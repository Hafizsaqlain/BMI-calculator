// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_test_common;

import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

typedef IsolateTest = Future<void> Function(
  VmService service,
  IsolateRef isolate,
);
typedef VMTest = Future<void> Function(VmService service);

Future<void> smartNext(VmService service, IsolateRef isolateRef) async {
  print('smartNext');
  final isolate = await service.getIsolate(isolateRef.id!);
  final Event event = isolate.pauseEvent!;
  if (event.kind == EventKind.kPauseBreakpoint) {
    // TODO(bkonyi): remove needless refetching of isolate object.
    if (event.atAsyncSuspension ?? false) {
      return asyncNext(service, isolateRef);
    } else {
      return syncNext(service, isolateRef);
    }
  } else {
    throw 'The program is already running';
  }
}

Future<void> asyncNext(VmService service, IsolateRef isolateRef) async {
  print('asyncNext');
  final id = isolateRef.id!;
  final isolate = await service.getIsolate(id);
  final event = isolate.pauseEvent!;
  if (event.kind == EventKind.kPauseBreakpoint) {
    final dynamic event = isolate.pauseEvent;
    if (!event.atAsyncSuspension) {
      throw 'No async continuation at this location';
    } else {
      await service.resume(id, step: 'OverAsyncSuspension');
    }
  } else {
    throw 'The program is already running';
  }
}

Future<void> syncNext(VmService service, IsolateRef isolateRef) async {
  print('syncNext');
  final id = isolateRef.id!;
  final isolate = await service.getIsolate(id);
  final event = isolate.pauseEvent!;
  if (event.kind == EventKind.kPauseBreakpoint) {
    await service.resume(id, step: 'Over');
  } else {
    throw 'The program is already running';
  }
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasPausedFor(
  VmService service,
  IsolateRef isolateRef,
  String kind,
) async {
  Completer<dynamic>? completer = Completer();
  late StreamSubscription<Event> subscription;
  subscription = service.onDebugEvent.listen((event) async {
    if ((isolateRef.id == event.isolate!.id) && (event.kind == kind)) {
      if (completer != null) {
        try {
          await service.streamCancel(EventStreams.kDebug);
        } catch (_) {/* swallow exception */} finally {
          await subscription.cancel();
          completer?.complete();
          completer = null;
        }
      }
    }
  });

  await _subscribeDebugStream(service);

  // Pause may have happened before we subscribed.
  final id = isolateRef.id!;
  final isolate = await service.getIsolate(id);
  final event = isolate.pauseEvent!;
  if (event.kind == kind) {
    if (completer != null) {
      try {
        await service.streamCancel(EventStreams.kDebug);
      } catch (_) {/* swallow exception */} finally {
        await subscription.cancel();
        completer?.complete();
      }
    }
  }
  return completer?.future; // Will complete when breakpoint hit.
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasStoppedAtBreakpoint(VmService service, IsolateRef isolate) {
  return hasPausedFor(service, isolate, EventKind.kPauseBreakpoint);
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasStoppedPostRequest(VmService service, IsolateRef isolate) {
  return hasPausedFor(service, isolate, EventKind.kPausePostRequest);
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasStoppedWithUnhandledException(
  VmService service,
  IsolateRef isolate,
) {
  return hasPausedFor(service, isolate, EventKind.kPauseException);
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasStoppedAtExit(VmService service, IsolateRef isolate) {
  return hasPausedFor(service, isolate, EventKind.kPauseExit);
}

// WARNING: interleaving calls based on hasPausedFor using Future.wait() may
// cause the debug stream to be cancelled after one of the checks completes.
// If another check is waiting on an event, it will no longer be notified of
// the event, causing the test to hang.
Future<void> hasPausedAtStart(VmService service, IsolateRef isolate) {
  return hasPausedFor(service, isolate, EventKind.kPauseStart);
}

Future<void> markDartColonLibrariesDebuggable(
  VmService service,
  IsolateRef isolateRef,
) async {
  final isolateId = isolateRef.id!;
  final isolate = await service.getIsolate(isolateId);
  final requests = <Future>[];
  for (final libRef in isolate.libraries!) {
    final lib = await service.getObject(isolateId, libRef.id!) as Library;
    if (lib.uri!.startsWith('dart:') && !lib.uri!.startsWith('dart:_')) {
      requests.add(service.setLibraryDebuggable(isolateId, lib.id!, true));
    }
  }
  await Future.wait(requests);
}

// Currying is your friend.
IsolateTest setBreakpointAtLine(int line) {
  return (VmService service, IsolateRef isolateRef) async {
    print('Setting breakpoint for line $line');
    final isolateId = isolateRef.id!;
    final isolate = await service.getIsolate(isolateId);
    final Library lib =
        (await service.getObject(isolateId, isolate.rootLib!.id!)) as Library;
    final script = lib.scripts!.first;

    final Breakpoint bpt =
        await service.addBreakpoint(isolateId, script.id!, line);
    print('Breakpoint is $bpt');
  };
}

IsolateTest setBreakpointAtUriAndLine(String uri, int line) {
  return (VmService service, IsolateRef isolateRef) async {
    print('Setting breakpoint for line $line in $uri');
    final Breakpoint bpt =
        await service.addBreakpointWithScriptUri(isolateRef.id!, uri, line);
    print('Breakpoint is $bpt');
    expect(bpt, isNotNull);
  };
}

IsolateTest setBreakpointAtLineColumn(int line, int column) {
  return (VmService service, IsolateRef isolateRef) async {
    print('Setting breakpoint for line $line column $column');
    final isolateId = isolateRef.id!;
    final isolate = await service.getIsolate(isolateId);
    final lib =
        await service.getObject(isolateId, isolate.rootLib!.id!) as Library;
    final ScriptRef script = lib.scripts!.firstWhere((s) => s.uri == lib.uri);
    final Breakpoint bpt = await service.addBreakpoint(
      isolateId,
      script.id!,
      line,
      column: column,
    );
    print('Breakpoint is $bpt');
    expect(bpt, isNotNull);
  };
}

extension FrameLocation on Frame {
  Future<(String, int)> getLocation(
    VmService service,
    IsolateRef isolateRef,
  ) async {
    if (location?.tokenPos == null) {
      return ('<unknown>', -1);
    }

    final script = (await service.getObject(
      isolateRef.id!,
      location!.script!.id!,
    )) as Script;
    return (
      script.uri!,
      script.getLineNumberFromTokenPos(location!.tokenPos!) ?? -1
    );
  }
}

Future<String> formatFrames(
  VmService service,
  IsolateRef isolateRef,
  List<Frame> frames,
) async {
  final sb = StringBuffer();
  for (Frame f in frames) {
    sb.write(' $f');
    if (f.function case final funcRef?) {
      sb.write(' ');
      sb.write(await qualifiedFunctionName(service, isolateRef, funcRef));
    }
    if (f.location != null) {
      final (uri, lineNo) = await f.getLocation(service, isolateRef);
      sb.write(' $uri:$lineNo');
    }
    sb.writeln();
  }
  return sb.toString();
}

Future<String> formatStack(
  VmService service,
  IsolateRef isolateRef,
  Stack stack,
) async {
  final sb = StringBuffer();
  sb.write('Full stack trace:\n');
  sb.writeln(await formatFrames(service, isolateRef, stack.frames!));
  if (stack.asyncCausalFrames case final asyncFrames?) {
    sb.write('\nFull async stack trace:\n');
    sb.writeln(await formatFrames(service, isolateRef, asyncFrames));
  }
  return sb.toString();
}

IsolateTest stoppedAtLine(int line) {
  return (VmService service, IsolateRef isolateRef) async {
    print('Checking we are at line $line');

    // Make sure that the isolate has stopped.
    final id = isolateRef.id!;
    final isolate = await service.getIsolate(id);
    final event = isolate.pauseEvent!;
    expect(event.kind != EventKind.kResume, isTrue);

    final stack = await service.getStack(id);

    final frames = stack.frames!;
    expect(frames.length, greaterThanOrEqualTo(1));

    final top = frames[0];
    final (_, actualLine) = await top.getLocation(service, isolateRef);
    if (actualLine != line) {
      print('Actual: $actualLine Line: $line');
      final sb = StringBuffer();
      sb.write('Expected to be at line $line but actually at line $actualLine');
      sb.writeln(await formatStack(service, isolateRef, stack));
      throw sb.toString();
    } else {
      print('Program is stopped at line: $line');
    }
  };
}

Future<void> resumeIsolate(VmService service, IsolateRef isolate) async {
  final Completer completer = Completer();
  late StreamSubscription<Event> subscription;
  bool cancelStreamAfterResume = false;
  subscription = service.onDebugEvent.listen((event) async {
    if (event.kind == EventKind.kResume) {
      try {
        if (cancelStreamAfterResume) {
          await service.streamCancel(EventStreams.kDebug);
        }
      } catch (_) {/* swallow exception */} finally {
        await subscription.cancel();
        completer.complete();
      }
    }
  });
  cancelStreamAfterResume = await _subscribeDebugStream(service);
  await service.resume(isolate.id!);
  return completer.future;
}

Future<bool> _subscribeDebugStream(VmService service) async {
  try {
    await service.streamListen(EventStreams.kDebug);
    return true;
  } catch (_) {
    /* swallow exception */
    return false;
  }
}

Future<void> _unsubscribeDebugStream(VmService service) async {
  try {
    await service.streamCancel(EventStreams.kDebug);
  } catch (_) {
    /* swallow exception */
  }
}

Future<void> resumeAndAwaitEvent(
  VmService service,
  IsolateRef isolateRef,
  String streamId,
  Function(Event) onEvent,
) async {
  final completer = Completer<void>();
  late final StreamSubscription sub;
  sub = service.onEvent(streamId).listen((event) async {
    await onEvent(event);
    await sub.cancel();
    await service.streamCancel(streamId);
    completer.complete();
  });

  await service.streamListen(streamId);
  await service.resume(isolateRef.id!);
  return completer.future;
}

IsolateTest resumeIsolateAndAwaitEvent(
  String streamId,
  Function(Event) onEvent,
) {
  return (VmService service, IsolateRef isolate) async =>
      resumeAndAwaitEvent(service, isolate, streamId, onEvent);
}

Future<void> stepOver(VmService service, IsolateRef isolateRef) async {
  await _subscribeDebugStream(service);
  await service.resume(isolateRef.id!, step: 'Over');
  await hasStoppedAtBreakpoint(service, isolateRef);
  await _unsubscribeDebugStream(service);
}

Future<void> stepInto(VmService service, IsolateRef isolateRef) async {
  await _subscribeDebugStream(service);
  await service.resume(isolateRef.id!, step: 'Into');
  await hasStoppedAtBreakpoint(service, isolateRef);
  await _unsubscribeDebugStream(service);
}

Future<void> stepOut(VmService service, IsolateRef isolateRef) async {
  await _subscribeDebugStream(service);
  await service.resume(isolateRef.id!, step: 'Out');
  await hasStoppedAtBreakpoint(service, isolateRef);
  await _unsubscribeDebugStream(service);
}

IsolateTest resumeProgramRecordingStops(
  List<String> recordStops,
  bool includeCaller,
) {
  return (VmService service, IsolateRef isolateRef) async {
    final completer = Completer<void>();

    late StreamSubscription subscription;
    subscription = service.onDebugEvent.listen((event) async {
      if (event.kind == EventKind.kPauseBreakpoint) {
        final stack = await service.getStack(isolateRef.id!);
        expect(stack.frames!.length, greaterThanOrEqualTo(2));

        String brokeAt =
            await _locationToString(service, isolateRef, stack.frames![0]);
        if (includeCaller) {
          brokeAt =
              '$brokeAt (${await _locationToString(service, isolateRef, stack.frames![1])})';
        }
        recordStops.add(brokeAt);
        await service.resume(isolateRef.id!);
      } else if (event.kind == EventKind.kPauseExit) {
        await subscription.cancel();
        await service.streamCancel(EventStreams.kDebug);
        completer.complete();
      }
    });

    await service.streamListen(EventStreams.kDebug);
    await service.resume(isolateRef.id!);
    return completer.future;
  };
}

Future<String> _locationToString(
  VmService service,
  IsolateRef isolateRef,
  Frame frame,
) async {
  final location = frame.location!;
  final Script script =
      await service.getObject(isolateRef.id!, location.script!.id!) as Script;
  final scriptName = p.basename(script.uri!);
  final tokenPos = location.tokenPos!;
  final line = script.getLineNumberFromTokenPos(tokenPos);
  final column = script.getColumnNumberFromTokenPos(tokenPos);
  return '$scriptName:$line:$column';
}

IsolateTest runStepThroughProgramRecordingStops(List<String> recordStops) {
  return (VmService service, IsolateRef isolateRef) async {
    final completer = Completer<void>();

    late StreamSubscription subscription;
    subscription = service.onDebugEvent.listen((event) async {
      if (event.kind == EventKind.kPauseBreakpoint) {
        final isolate = await service.getIsolate(isolateRef.id!);
        final frame = isolate.pauseEvent!.topFrame!;
        recordStops.add(await _locationToString(service, isolateRef, frame));
        if (event.atAsyncSuspension ?? false) {
          await service.resume(
            isolateRef.id!,
            step: StepOption.kOverAsyncSuspension,
          );
        } else {
          await service.resume(isolateRef.id!, step: StepOption.kOver);
        }
      } else if (event.kind == EventKind.kPauseExit) {
        await subscription.cancel();
        await service.streamCancel(EventStreams.kDebug);
        completer.complete();
      }
    });
    await service.streamListen(EventStreams.kDebug);
    await service.resume(isolateRef.id!);
    return completer.future;
  };
}

IsolateTest runStepIntoThroughProgramRecordingStops(List<String> recordStops) {
  return (VmService service, IsolateRef isolateRef) async {
    final completer = Completer<void>();

    late StreamSubscription subscription;
    subscription = service.onDebugEvent.listen((event) async {
      if (event.kind == EventKind.kPauseBreakpoint) {
        final isolate = await service.getIsolate(isolateRef.id!);
        final frame = isolate.pauseEvent!.topFrame!;
        recordStops.add(await _locationToString(service, isolateRef, frame));
        await service.resume(isolateRef.id!, step: StepOption.kInto);
      } else if (event.kind == EventKind.kPauseExit) {
        await subscription.cancel();
        await service.streamCancel(EventStreams.kDebug);
        completer.complete();
      }
    });
    await service.streamListen(EventStreams.kDebug);
    await service.resume(isolateRef.id!);
    return completer.future;
  };
}

IsolateTest checkRecordedStops(
  List<String> recordStops,
  List<String> expectedStops, {
  bool removeDuplicates = false,
  bool debugPrint = false,
  String? debugPrintFile,
  int? debugPrintLine,
}) {
  return (VmService service, IsolateRef isolate) async {
    if (debugPrint) {
      for (int i = 0; i < recordStops.length; i++) {
        final String line = recordStops[i];
        String output = line;
        final int firstColon = line.indexOf(':');
        final int lastColon = line.lastIndexOf(':');
        if (debugPrintFile != null &&
            debugPrintLine != null &&
            firstColon > 0 &&
            lastColon > 0) {
          final int lineNumber =
              int.parse(line.substring(firstColon + 1, lastColon));
          final int relativeLineNumber = lineNumber - debugPrintLine;
          final columnNumber = line.substring(lastColon + 1);
          final file = line.substring(0, firstColon);
          if (file == debugPrintFile) {
            output = '\$file:\${LINE+$relativeLineNumber}:$columnNumber';
          }
        }
        final String comma = i == recordStops.length - 1 ? '' : ',';
        print("'$output'$comma");
      }
    }
    if (removeDuplicates) {
      recordStops = removeAdjacentDuplicates(recordStops);
      expectedStops = removeAdjacentDuplicates(expectedStops);
    }

    // Single stepping may record extra stops.
    // Allow the extra ones as long as the expected ones are recorded.
    int i = 0;
    int j = 0;
    while (i < recordStops.length && j < expectedStops.length) {
      if (recordStops[i] != expectedStops[j]) {
        // Check if recordStops[i] is an extra stop.
        int k = i + 1;
        while (k < recordStops.length && recordStops[k] != expectedStops[j]) {
          k++;
        }
        if (k < recordStops.length) {
          // Allow and ignore extra recorded stops from i to k-1.
          i = k;
        } else {
          // This will report an error.
          expect(recordStops[i], expectedStops[j]);
        }
      }
      i++;
      j++;
    }

    expect(
      recordStops.length >= expectedStops.length,
      true,
      reason: 'Expects at least ${expectedStops.length} breaks, '
          'got ${recordStops.length}.',
    );
  };
}

List<String> removeAdjacentDuplicates(List<String> fromList) {
  final List<String> result = <String>[];
  String? latestLine;
  for (String s in fromList) {
    if (s == latestLine) continue;
    latestLine = s;
    result.add(s);
  }
  return result;
}

/// Waits for ServiceProtocolInfo.serverUri to be populated.
Future<ServiceProtocolInfo> waitForServiceInfo() async {
  print('Waiting for the VM service URI to become available...');
  var info = await Service.getInfo();
  while (info.serverUri == null) {
    await Future.delayed(const Duration(milliseconds: 100));
    info = await Service.getInfo();
  }
  print('VM service URI has become available: ${info.serverUri}');
  return info;
}

typedef ServiceExtensionHandler = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> cb,
);

/// Registers a service extension and returns the actual service name used to
/// invoke the service.
Future<String> registerServiceHelper(
  VmService primaryClient,
  VmService serviceRegisterClient,
  String serviceName,
  ServiceExtensionHandler callback,
) async {
  final serviceNameCompleter = Completer<String>();
  late final StreamSubscription sub;
  sub = primaryClient.onServiceEvent.listen((event) {
    if (event.kind == EventKind.kServiceRegistered &&
        event.method!.endsWith(serviceName)) {
      serviceNameCompleter.complete(event.method!);
      sub.cancel();
    }
  });
  // TODO(bkonyi): if we end up in a situation where this call throws due to a
  // prior subscription to the Service stream, we should do something similar
  // to _subscribeDebugStream in this method.
  await primaryClient.streamListen(EventStreams.kService);

  // Register the service.
  serviceRegisterClient.registerServiceCallback(serviceName, callback);
  await serviceRegisterClient.registerService(serviceName, serviceName);

  // Wait for the service registered event on the non-registering client to get
  // the actual service name.
  final actualServiceName = await serviceNameCompleter.future;
  print("Service '$serviceName' registered as '$actualServiceName'");
  await primaryClient.streamCancel(EventStreams.kService);
  return actualServiceName;
}

Future<void> evaluateInFrameAndExpect(
  VmService service,
  String isolateId,
  String expression,
  String expected, {
  Map<String, String>? scope,
  String? kind,
  int topFrame = 0,
}) async {
  final result = await service.evaluateInFrame(
    isolateId,
    topFrame,
    expression,
    scope: scope,
  ) as InstanceRef;
  expect(result.valueAsString, expected);
  if (kind != null) {
    expect(result.kind!, kind);
  }
}

Future<void> evaluateAndExpect(
  VmService service,
  String isolateId,
  String targetId,
  String expression,
  String expected, {
  Map<String, String>? scope,
  String? kind,
}) async {
  final result = await service.evaluate(
    isolateId,
    targetId,
    expression,
    scope: scope,
  ) as InstanceRef;
  expect(result.valueAsString, expected);
  if (kind != null) {
    expect(result.kind!, kind);
  }
}

Future<HeapSnapshotGraph> fetchHeapSnapshot(
  VmService service,
  IsolateRef isolateRef,
) async {
  final isolateId = isolateRef.id!;
  final completer = Completer<void>();
  late final StreamSubscription sub;
  final data = <ByteData>[];
  sub = service.onHeapSnapshotEvent.listen((event) async {
    data.add(event.data!);
    if (event.last == true) {
      await sub.cancel();
      await service.streamCancel(EventStreams.kHeapSnapshot);
      completer.complete();
    }
  });
  await service.streamListen(EventStreams.kHeapSnapshot);
  await service.requestHeapSnapshot(isolateId);
  await completer.future;
  return HeapSnapshotGraph.fromChunks(data);
}

IsolateTest reloadSources({bool pause = false}) {
  return (VmService service, IsolateRef isolateRef) async {
    await service.reloadSources(isolateRef.id!, pause: pause);
  };
}

IsolateTest hasLocalVarInTopStackFrame(String varName) {
  return (VmService service, IsolateRef isolateRef) async {
    print("Checking we have variable '$varName' in the top frame");

    final isolateId = isolateRef.id!;
    // Make sure that the isolate has stopped.
    final isolate = await service.getIsolate(isolateId);
    expect(isolate.pauseEvent, isNotNull);
    expect(isolate.pauseEvent!.kind, isNot(EventKind.kResume));

    final stack = await service.getStack(isolateId);
    final frames = stack.frames!;
    expect(frames.length, greaterThanOrEqualTo(1));

    final top = frames[0];
    final vars = top.vars!;
    for (final variable in vars) {
      if (variable.name == varName) {
        return;
      }
    }
    final sb = StringBuffer();
    sb.write('Expected to find $varName in top awaiter stack frame, found ');
    if (vars.isEmpty) {
      sb.writeln('no variables');
    } else {
      sb.writeln('these instead:');
      for (var variable in vars) {
        sb.writeln('\t${variable.name}');
      }
    }
    throw sb.toString();
  };
}

IsolateTest stoppedInFunction(String functionName) {
  return (VmService service, IsolateRef isolateRef) async {
    print('Checking we are in function: $functionName');

    final isolateId = isolateRef.id!;
    final stack = await service.getStack(isolateId);

    final frames = stack.frames!;
    expect(frames, isNotEmpty);

    final topFrame = frames[0];
    final function = await service.getObject(
      isolateId,
      topFrame.function!.id!,
    ) as Func;
    final name = function.name!;
    if (name != functionName) {
      final sb = StringBuffer();
      sb.writeln(
        'Expected to be in function $functionName but '
        'actually in function $name',
      );
      sb.writeln(await formatStack(service, isolateRef, stack));

      throw sb.toString();
    } else {
      print('Program is stopped in function: $functionName');
    }
  };
}

Future<String> qualifiedFunctionName(
  VmService service,
  IsolateRef isolate,
  FuncRef func,
) async {
  final funcName = func.name ?? '<unknown>';
  switch (func.owner) {
    case final FuncRef parentFuncRef:
      final parentFuncName =
          await qualifiedFunctionName(service, isolate, parentFuncRef);
      return '$parentFuncName.$funcName';

    case final ClassRef parentClass:
      return '${parentClass.name!}.$funcName';

    case _:
      return funcName;
  }
}

Future<void> expectFrame(
  VmService service,
  IsolateRef isolate,
  Frame frame, {
  String kind = 'Regular',
  String? functionName,
  int? line,
}) async {
  expect(frame.kind, equals(kind));
  if (functionName != null) {
    expect(
      await qualifiedFunctionName(service, isolate, frame.function!),
      equals(functionName),
    );
  }
  if (line != null) {
    expect(frame.location, isNotNull);

    final script = await service.getObject(
      isolate.id!,
      frame.location!.script!.id!,
    ) as Script;
    expect(
      script.getLineNumberFromTokenPos(frame.location!.tokenPos!),
      equals(line),
    );
  }
}

Future<String> getCurrentExceptionAsString(
  VmService service,
  IsolateRef isolateRef,
) async {
  final isolate = await service.getIsolate(isolateRef.id!);
  final event = isolate.pauseEvent!;
  final exception = await service.getObject(
    isolateRef.id!,
    event.exception!.id!,
  ) as Instance;
  return exception.valueAsString!;
}

typedef ExpectedFrame = ({String? functionName, int? line});
const ExpectedFrame asyncGap = (functionName: null, line: null);

IsolateTest resumePastUnhandledException(String exceptionAsString) {
  return (service, isolateRef) async {
    do {
      await resumeIsolate(service, isolateRef);
      await hasStoppedWithUnhandledException(service, isolateRef);
    } while (await getCurrentExceptionAsString(service, isolateRef) ==
        exceptionAsString);
  };
}

IsolateTest expectUnhandledExceptionWithFrames({
  List<ExpectedFrame>? expectedFrames,
  String? exceptionAsString,
}) {
  return (VmService service, IsolateRef isolateRef) async {
    await hasStoppedWithUnhandledException(service, isolateRef);
    if (exceptionAsString != null) {
      expect(
        await getCurrentExceptionAsString(service, isolateRef),
        equals(exceptionAsString),
      );
    }

    if (expectedFrames == null) {
      return;
    }

    final stack = await service.getStack(isolateRef.id!);

    final frames = stack.asyncCausalFrames!;
    var currentKind = 'Regular';
    for (var i = 0; i < expectedFrames.length; i++) {
      final expected = expectedFrames[i];
      final got = frames[i];
      await expectFrame(
        service,
        isolateRef,
        got,
        kind: expected == asyncGap ? 'AsyncSuspensionMarker' : currentKind,
        functionName: expected.functionName,
        line: expected.line,
      );
      if (expected == asyncGap) {
        currentKind = 'AsyncCausal';
      }
    }
  };
}

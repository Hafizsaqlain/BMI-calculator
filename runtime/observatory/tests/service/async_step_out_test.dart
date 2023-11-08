// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// VMOptions=--async-debugger --verbose-debug

import 'dart:developer';
import 'service_test_common.dart';
import 'test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart runtime/observatory/tests/service/update_line_numbers.dart <test.dart>
//
const int LINE_A = 29;
const int LINE_B = 30;
const int LINE_C = 31;
const int LINE_G = 36;
const int LINE_0 = 40;
const int LINE_D = 41;
const int LINE_E = 42;
const int LINE_F = 43;
const int LINE_H = 44;
// AUTOGENERATED END

Future<int> helper() async {
  await null; // LINE_A.
  print('line b'); // LINE_B.
  print('line c'); // LINE_C.
  return 0;
}

Future<void> testMain() async {
  int process(int value) /* LINE_G */ {
    return value + 1;
  }

  debugger(); // LINE_0.
  print('line d'); // LINE_D.
  await helper().then(process); // LINE_E.
  final v = process(10); // LINE_F.
  print('line h'); // LINE_H.
}

var tests = <IsolateTest>[
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_0),
  stepOver, // debugger.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_D),
  stepOver, // print.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_E),
  stepInto,

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  asyncNext,

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_B),
  stepOver, // print.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_C),
  stepOut, // out of helper to awaiter testMain.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_G),
  stepOut, // out of helper to awaiter testMain.

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_F),
  stepOver,

  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_H),
];

main(args) => runIsolateTests(args, tests,
    testeeConcurrent: testMain, extraArgs: extraDebuggingArgs);

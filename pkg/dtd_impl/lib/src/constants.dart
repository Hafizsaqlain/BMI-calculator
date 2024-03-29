// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class RPCResponses {
  static const success = <String, dynamic>{
    'type': 'Success',
  };

  static const collectedSentinel = <String, dynamic>{
    'type': 'Sentinel',
    'kind': 'Collected',
    'valueAsString': '<collected>',
  };
}

// Give connections time to reestablish before considering them closed.
// Required to reestablish connections killed by UberProxy.
const sseKeepAlive = Duration(seconds: 30);

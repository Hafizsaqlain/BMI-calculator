// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:async";

/*member: main:
 dynamic=[runtimeType],
 runtimeType=[unknown:FutureOr<int>],
 static=[
  Future.value(1),
  checkTypeBound(4),
  print(1)],
 type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]
*/
@pragma('dart2js:disableFinal')
void main() {
  FutureOr<int> i = Future<int>.value(0);
  print(i.runtimeType);
}

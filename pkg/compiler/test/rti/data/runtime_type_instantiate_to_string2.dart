// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*member: global#instantiate1:needsArgs*/

/*spec.member: id:explicit=[id.T],needsArgs,needsInst=[<int>],test*/
T id<T>(T t, String s) => t;

main() {
  int Function(int, String s) x = id;
  makeLive("${x.runtimeType}");
}

// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

class Class<T> {
  Class();
}

method1() {}

method2(int i, String s) => i;

main() {
  makeLive('${method1.runtimeType}');
  method2(0, '');
  Class();
}

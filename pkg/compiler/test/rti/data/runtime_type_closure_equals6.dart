// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

method1a() => null;

method1b() => null;

method2(t, s) => t;

class Class<T> {
  Class();
}

main() {
  makeLive(method1a.runtimeType == method1b.runtimeType);
  makeLive(method1a.runtimeType == method2.runtimeType);
  Class<int>();
}

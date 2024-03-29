// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*class: Class1:*/
class Class1 {
  /*member: Class1.:*/
  Class1();

  /*member: Class1.method:*/
  T? method<T>() => null;
}

/*class: Class2:*/
class Class2<T> {
  /*member: Class2.:*/
  Class2();
}

/*member: main:*/
main() {
  Class1 cls1 = Class1();
  makeLive(cls1.method.runtimeType.toString());
  Class2<int>();
}

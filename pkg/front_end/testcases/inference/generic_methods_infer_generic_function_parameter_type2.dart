// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
/*@testedFeatures=inference*/
library test;

class C<T> extends D<T> {
  f<U>(g) => null;
}

abstract class D<T> {
  void f<U>(G<U> g);
}

typedef List<V> G<V>();

main() {}

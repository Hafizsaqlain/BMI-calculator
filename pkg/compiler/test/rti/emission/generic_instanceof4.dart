// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*class: A:checks=[],instance*/
class A<T> {
  @pragma('dart2js:noInline')
  foo(x) {
    return x is T;
  }
}

/*class: BB:checkedInstance,typeArgument*/
class BB {}

/*class: B:checks=[$isBB],instance*/
class B<T> implements BB {
  @pragma('dart2js:noInline')
  foo() {
    return A<T>().foo(new B());
  }
}

main() {
  B<BB>().foo();
}

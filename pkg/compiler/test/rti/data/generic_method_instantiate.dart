// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*class: A:explicit=[B<A>]*/
class A {}

/*class: B:deps=[method],explicit=[B<A>],needsArgs*/
class B<T> {}

/*member: method:needsArgs*/
method<T>() => B<T>();

main() {
  method<A>() is B<A>;
}

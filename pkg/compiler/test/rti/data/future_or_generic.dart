// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/*spec.class: global#Future:deps=[A],implicit=[Future<A.T>],needsArgs,test*/

/*class: A:explicit=[FutureOr<A.T>],implicit=[A.T,Future<A.T>],needsArgs,test*/
class A<T> {
  m(o) => o is FutureOr<T>;
}

// TODO(johnniwinther): Do we need the implied `Future<B>` test in `A.m`?
/*class: B:implicit=[B]*/
class B {}

main() {
  A<B>().m(new B());
}

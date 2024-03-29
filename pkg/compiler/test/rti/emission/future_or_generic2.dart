// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:compiler/src/util/testing.dart';

/*class: global#Future:checkedInstance*/

/*class: A:checks=[],instance*/
class A<T> {
  @pragma('dart2js:noInline')
  m(o) => o is FutureOr<B<T>>;
}

/*class: B:checkedInstance,checkedTypeArgument,checks=[],instance,typeArgument*/
class B<T> {}

/*class: C:checkedInstance,checkedTypeArgument,typeArgument*/
class C {}

/*class: D:checkedInstance,checkedTypeArgument,typeArgument*/
class D {}

main() {
  makeLive(new A<C>().m(new B<C>()));
  makeLive(new A<D>().m(new B<C>()));
}

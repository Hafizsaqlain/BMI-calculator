// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*class: B:checkedInstance,typeArgument*/
class B {}

/*class: C:checks=[],instance*/
class C {
  @pragma('dart2js:noInline')
  method1<T>(o) => method2<T>(o);

  @pragma('dart2js:noInline')
  method2<T>(o) => o is T;
}

/*class: D:checks=[$isB],instance*/
class D implements B {}

@pragma('dart2js:noInline')
test(o) => C().method1<B>(o);

main() {
  makeLive(test(new D()));
  makeLive(test(null));
}

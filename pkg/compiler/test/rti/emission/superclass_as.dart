// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*class: A:checkedInstance,checks=[],instance*/
class A<T> {}

/*class: B:checks=[],indirectInstance*/
class B<T, S> {
  @pragma('dart2js:noInline')
  method() => A<S>();
}

/*class: C:checks=[],instance*/
class C<T> extends B<T, T> {}

@pragma('dart2js:noInline')
test(o) => o is A<int>;

main() {
  makeLive(test(new C<int>().method()));
  makeLive(test(new C<String>().method()));
}

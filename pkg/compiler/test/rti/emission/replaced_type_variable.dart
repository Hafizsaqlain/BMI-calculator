// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

// This class is inlined away.
/*class: Class:checks=[],instance*/
class Class<T> {
  const Class();

  Type get type => T;
}

/*class: A:typeArgument*/
class A {}

@pragma('dart2js:noInline')
test(o) => makeLive('dynamic' != '$o');

main() {
  test(const Class<A>().type);
}

// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*spec.class: global#JSArray:checkedInstance,checks=[$isIterable,$isList],instance*/
/*prod.class: global#JSArray:checks=[$isList],instance*/

@pragma('dart2js:noInline')
method<T>() {
  return /*checks=[],instance*/ () => <T>[];
}

@pragma('dart2js:noInline')
test(o) => o is List<int>;

main() {
  makeLive(test(method<int>().call()));
  makeLive(test(method<String>().call()));
}

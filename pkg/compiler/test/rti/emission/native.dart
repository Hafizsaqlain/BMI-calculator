// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:compiler/src/util/testing.dart";
// ignore: import_internal_library
import 'dart:_js_helper' show Native;
// ignore: import_internal_library
import 'dart:_foreign_helper' show JS;

/*class: Purple:checkedInstance,checks=[$isPurple],instance*/
@Native('PPPP')
class Purple {}

/*class: Q:instance*/
@Native('QQQQ')
class Q {}

@pragma('dart2js:noInline')
makeP() => JS('returns:;creates:Purple', 'null');

@pragma('dart2js:noInline')
makeQ() => JS('Q', 'null');

@pragma('dart2js:noInline')
testNative() {
  var x = makeP();
  makeLive(x is Purple);
  x = makeQ();
  makeLive(x is Purple);
}

main() {
  testNative();
}

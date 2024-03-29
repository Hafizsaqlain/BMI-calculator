// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Derived from tests/web/generic_type_error_message_test.

import 'package:compiler/src/util/testing.dart';

/*class: Foo:*/
class Foo<T extends num> {}

/*class: Bar:*/
class Bar<T extends num> {}

/*class: Baz:explicit=[Baz<num>],needsArgs*/
class Baz<T extends num> {}

@pragma('dart2js:disableFinal')
main() {
  test(new Foo(), Foo, expectTypeArguments: false);
  // ignore: unnecessary_cast
  test(new Bar() as Bar<num>, Bar, expectTypeArguments: false);
  Baz<num> b = Baz();
  dynamic c = b;
  test(c as Baz<num>, Baz, expectTypeArguments: true);
}

void test(dynamic object, Type type, {required bool expectTypeArguments}) {
  bool caught = false;
  try {
    makeLive(type);
    object as List<String>;
  } catch (e) {
    String expected = '$type';
    if (!expectTypeArguments) {
      expected = expected.substring(0, expected.indexOf('<'));
    }
    expected = "'$expected'";
    makeLive(e.toString().contains(expected));
    caught = true;
    makeLive(e);
  }
  makeLive(caught);
}

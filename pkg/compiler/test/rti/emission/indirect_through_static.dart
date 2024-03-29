// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*class: A:checkedInstance,typeArgument*/
abstract class A {}

/*class: B:typeArgument*/
class B implements A {}

/*class: C:checkedInstance,checks=[],instance,typeArgument*/
class C<T> {}

final Map<String, C> map = {};

void setup() {
  map['x'] = C<B>();
}

C<T> lookup<T>(String key) {
  final value = map[key];
  if (value != null && value is C<T>) {
    return value;
  }
  throw 'Invalid C value for $key: ${value}';
}

void lookupA() {
  lookup<A>('x');
}

main() {
  setup();
  lookupA();
}

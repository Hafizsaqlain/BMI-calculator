// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

/*class: A:checkedInstance,checks=[],instance*/
class A<T> {}

main() {
  test1();
  test2();
  test3();
  test4();
  test5();
  test6();
}

/*class: B1:checkedTypeArgument,typeArgument*/
class B1<T> {}

/*class: C1:checkedTypeArgument,typeArgument*/
class C1 extends B1<int> {}

@pragma('dart2js:noInline')
test1() {
  makeLive(_test1(new A<void Function(C1)>()));
  makeLive(_test1(new A<void Function(B1<int>)>()));
  makeLive(_test1(new A<void Function(B1<String>)>()));
}

@pragma('dart2js:noInline')
_test1(f) => f is A<void Function(C1)>;

/*class: B2:typeArgument*/
class B2<T> {}

/*class: C2:checkedTypeArgument,typeArgument*/
class C2 extends B2<int> {}

@pragma('dart2js:noInline')
test2() {
  makeLive(_test2(new A<C2 Function()>()));
  makeLive(_test2(new A<B2<int> Function()>()));
  makeLive(_test2(new A<B2<String> Function()>()));
}

@pragma('dart2js:noInline')
_test2(f) => f is A<C2 Function()>;

/*class: B3:checkedTypeArgument,typeArgument*/
class B3<T> {}

/*class: C3:checkedTypeArgument,typeArgument*/
class C3 extends B3<int> {}

@pragma('dart2js:noInline')
test3() {
  makeLive(_test3(new A<void Function(C3)>()));
  makeLive(_test3(new A<void Function(B3<int>)>()));
  makeLive(_test3(new A<void Function(B3<String>)>()));
}

@pragma('dart2js:noInline')
_test3(f) => f is A<void Function(B3<int>)>;

/*class: B4:checkedTypeArgument,typeArgument*/
class B4<T> {}

/*class: C4:typeArgument*/
class C4 extends B4<int> {}

@pragma('dart4js:noInline')
test4() {
  makeLive(_test4(new A<C4 Function()>()));
  makeLive(_test4(new A<B4<int> Function()>()));
  makeLive(_test4(new A<B4<String> Function()>()));
}

@pragma('dart4js:noInline')
_test4(f) => f is A<B4<int> Function()>;

/*class: B5:checkedTypeArgument,typeArgument*/
class B5<T> {}

/*class: C5:checkedTypeArgument,typeArgument*/
class C5 extends B5<int> {}

@pragma('dart2js:noInline')
test5() {
  makeLive(_test5(new A<void Function(C5 Function())>()));
  makeLive(_test5(new A<void Function(B5<int> Function())>()));
  makeLive(_test5(new A<void Function(B5<String> Function())>()));
}

@pragma('dart2js:noInline')
_test5(f) => f is A<void Function(C5 Function())>;

/*class: B6:typeArgument*/
class B6<T> {}

/*class: C6:checkedTypeArgument,typeArgument*/
class C6 extends B6<int> {}

@pragma('dart2js:noInline')
test6() {
  makeLive(_test6(new A<void Function(void Function(C6))>()));
  makeLive(_test6(new A<void Function(void Function(B6<int>))>()));
  makeLive(_test6(new A<void Function(void Function(B6<String>))>()));
}

@pragma('dart2js:noInline')
_test6(f) => f is A<void Function(void Function(C6))>;

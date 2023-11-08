// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Foo {}
class Bar {}
class Baz {}
class Boz {}
class BarBaz implements BarBaz {}
class BarBoz implements BarBoz {}

extension type ET1(int i) extends Foo {}
extension type ET2(int i) with Foo {}
extension type ET3(int i) with Foo, Bar {}
extension type ET4(int i) extends Foo with Bar {}
extension type ET5(int i) extends Foo with Bar, Baz {}
extension type ET6(Bar i) extends Foo implements Bar {}
extension type ET7(Bar i) with Foo implements Bar {}
extension type ET8(Baz i) with Foo, Bar implements Baz {}
extension type ET9(Baz i) extends Foo with Bar implements Baz {}
extension type ET10(Boz i) extends Foo with Bar, Baz implements Boz {}
extension type ET11(Bar i) implements Bar extends Foo {}
extension type ET12(Bar i) implements Bar with Foo {}
extension type ET13(Bar i) implements Bar with Foo, Bar {}
extension type ET14(Bar i) implements Bar extends Foo with Bar {}
extension type ET15(Bar i) implements Bar extends Foo with Bar, Baz {}
extension type ET16(Bar i) implements Bar extends Foo implements Bar {}
extension type ET17(Bar i) implements Bar with Foo implements Bar {}
extension type ET18(BarBaz i) implements Bar with Foo, Bar implements Baz {}
extension type ET19(BarBaz i) implements Bar extends Foo with Bar implements Baz {}
extension type ET20(BarBaz i) implements Bar extends Foo with Bar, Baz implements Boz {}
extension type ET21(Boz i) implements Bar implements Boz {}
extension type ET22(int i) extends Bar extends Boz {}
extension type ET23(int i) extends Bar, Boz {}

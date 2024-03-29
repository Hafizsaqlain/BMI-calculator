// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class C {
  /*member: C._private:deps=[D._private2],explicit=[_private.T],needsArgs,selectors=[Selector(call, _private, arity=1, types=1)],test*/
  _private<T>(t) => t is T;
}

class D {
  /*member: D._private2:implicit=[_private2.T],needsArgs,selectors=[Selector(call, _private2, arity=2, types=1)],test*/
  _private2<T>(c, t) => c._private<T>(t);
}

main() {
  dynamic d = D();
  d._private2<int>(new C(), 0);
}

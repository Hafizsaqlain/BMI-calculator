// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*member: staticMethod1:deps=[staticMethod2],explicit=[staticMethod1.T],needsArgs,selectors=[Selector(call, call, arity=1, types=1)],test*/
staticMethod1<T>(t) => t is T;

/*member: staticMethod2:implicit=[staticMethod2.T],needsArgs,selectors=[Selector(call, call, arity=2, types=1)],test*/
staticMethod2<T>(a, t) => a<T>(t);

main() {
  var b = staticMethod2;
  b<int>(staticMethod1, 0);
}

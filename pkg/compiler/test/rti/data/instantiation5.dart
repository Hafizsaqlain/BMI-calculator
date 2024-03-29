// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*spec.member: f:deps=[method],explicit=[f.T],needsArgs,needsInst=[<method.S>],test*/
/*prod.member: f:deps=[method]*/
int? f<T>(T a) => null;

typedef int? F<R>(R a);

/*spec.member: method:implicit=[method.S],needsArgs,test*/
/*prod.member: method:needsArgs*/
method<S>() {
  F<S> c;

  return () {
    c = f;
    return c;
  };
}

main() {
  method();
}

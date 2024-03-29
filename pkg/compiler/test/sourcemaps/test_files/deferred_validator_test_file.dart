// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'deferred_validator_test_lib.dart' deferred as def;

void main() {
  def.loadLibrary().then((_) {
    () {
      var helloClass = def.HelloClass();
      helloClass.printHello();
    }();
  });
}

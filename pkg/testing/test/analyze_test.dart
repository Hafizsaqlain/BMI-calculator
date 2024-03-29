// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:testing/src/run_tests.dart" as testing show main;

Future<void> main() {
  // This method is async, but keeps a port open to prevent the VM from exiting
  // prematurely.
  return testing.main(
      <String>["--config=pkg/testing/testing.json", "--verbose", "analyze"]);
}

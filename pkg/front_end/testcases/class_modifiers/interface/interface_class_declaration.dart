// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

interface class A {}

abstract interface class B {}

interface mixin M {}
interface class C = Object with M;

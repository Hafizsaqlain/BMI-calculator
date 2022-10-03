// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/entities.dart';

abstract class GlobalTypeInferenceResults {
  GlobalTypeInferenceMemberResult resultOfMember(MemberEntity member);
}

abstract class GlobalTypeInferenceMemberResult {
  bool get throwsAlways;
}

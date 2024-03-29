// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    show SourceChange;
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// A description of a single proposed fix for some problem.
///
/// Clients may not extend, implement or mix-in this class.
class Fix {
  /// A description of the fix being proposed.
  final FixKind kind;

  /// The change to be made in order to apply the fix.
  final SourceChange change;

  /// Initialize a newly created fix to have the given [kind] and [change].
  Fix(this.kind, this.change);

  @override
  String toString() {
    return 'Fix(kind=$kind, change=$change)';
  }

  /// A function that can be used to sort fixes by their relevance.
  ///
  /// The most relevant fixes will be sorted before fixes with a lower
  /// relevance. Fixes with the same relevance are sorted alphabetically.
  static int compareFixes(Fix a, Fix b) {
    if (a.kind.priority != b.kind.priority) {
      // A higher priority indicates a higher relevance
      // and should be sorted before a lower priority.
      return b.kind.priority - a.kind.priority;
    }
    return a.change.message.compareTo(b.change.message);
  }
}

/// An object used to provide context information for [FixContributor]s.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FixContext {
  /// The error to fix.
  AnalysisError get error;
}

// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:kernel/ast.dart';

Set<Library> findAllReferencedLibraries(List<Library> from,
    {bool collectViaReferencesToo = false}) {
  _LibraryCollector collector =
      new _LibraryCollector(collectViaReferencesToo: collectViaReferencesToo);
  for (Library library in from) {
    collector.visitLibrary(library);
  }
  return collector.allSeenLibraries;
}

bool duplicateLibrariesReachable(List<Library> from) {
  Set<Uri> seenUris = {};
  for (Library lib in findAllReferencedLibraries(from)) {
    if (!seenUris.add(lib.importUri)) return true;
  }
  return false;
}

class _LibraryCollector extends RecursiveVisitor {
  final bool collectViaReferencesToo;
  Set<Library> allSeenLibraries = {};

  _LibraryCollector({required this.collectViaReferencesToo});

  @override
  void defaultNode(Node node) {
    if (node is NamedNode) {
      // Named nodes can be linked to.
      seen(node);
      if (collectViaReferencesToo) {
        TreeNode? refNode = node.reference.node;
        if (refNode != null && !identical(refNode, node)) {
          // This is generally pretty bad.
          seen(refNode);
        }
      }
    } else if (node is Name) {
      if (node.library != null) {
        seen(node.library!);
      }
    }
    super.defaultNode(node);
  }

  @override
  void defaultMemberReference(Member node) {
    seen(node);
    super.defaultMemberReference(node);
  }

  void seen(TreeNode node) {
    TreeNode? parent = node;
    while (parent != null && parent is! Library) {
      parent = parent.parent;
    }
    allSeenLibraries.add(parent as Library);
  }
}

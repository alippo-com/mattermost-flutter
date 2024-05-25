
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:commonmark/commonmark.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/types.dart';

/* eslint-disable no-underscore-dangle */

final cjkPattern = RegExp(r'[\u3000-\u303f\u3040-\u309f\u30a0-\u30ff\uff00-\uff9f\u4e00-\u9faf\u3400-\u4dbf\uac00-\ud7a3]');

List<Node> combineTextNodes(List<Node> ast) {
  var walker = ast.walker();
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if (node.type != NodeType.text) continue;

    while (node.next != null && node.next.type == NodeType.text) {
      var next = node.next;
      node.literal += next.literal;
      node.next = next.next;
      if (node.next != null) node.next.prev = node;
      if (node.parent.lastChild == next) node.parent.lastChild = node;
    }
    walker.resumeAt(node, false);
  }
  return ast;
}

List<Node> addListItemIndices(List<Node> ast) {
  var walker = ast.walker();
  Node node;

  while ((node = walker.next()) != null) {
    if (node.entering) {
      if (node.type == NodeType.list) {
        var i = node.listStart ?? 1;
        for (var child = node.firstChild; child != null; child = child.next) {
          child.index = i;
          i += 1;
        }
      }
    }
  }
  return ast;
}

List<Node> pullOutImages(List<Node> ast) {
  var walker = ast.walker();
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if (node.type == NodeType.table) {
      walker.resumeAt(node, false);
      continue;
    }

    if (node.type == NodeType.image && node.parent.type != NodeType.document) {
      pullOutImage(node);
    }
  }
  return ast;
}

void pullOutImage(Node image) {
  var parent = image.parent;
  if (parent.type == NodeType.link) {
    image.linkDestination = parent.destination;
  }
}

List<Node> highlightMentions(List<Node> ast, List<UserMentionKey> mentionKeys) {
  var walker = ast.walker();
  var patterns = mentionKeysToPatterns(mentionKeys);
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if (node.type == NodeType.text && node.literal != null) {
      var match = getFirstMatch(node.literal, patterns);
      if (match.index == -1) continue;
      var mentionNode = highlightTextNode(node, match.index, match.index + match.length, 'mention_highlight');
      walker.resumeAt(mentionNode, false);
    } else if (node.type == 'at_mention') {
      var matches = mentionKeys.any((mention) {
        var mentionName = '@' + node.mentionName;
        var pattern = RegExp(r'@' + escapeRegex(mention.key.replaceAll('@', '')) + r'\.?', caseSensitive: mention.caseSensitive);
        return pattern.hasMatch(mentionName);
      });
      if (!matches) continue;
      var wrapper = Node('mention_highlight');
      wrapNode(wrapper, node);
      walker.resumeAt(wrapper, false);
    }
  }
  return ast;
}

List<RegExp> mentionKeysToPatterns(List<UserMentionKey> mentionKeys) {
  return mentionKeys.where((mention) => mention.key.trim().isNotEmpty).map((mention) {
    var flags = mention.caseSensitive ? '' : 'i';
    var pattern;
    if (cjkPattern.hasMatch(mention.key)) {
      pattern = RegExp(escapeRegex(mention.key), caseSensitive: mention.caseSensitive);
    } else {
      pattern = RegExp(r'\b' + escapeRegex(mention.key) + r'(?=_*\b)', caseSensitive: mention.caseSensitive);
    }
    return pattern;
  }).toList();
}

List<Node> highlightWithoutNotification(List<Node> ast, List<HighlightWithoutNotificationKey> highlightKeys) {
  var walker = ast.walker();
  var patterns = highlightKeysToPatterns(highlightKeys);
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if (node.type == NodeType.text && node.literal != null) {
      var match = getFirstMatch(node.literal, patterns);
      if (match.index == -1) continue;
      var matchNode = highlightTextNode(node, match.index, match.index + match.length, 'highlight_without_notification');
      walker.resumeAt(matchNode, false);
    }
  }
  return ast;
}

List<RegExp> highlightKeysToPatterns(List<HighlightWithoutNotificationKey> highlightKeys) {
  if (highlightKeys.isEmpty) return [];
  return highlightKeys.where((highlight) => highlight.key.trim().isNotEmpty).map((highlight) {
    if (cjkPattern.hasMatch(highlight.key)) {
      return RegExp(escapeRegex(highlight.key), caseSensitive: false);
    }
    return RegExp(r'(^|\b)(' + escapeRegex(highlight.key) + r')(?=_*\b)', caseSensitive: false);
  }).toList();
}

List<Node> highlightSearchPatterns(List<Node> ast, List<SearchPattern> searchPatterns) {
  var walker = ast.walker();
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if ((node.type == NodeType.text || node.type == NodeType.code) && node.literal != null) {
      for (var pattern in searchPatterns) {
        var match = getFirstMatch(node.literal, [pattern.pattern]);
        if (match.index == -1) continue;
        var matchNode = highlightTextNode(node, match.index, match.index + match.length, 'search_highlight');
        walker.resumeAt(matchNode, false);
      }
    }
  }
  return ast;
}

Map<String, int> getFirstMatch(String str, List<RegExp> patterns) {
  var firstMatchIndex = -1;
  var firstMatchLength = -1;

  for (var pattern in patterns) {
    var match = pattern.firstMatch(str);
    if (match == null || match.group(0) == '') continue;
    if (firstMatchIndex == -1 || match.start < firstMatchIndex) {
      firstMatchIndex = match.start;
      firstMatchLength = match.group(0).length;
    }
  }
  return {'index': firstMatchIndex, 'length': firstMatchLength};
}

Node highlightTextNode(Node node, int start, int end, String type) {
  var literal = node.literal;
  node.literal = literal.substring(start, end);
  var highlighted = Node(type);
  wrapNode(highlighted, node);
  if (start != 0) {
    var before = Node(NodeType.text);
    before.literal = literal.substring(0, start);
    highlighted.insertBefore(before);
  }
  if (end != literal.length) {
    var after = Node(NodeType.text);
    after.literal = literal.substring(end);
    highlighted.insertAfter(after);
  }
  return highlighted;
}

void wrapNode(Node wrapper, Node node) {
  wrapper.parent = node.parent;
  if (node.parent.firstChild == node) {
    node.parent.firstChild = wrapper;
  }
  if (node.parent.lastChild == node) {
    node.parent.lastChild = wrapper;
  }

  wrapper.prev = node.prev;
  node.prev = null;
  if (wrapper.prev != null) {
    wrapper.prev.next = wrapper;
  }

  wrapper.next = node.next;
  node.next = null;
  if (wrapper.next != null) {
    wrapper.next.prev = wrapper;
  }

  wrapper.firstChild = node;
  wrapper.lastChild = node;
  node.parent = wrapper;
}

List<Node> parseTaskLists(List<Node> ast) {
  var walker = ast.walker();
  Node node;

  while ((node = walker.next()) != null) {
    if (!node.entering) continue;

    if (node.type != NodeType.item) continue;

    if (node.firstChild.type == NodeType.paragraph && node.firstChild.firstChild.type == NodeType.text) {
      var paragraphNode = node.firstChild;
      var textNode = node.firstChild.firstChild;
      var literal = textNode.literal ?? '';
      var match = RegExp(r'^ {0,3}\[( |x)\]\s').firstMatch(literal);
      if (match != null) {
        var checkbox = Node('checkbox');
        checkbox.isChecked = match.group(1) == 'x';
        paragraphNode.prependChild(checkbox);
        textNode.literal = literal.substring(match.end);
      }
    }
  }
  return ast;
}

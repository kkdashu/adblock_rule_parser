// Copyright (c) 2024. This code is licensed under MIT license (see LICENSE for details)

import 'url.dart';

/// The maximum number of patterns that compilePatterns() will compile into regular expressions
const int COMPILE_PATTERNS_MAX = 100;

/// Regular expression used to match the `^` suffix in an otherwise literal pattern
final RegExp separatorRegExp = RegExp(r'[\x00-\x24\x26-\x2C\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F]');

/// Regular expression for matching a keyword in a filter
final RegExp keywordRegExp = RegExp(r'[^a-z0-9%*][a-z0-9%]{2,}(?=[^a-z0-9%*])');

/// Regular expression for matching all keywords in a filter
final RegExp allKeywordsRegExp = RegExp(keywordRegExp.pattern, caseSensitive: true, multiLine: true);

/// Converts filter text into regular expression string
String filterToRegExp(String text) {
  // Remove multiple wildcards
  text = text.replaceAll(RegExp(r'\*+'), '*');

  // Remove leading wildcard
  if (text.startsWith('*')) {
    text = text.substring(1);
  }

  // Remove trailing wildcard
  if (text.endsWith('*')) {
    text = text.substring(0, text.length - 1);
  }

  return text
    // Remove anchors following separator placeholder
    .replaceAll(RegExp(r'\^\|$'), '^')
    // Escape special symbols
    .replaceAll(RegExp(r'[^\w\-\*]'), r'\$&')
    // Replace wildcards by .*
    .replaceAll(r'\*', '.*')
    // Process separator placeholders
    .replaceAll(r'\^', r'(?:${separatorRegExp.pattern}|\$)')
    // Process extended anchor at expression start
    .replaceAll(r'^\\\|\\\|', r'^[\w\-]+:\/+(?:[^\/]+\.)?')
    // Process anchor at expression start
    .replaceAll(r'^\\\|', '^')
    // Process anchor at expression end
    .replaceAll(r'\\\|$', r'$');
}

/// A Pattern represents a URL pattern that can be either a regular expression or a literal string
class Pattern {
  final String pattern;
  final bool matchCase;
  RegExp? _regexp;
  String? _regexpSource;
  bool? _isLiteralPattern;

  Pattern(this.pattern, this.matchCase) {
    _init();
  }

  void _init() {
    if (pattern.isEmpty) {
      _isLiteralPattern = true;
      _regexpSource = '';
      return;
    }

    // Check for literal pattern with optional extended anchor prefix and separator suffix
    _isLiteralPattern = !RegExp(r'[*^|]').hasMatch(pattern) ||
        (pattern.startsWith('||') && !RegExp(r'[*^|]').hasMatch(pattern.substring(2))) ||
        (pattern.endsWith('^') && !RegExp(r'[*^|]').hasMatch(pattern.substring(0, pattern.length - 1)));

    if (_isLiteralPattern!) {
      _regexpSource = pattern;
    } else {
      _regexpSource = filterToRegExp(pattern);
      try {
        _regexp = RegExp(_regexpSource!, caseSensitive: matchCase, multiLine: true);
      } catch (e) {
        // If regexp creation fails, treat it as a literal pattern
        _isLiteralPattern = true;
        _regexpSource = pattern;
      }
    }
  }

  /// Regular expression to be used when testing against this pattern
  RegExp? get regexp => _regexp;

  /// Pattern in regular expression notation
  String get regexpSource => _regexpSource ?? '';

  /// Checks whether the pattern is a literal string
  bool get isLiteralPattern => _isLiteralPattern ?? false;

  /// Checks whether the given URL request matches this pattern
  bool matchesLocation(URLRequest request) {
    String location = request.location;
    String locationToMatch = matchCase ? location : request.locationLowerCase;
    
    if (isLiteralPattern) {
      String patternToMatch = matchCase ? pattern : pattern.toLowerCase();
      
      if (pattern.startsWith('||')) {
        patternToMatch = pattern.substring(2);
        String patternLower = patternToMatch.toLowerCase();
        
        // The pattern must match at a domain boundary
        int pos = locationToMatch.indexOf(patternLower);
        if (pos == -1) return false;
        
        // Check if the match is preceded by a domain boundary
        if (pos > 0) {
          String preceding = locationToMatch.substring(0, pos);
          if (!preceding.endsWith('://') && !preceding.endsWith('.')) {
            return false;
          }
        }
        return true;
      }
      
      if (pattern.startsWith('|')) {
        patternToMatch = patternToMatch.substring(1);
        return locationToMatch.startsWith(patternToMatch);
      }
      
      if (pattern.endsWith('|')) {
        patternToMatch = patternToMatch.substring(0, patternToMatch.length - 1);
        return locationToMatch.endsWith(patternToMatch);
      }
      
      if (pattern.endsWith('^')) {
        patternToMatch = patternToMatch.substring(0, patternToMatch.length - 1);
        if (!locationToMatch.contains(patternToMatch)) return false;
        
        int pos = locationToMatch.indexOf(patternToMatch) + patternToMatch.length;
        if (pos >= locationToMatch.length) return true;
        
        return separatorRegExp.hasMatch(locationToMatch[pos]);
      }
      
      return locationToMatch.contains(patternToMatch);
    }
    
    return _regexp?.hasMatch(locationToMatch) ?? false;
  }

  /// Checks whether the pattern has keywords
  bool hasKeywords() => keywordRegExp.hasMatch(pattern.toLowerCase());

  /// Finds all keywords that could be associated with this pattern
  List<String> keywordCandidates() {
    List<String> candidates = [];
    String text = pattern.toLowerCase();
    
    for (Match match in allKeywordsRegExp.allMatches(text)) {
      String keyword = text.substring(match.start + 1, match.end);
      if (!candidates.contains(keyword)) {
        candidates.add(keyword);
      }
    }
    
    return candidates;
  }
}

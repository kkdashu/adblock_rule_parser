// Copyright (c) 2024. This code is licensed under MIT license (see LICENSE for details)

import 'package:adblock_rule_parser/src/filters/index.dart';

import 'content_types.dart';
import 'patterns.dart';
import 'url.dart';

/// Regular expression for matching content filters
final RegExp contentFilterRegExp = RegExp(r'^([^/|@"!]*?)#([@?$])?#(.+)$');

/// Regular expression for matching snippet filters
final RegExp snippetFilterRegExp = RegExp(r'^([^#]*)#\$#(.+)$');


const MIN_GENERIC_CONTENT_FILTER_BODY_LENGTH = 3;

bool isActiveFilter(Filter filter) {
  return filter is ActiveFilter;
}

/// Abstract base class for filters
abstract class Filter {
  /// String representation of the filter
  final String text;
  
  // /// Source of the domains
  // String? domainSource;
  // 
  // /// Map containing domains that this filter should match on/not match
  // Map<String, bool>? _domains;
  Filter(this.text);

  // Filter(this.text, [this.domainSource]) {
  //   if (domainSource != null && domainSource!.isNotEmpty) {
  //     _domains = parseDomains(domainSource!);
  //   }
  // }

  /// Filter type as a string, e.g. "blocking"
  String get type;

  /// True if filter should only be loaded if it comes from a privileged subscription
  bool get requiresPrivilegedSubscription => false;

  /// Creates a filter from filter text
  static Filter fromText(String text) {
    throw UnimplementedError();
    // Normalize the text by removing unnecessary whitespace
    // text = text.trim();
    // 
    // // Check for empty text
    // if (text.isEmpty) {
    //   throw FilterParsingException('filter_empty', {'text': text});
    // }

    // // Check for comments
    // if (text.startsWith('!')) {
    //   return CommentFilter(text);
    // }

    // // Check for snippet filters
    // Match? snippetMatch = snippetFilterRegExp.firstMatch(text);
    // if (snippetMatch != null) {
    //   String domains = snippetMatch.group(1) ?? '';
    //   String body = snippetMatch.group(2) ?? '';
    //   return SnippetFilter(text, domains, body);
    // }

    // // Check for content filters
    // if (contentFilterRegExp.hasMatch(text)) {
    //   return CommentFilter(text); // For now, treat as comment
    // }


    // bool blocking = true;
    // String origText = text;
    // 
    // // Check for allowing filters
    // if (text.startsWith('@@')) {
    //   blocking = false;
    //   text = text.substring(2);
    // }

    // int contentType = ContentType.OTHER.v;
    // bool matchCase = false;
    // String? domains;
    // List<String>? sitekeys;
    // bool thirdParty = false;
    // String? csp;
    // String? rewrite;
    // Map<String, String>? headers;

    // // Parse options
    // Match? match = text.contains('\$') ? filterOptionsRegExp.firstMatch(text) : null;
    // if (match != null) {
    //   String options = match[1]!;
    //   text = text.substring(0, match.start);

    //   for (String option in options.split(',')) {
    //     String value = '';
    //     bool inverse = false;
    //     
    //     // Check for option value
    //     int separatorIndex = option.indexOf('=');
    //     if (separatorIndex >= 0) {
    //       value = option.substring(separatorIndex + 1);
    //       option = option.substring(0, separatorIndex);
    //     }

    //     // Check for inverse option
    //     if (option.startsWith('~')) {
    //       inverse = true;
    //       option = option.substring(1);
    //     }

    //     String optionUpperCase = option.toUpperCase();
    //     int? type = contentTypeFromText(optionUpperCase.replaceAll('-', '_'));

    //     if (type != null) {
    //       if (inverse) {
    //         contentType &= ~type;
    //       } else if (type == ContentType.CSP) {
    //         if (blocking && value.isEmpty) {
    //           throw FilterParsingError('filter_invalid_csp', {'text': origText});
    //         }
    //         csp = value;
    //       } else {
    //         contentType |= type;
    //       }
    //     } else {
    //       switch (option.toLowerCase()) {
    //         case 'match-case':
    //           matchCase = true;
    //           break;
    //         case 'domain':
    //           domains = value;
    //           break;
    //         case 'third-party':
    //         case 'thirdparty':
    //           thirdParty = !inverse;
    //           break;
    //         case 'sitekey':
    //           if (value.isNotEmpty) {
    //             sitekeys = value.split('|');
    //           }
    //           break;
    //         case 'rewrite':
    //           if (value.isNotEmpty) {
    //             rewrite = value;
    //           }
    //           break;
    //         default:
    //           throw FilterParsingError('filter_unknown_option', 
    //             {'text': origText, 'option': option});
    //       }
    //     }
    //   }
    // }

    // // Create the appropriate filter
    // try {
    //   if (blocking) {
    //     return BlockingFilter(
    //       origText,
    //       text,
    //       contentType,
    //       matchCase,
    //       domains,
    //       thirdParty,
    //       sitekeys,
    //       headers,
    //       rewrite,
    //       csp
    //     );
    //   } else {
    //     return AllowingFilter(
    //       origText,
    //       text,
    //       contentType,
    //       matchCase,
    //       domains,
    //       thirdParty,
    //       sitekeys,
    //       headers,
    //       rewrite
    //     );
    //   }
    // } catch (e) {
    //   throw FilterParsingError('filter_invalid_regexp', 
    //     {'text': origText, 'regexp': text});
    // }
  }

  @override
  String toString() {
    var props = {
      'text': text,
      // 'domainSource': domainSource,
      // '_domains': _domains,
    };
    return '${runtimeType} ${props.toString()}';
  }
}

final knownFilters = Map<String, Filter>();

/// Class for invalid filters
class InvalidFilter extends Filter {
  final String reason;
  final String? option;

  InvalidFilter(String text, this.reason, [this.option]) : super(text);

  @override
  String get type => 'invalid';

  @override
  String toString() {
    var props = {
      'text': text,
      'reason': reason,
      if (option != null) 'option': option,
    };
    return '${runtimeType} ${props.toString()}';
  }
}

/// Class for comment filters
class CommentFilter extends Filter {
  CommentFilter(String text) : super(text);

  @override
  String get type => 'comment';

  @override
  String toString() => '${runtimeType} { text: \'$text\' }';
}

/// Class for snippet filters
// class SnippetFilter extends Filter {
//   final String body;
// 
//   SnippetFilter(String text, String domains, this.body) : super(text, domains);
// 
//   @override
//   String get type => 'snippet';
// 
//   @override
//   String toString() {
//     return '${runtimeType} { text: \'$text\', domainSource: \'$domainSource\', _domains: ${_domains}, body: \'$body\' }';
//   }
// }

/// Abstract base class for filters that can get hits
abstract class ActiveFilter extends Filter {
  Set<String>? _disabledSubscriptions;
  int _hitCount = 0;
  int _lastHit = 0;
  List<String>? _sitekeys;
  String? _sitekeySource;
  final String domainSource;

  Map<String, bool> _domains = {};

  ActiveFilter(String text, String? domains) : domainSource = domains ?? '', _domains = parseDomains(domains ?? '', ','), super(text) ;

  /// Number of hits on the filter since the last reset
  int get hitCount => _hitCount;
  set hitCount(int value) => _hitCount = value;

  /// Last time the filter had a hit (in milliseconds since epoch)
  int get lastHit => _lastHit;
  set lastHit(int value) => _lastHit = value;

  /// Array containing public keys of websites that this filter should apply to
  List<String>? get sitekeys => _sitekeys;

  /// Checks whether this filter is active on a domain
  bool isActiveOnDomain(String? docDomain, [String? sitekey]) {
    if (_domains.isEmpty && _sitekeys == null) {
      return true;
    }

    if (docDomain != null && _domains.isNotEmpty) {
      var suffixes = getDomainSuffixes(docDomain);
      for (var domain in suffixes) {
        if (_domains.containsKey(domain)) {
          return _domains[domain]!;
        }
      }
    }

    if (sitekey != null && _sitekeys != null) {
      return _sitekeys!.contains(sitekey);
    }

    return _domains.isEmpty;
  }

  /// Checks whether this filter is active only on a domain and its subdomains
  bool isActiveOnlyOnDomain(String docDomain) {
    if (_domains.isEmpty) {
      return false;
    }

    var suffixes = getDomainSuffixes(docDomain);
    for (var domain in suffixes) {
      if (_domains.containsKey(domain)) {
        return _domains[domain]!;
      }
    }

    return false;
  }

  /// Checks whether this filter is generic or specific
  bool isGeneric() => _domains.isEmpty && _sitekeys == null;
}

/// Class for URL filters
abstract class URLFilter extends ActiveFilter {
  final Pattern urlPattern;
  final ContentType contentType;
  final bool matchCase;
  final bool thirdParty;
  final Map<String, String>? headers;
  final String? rewrite;

  URLFilter({
    required String text,
    required String regexpSource,
    this.contentType = ContentType.RESOURCE,
    this.matchCase = false,
    String? domains,
    this.thirdParty = false,
    List<String>? sitekeys,
    this.headers,
    this.rewrite,
  }) : urlPattern = Pattern(regexpSource, matchCase),
      super(text, domains) {
      _sitekeys = sitekeys;
  }

  /// Tests whether the URL request matches this filter
  bool matches(URLRequest request, ContentType typeMask, [String? sitekey]) {
    final contextMask = typeMask.v & ContentType.CONTEXT_TYPES.v;
    final resourceMask = typeMask.v & ~ContentType.CONTEXT_TYPES.v;
    if ((resourceMask & contentType.v) == 0) {
      return false;
    }

    if (!isActiveOnDomain(request.documentDomain, sitekey)) {
      return false;
    }

    if (thirdParty && request.documentDomain != null) {
      bool isThirdPartyRequest = isThirdParty(request.location, request.documentDomain!);
      if (isThirdPartyRequest != thirdParty) {
        return false;
      }
    }

    return urlPattern.matchesLocation(request);
  }

  String get pattern => urlPattern.pattern;

  RegExp? get regexp => urlPattern.regexp;


  @override
  String toString() {
    var props = {
      'text': text,
      'domainSource': domainSource,
      '_domains': _domains,
      '_sitekeySource': _sitekeySource,
      '_sitekeys': _sitekeys,
      'contentType': contentType,
      'thirdParty': thirdParty,
      'header': headers,
      'rewrite': rewrite,
      'urlPattern': urlPattern,
    };
    return '${runtimeType} ${props.toString()}';
  }
}

/// Class for blocking filters
class BlockingFilter extends URLFilter {
  BlockingFilter({
    required super.text,
    required super.regexpSource,
    super.contentType = ContentType.RESOURCE,
    super.matchCase = false,
    super.domains,
    super.thirdParty = false,
    super.sitekeys,
    super.headers,
    super.rewrite,
    this.csp,
  });

  final String? csp;

  @override
  String get type => 'blocking';

  @override
  bool get requiresPrivilegedSubscription =>
      (contentType.v & ContentType.HEADER.v) != 0;

  /// Rewrites a URL
  /// @TODO: Implement
  String rewriteUrl(String url) {
    if (rewrite == null) {
      return url;
    }
    return rewrite!;
  }

  // @TODO: Implement
  bool filterHeaders(Map<String, dynamic> headers) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    var props = {
      'text': text,
      'domainSource': domainSource,
      '_domains': _domains,
      '_sitekeySource': _sitekeySource,
      '_sitekeys': _sitekeys,
      'contentType': contentType,
      'thirdParty': thirdParty,
      'header': headers,
      'rewrite': rewrite,
      'urlPattern': 'Pattern { matchCase: $matchCase, pattern: \'$text\' }',
      'csp': csp,
    };
    return '${runtimeType} ${props.toString()}';
  }
}

/// Class for allowing (allowlisting) filters
class AllowingFilter extends URLFilter {
  AllowingFilter({
    required super.text,
    required super.regexpSource,
    super.contentType,
    super.matchCase,
    super.domains,
    super.thirdParty,
    super.sitekeys,
    super.headers,
    super.rewrite,
  });

  @override
  String get type => 'allowing';
}

///
/// [How-to-write-filters](https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters)
///

import 'package:adblock_rule_parser/src/error.dart';
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

final knownFilters = Map<String, Filter>();
/// Abstract base class for filters
abstract class Filter {
  /// String representation of the filter
  final String text;

  
  // /// Source of the domains
  // String? domainSource;
  // 
  // /// Map containing domains that this filter should match on/not match
  // Map<String, bool>? _domains;
  Filter._(this.text);

  /// Filter type as a string, e.g. "blocking"
  String get type;

  /// True if filter should only be loaded if it comes from a privileged subscription
  bool get requiresPrivilegedSubscription => false;

  /// Creates a filter from filter text
  factory Filter.fromText(String text) {
    final knownFilter = knownFilters[text];
    if (knownFilter != null) {
      return knownFilter;
    }
    if (text.isEmpty) {
      throw ParseFilterException("empty_filter");
    }
    if (text[0] == "!") {
      return CommentFilter(text);
    } else {
      final match = text.contains('#') ? contentFilterRegExp.firstMatch(text) : null;
      if (match != null) {
        final domain = match.group(1) ?? '';
        final type = match.group(2) ?? '';
        final body = match.group(3) ?? '';
        return ContentFilter.fromText(text: text, domains: domain, type: type, body: body);
      } else {
        return URLFilter.fromText(text);
      }
    }
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


/// Class for comment filters
class CommentFilter extends Filter {
  CommentFilter(String text) : super._(text);

  @override
  String get type => 'comment';

  @override
  String toString() => '${runtimeType} { text: \'$text\' }';
}

/// Abstract base class for filters that can get hits
abstract class ActiveFilter extends Filter {
  Set<String>? _disabledSubscriptions;
  int _hitCount = 0;
  int _lastHit = 0;
  List<String>? _sitekeys;
  String? _sitekeySource;
  final String domainSource;

  Map<String, bool> _domains = {};

  ActiveFilter(String text, String? domains) : domainSource = domains ?? '', _domains = parseDomains(domains ?? '', ','), super._(text) ;

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

  factory URLFilter.fromText(String txt) {
    final result = parseFilter(txt);
    final ParsedFilter(
      :domains,
      :blocking,
      :text,
      :csp,
      :header,
      :rewrite,
      :siteKeys,
      :matchCase,
      :thirdParty,
      :contentType,
      :regexpSource
    ) = result;
    if (blocking) {
      return BlockingFilter(
        text: text,
        regexpSource: regexpSource,
        contentType: contentType,
        matchCase: matchCase,
        domains: domains,
        thirdParty: thirdParty,
        sitekeys: siteKeys.split(','),
        headers: header,
        rewrite: rewrite,
        csp: csp,
      );
    }
    return AllowingFilter(
      text: text,
      regexpSource: regexpSource,
      contentType: contentType,
      matchCase: matchCase,
      domains: domains,
      thirdParty: thirdParty,
      sitekeys: siteKeys.split(','),
      headers: header,
      rewrite: rewrite,
    );
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
      'urlPattern': urlPattern,
    };
    return '${runtimeType} ${props.toString()}';
  }
}

/// Class for blocking filters
/// Applied on the network level to decide whether a request should be blocked.
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

/// https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters#content-filters
/// 一般格式是 <domains><separator><body>
/// 分隔符不同对应不同的 ContentFilter
/// ##	Element hiding	CSS selector (domains may be empty) // ElementHideFilter
/// #?#	Element hiding emulation	Extended CSS selector     // ElemHideEmulationFilter
/// #@#	Element hiding exception	Selector                  // ElementHideExceptionFilter
/// #$#	Snippet filter	Snippet                             // SnippetFilter
abstract class ContentFilter extends ActiveFilter {
  // body 一般是用于指定隐藏内容的CSS样式
  final String body;
  ContentFilter(
    super.text,
    super.domains,
    this.body,
  );

  factory ContentFilter.fromText({
    required String text,
    required String domains,
    required String type,
    required String body
  }) {
    if (domains.isNotEmpty && RegExp(r'(^|,)~?(,|$)').hasMatch(domains)) {
      return InvalidContentFilter(text, domains, body);
    }

    final restrictedByDomain = (RegExp(r',[^~][^,.]*\.[^,]').hasMatch("," + domains) ||
      ("," + domains + ",").contains(",localhost,"));

    if (type == "?" || type == "\$") {
      // Element hiding emulation and snippet filters are inefficient so we need
      // to make sure that they're only applied if they specify active domains
      if (!restrictedByDomain) {
        return InvalidContentFilter(text, domains, body);
      }

      if (type == "?") {
        return ElemHideEmulationFilter(text, domains, body);
      }

      return SnippetFilter(text, domains, body);
    }

    if (!restrictedByDomain && body.length < MIN_GENERIC_CONTENT_FILTER_BODY_LENGTH) {
      return InvalidContentFilter(text, domains, body);
    }

    if (type == "@") {
      return ElemHideExceptionFilter(text, domains, body);
    }

    return ElementHideFilter(text, domains, body);
  }
}

class InvalidContentFilter extends ContentFilter {
  InvalidContentFilter(super.text, super.domains, super.body);

  @override
  String get type => "invalid";
}

class ElementHideFilter extends ContentFilter {
  ElementHideFilter(super.text, super.domains, super.body);

  String get selector => body;

  @override
  String get type => "elemhide";
}

class ElemHideExceptionFilter extends ContentFilter {
  ElemHideExceptionFilter(super.text, super.domains, super.body);

  @override
  String get type => "elemhideexception";
}

class ElemHideEmulationFilter extends ContentFilter {
  ElemHideEmulationFilter(super.text, super.domains, super.body);

  String get selector => body;

  @override
  String get type => "elemhide_emulation";
}

class SnippetFilter extends ContentFilter {
  SnippetFilter(super.text, super.domains, super.body);

  String get type => "snippet";

  bool get requiresPrivilegedSubscription => true;

  /// SnippetFilter 需要执行的脚本代码
  String get script => body;
}


import 'package:adblock_rule_parser/src/content_types.dart';
import 'package:adblock_rule_parser/src/error.dart';

/// Regular expression that content filters should match
final contentFilterRegExp = RegExp(r'^([^/|@"!]*?)#([@?$])?#(.+)$');

/// Regular expression that options on a RegExp filter should match
/// match $key1=value1,key2=value2
final filterOptionsRegExp = RegExp(r'\$(~?[\w-]+(?:=[^,]*)?(?:,~?[\w-]+(?:=[^,]*)?)*)$');

/// used to reduce possible short filters damage
final minGenericURLFilterPatternLength = 4;

/// Regular expression that matches an invalid Content Security Policy
final invalidCSPRegExp = RegExp(r'(;|^) ?(base-uri|referrer|report-to|report-uri|upgrade-insecure-requests)\b', caseSensitive: false);

class ParsedFilter {
  final bool blocking;
  final String text;
  final String regexpSource;
  final ContentType contentType;
  final bool matchCase;
  final String domains;
  final bool thirdParty;
  final String siteKeys;
  final Map<String, String> header;
  final String rewrite;
  final String csp;
  ParsedFilter({
    required this.blocking,
    required this.text,
    required this.regexpSource,
    required this.contentType,
    required this.matchCase,
    required this.domains,
    required this.thirdParty,
    required this.siteKeys,
    required this.header,
    required this.rewrite,
    required this.csp,
  });

  @override
  String toString() {
    var props = {
      'blocking': blocking,
      'text': text,
      'regexpSource': regexpSource,
      'contentType': contentType,
      'matchCase': matchCase,
      'domains': domains,
      'thirdParty': thirdParty,
      'siteKeys': siteKeys,
      'header': header,
      'rewrite': rewrite,
      'csp': csp,
    };
    return '${runtimeType} ${props.toString()}';
  }
}


ParsedFilter parseFilter(String text) {
  if (text.isEmpty) {
    throw ParseFilterException('filter_empty');
  }
  if (text[0] == "!" || contentFilterRegExp.hasMatch(text)) {
    throw ParseFilterException('filter_invalid');
  }
  var blocking = true;
  int? contentType = null;
  bool matchCase = false;
  String domains = "";
  bool thirdParty = false;
  String csp = "";
  String siteKeys = "";
  String rewrite = "";
  Map<String, String> header = {};
  final origText = text;
  if (text.startsWith("@@")) {
    blocking = false;
    text = text.substring(2);
  }
  final match = text.contains("\$") ? filterOptionsRegExp.firstMatch(text) : null;
  if (match != null) {
    text = match.input.substring(0, match.start);
    final options = match[1]?.split(',') ?? [];
    var cspSet = false;
    var headerSet = false;
    for (var option in options) {
      final separatorIndex = option.indexOf('=');
      String? value = null;
      if (separatorIndex >= 0) {
        value = option.substring(separatorIndex + 1);
        option = option.substring(0, separatorIndex);
      }
      var inverse = option[0] == "~";
      if (inverse) {
        option = option.substring(1);
      }
      var optionUpperCase = option.toUpperCase();
      var type = ContentType.fromText(optionUpperCase.replaceAll('-', '_'));
      if (type != null) {
        if (inverse) {
          if (contentType == null) {
            contentType = ContentType.RESOURCE.v;
          }
          contentType = contentType &= ~type.v;
        } else if (type == ContentType.CSP) {
          if (blocking && (value == null || value.isEmpty)) {
            throw ParseFilterException("filter_invalid_csp");
          }
          cspSet = true;
          csp = value ?? "";
        } else if (type == ContentType.HEADER) {
          if (blocking && (value == null || value.isEmpty)) {
            throw ParseFilterException("filter_invalid_header");
          }
          headerSet = true;
          if (value != null && value.isNotEmpty) {
            // @TODO add support for headers
          }
        } else {
          if (contentType != null) {
            contentType |= type.v;
          }
        }
      } else {
        switch (optionUpperCase) {
          case "MATCH-CASE":
            matchCase = !inverse;
            break;
          case "DOMAIN":
            if (value == null || value.isEmpty) {
              throw ParseFilterException("filter_unknown_option");
            } else {
              domains = value;
            }
            break;
          case "THIRD-PARTY":
              thirdParty = !inverse;
            break;
          case "SITEKEY":
            if (value == null || value.isEmpty) {
              throw ParseFilterException("filter_unknown_option");
            } else {
              siteKeys = value;
            }
            break;
          case "REWRITE":
            if (value == null || value.isEmpty) {
              throw ParseFilterException("filter_unknown_option");
            }
            if (!value.startsWith("abp-resource:")) {
              throw ParseFilterException("filter_invalid_rewrite");
            }
            rewrite = value.substring("abp-resource:".length);
            break;
        }
      }
    }
    if (cspSet || headerSet) {
      if (contentType == null) {
        contentType = ContentType.RESOURCE.v;
      }
      if (cspSet) {
        contentType |= ContentType.CSP.v;
      }
      if (headerSet) {
        //@TODO set contentType to HEADER
        contentType |= ContentType.HEADER.v;
      }
    }
  }
  var isGeneric = siteKeys.isNotEmpty && domains.isNotEmpty;
  if (isGeneric) {
    var minTextLength = minGenericURLFilterPatternLength;
    final length = text.length;
    if (length > 0 && text[0] == "|") {
      minTextLength++;
      if (length > 1 && text[1] == "|") {
        minTextLength++;
      }
    }
    if (length < minTextLength && !text.contains("*")) {
      throw ParseFilterException("filter_url_not_specific_enough");
    }
  } else if (domains.isNotEmpty && RegExp(r"[^\x00-\x7F]").hasMatch(domains)) {
    throw ParseFilterException("filter_invalid_domain");
  }
  if (blocking) {
    if (csp.isNotEmpty && invalidCSPRegExp.hasMatch(csp)) {
      throw ParseFilterException("filter_invalid_csp");
    }
    if (rewrite.isNotEmpty) {
      if (text.startsWith("||")) {
        if (domains.isEmpty && thirdParty != false) {
          throw ParseFilterException("filter_invalid_rewrite");
        }
      } else if (text.startsWith("*")) {
        if (domains.isEmpty) {
          throw ParseFilterException("filter_invalid_rewrite");
        }
      } else {
          throw ParseFilterException("filter_invalid_rewrite");
      }
    }
  }
  if (contentType == null) {
    contentType = ContentType.OTHER.v;
  }
  return ParsedFilter(
    blocking: blocking,
    text: origText,
    regexpSource: text,
    contentType: ContentType.fromInt(contentType) ?? ContentType.OTHER,
    matchCase: matchCase,
    domains: domains,
    thirdParty: thirdParty,
    siteKeys: siteKeys,
    header: header,
    rewrite: rewrite,
    csp: csp
  );
  
}

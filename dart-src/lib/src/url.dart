// Copyright (c) 2024. This code is licensed under MIT license (see LICENSE for details)

/// A class representing a URL request
class URLRequest {
  final String location;
  final String locationLowerCase;
  final String? documentDomain;

  URLRequest(this.location, this.documentDomain)
      : locationLowerCase = location.toLowerCase();
}

/// Parses the domains string and returns a map of domain to include/exclude
Map<String, bool> parseDomains(String domains, String separator) {
  Map<String, bool> result = {};

  for (String domain in domains.split(separator)) {
    if (domain.isEmpty) continue;

    bool include = true;
    if (domain.startsWith('~')) {
      include = false;
      domain = domain.substring(1);
    }

    result[domain.toLowerCase()] = include;
  }

  return result;
}

/// Gets all relevant domain suffixes for a domain
List<String> getDomainSuffixes(String domain) {
  List<String> result = [];
  domain = domain.toLowerCase();
  
  while (domain.contains('.')) {
    result.add(domain);
    domain = domain.substring(domain.indexOf('.') + 1);
  }
  result.add(domain);
  
  return result;
}

/// Checks if a URL is third-party relative to a domain
bool isThirdParty(String url, String documentDomain) {
  String domain = extractDomain(url);
  documentDomain = documentDomain.toLowerCase();
  
  if (domain.isEmpty) {
    return true;
  }
  
  if (domain == documentDomain) {
    return false;
  }
  
  return !documentDomain.endsWith('.$domain') && !domain.endsWith('.$documentDomain');
}

/// Extracts the domain from a URL
String extractDomain(String url) {
  try {
    Uri uri = Uri.parse(url);
    var host = uri.host;
    
    if (host.isEmpty) {
      return '';
    }
    
    // Remove username/password
    if (host.contains('@')) {
      host = host.substring(host.lastIndexOf('@') + 1);
    }
    
    // Remove port
    if (host.contains(':')) {
      host = host.substring(0, host.indexOf(':'));
    }
    
    return host.toLowerCase();
  } catch (e) {
    return '';
  }
}

/// Map of internal resources for URL rewriting
final Map<String, String> resourceMap = {
  'blank-html': 'about:blank',
  'blank-js': 'data:application/javascript,',
  'blank-css': 'data:text/css,',
  'blank-mp3': 'data:audio/mpeg;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4LjIwLjEwMAAAAAAAAAAAAAAA//tUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWGluZwAAAA8AAAACAAABwABgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBg//////////////////////////////////////////////////////////////////8AAAAATGF2YzU4LjM1AAAAAAAAAAAAAAAAJAYAAAAAAAAAAfA/J0HqAAAAAAD/+1DEARMA/wBNAGQAAAEDAABgAAAAAExBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZCQAEyAD0gBhoAAAAA0g4AAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZEYAEyADUgBhoAAAAA0gAAAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZGQAEyADUgBhoAAAAA0gAAAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZIQAEyADUgBhoAAAAA0gAAAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZKIAEyADUgBhoAAAAA0gAAAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//tUZMAAEyADUgBhoAAAAA0gAAAAAVYQ1IYYwAAAADSDAAAAVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV',
  'blank-txt': 'data:text/plain,',
  'tracking-pixel': 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==',
  '1x1-transparent-gif': 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
};

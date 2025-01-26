# AdBlock Rule Parser

A Dart implementation of AdBlock filter rules parser, ported from the original JavaScript implementation.

## Features

- Parse AdBlock filter rules
- Support for various filter types:
  - Blocking filters
  - Allowing (whitelist) filters
  - Element hiding filters
  - Comment filters
- URL pattern matching with support for wildcards and regular expressions
- Domain-specific filtering
- Content type filtering

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  adblock_rule_parser: ^1.0.0
```

## Usage

```dart
import 'package:adblock_rule_parser/adblock_rule_parser.dart';

void main() {
  // Create a blocking filter
  var filter = BlockingFilter(
    '||example.com/ads/*',  // filter text
    'example.com/ads/*',    // regexp source
    ContentType.ALL,        // content type
    false,                  // match case
    null,                   // domains
    false,                  // third party
    null,                   // sitekeys
    null,                   // headers
    null,                   // rewrite
    null                    // csp
  );

  // Create a URL request
  var request = URLRequest(
    'https://example.com/ads/banner.jpg',
    'example.com'
  );

  // Check if the request matches the filter
  bool matches = filter.matches(
    request,
    ContentType.IMAGE,
    null  // sitekey
  );

  print(matches);  // true
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

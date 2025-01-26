import 'package:test/test.dart';
import 'package:adblock_rule_parser/adblock_rule_parser.dart';

void main() {
  group('Filter Creation Tests', () {
    test('Create from text - basic blocking filter', () {
      var filter = Filter.fromText('||ads.example.com^');
      expect(filter, isA<BlockingFilter>());
      expect(filter.text, '||ads.example.com^');
      
      var blockingFilter = filter as BlockingFilter;
      expect(blockingFilter.contentType, ContentType.ALL);
      expect(blockingFilter.matchCase, false);
      expect(blockingFilter.thirdParty, false);
    });

    test('Create from text - allowing filter', () {
      var filter = Filter.fromText('@@||example.com/ads');
      expect(filter, isA<AllowingFilter>());
      expect(filter.text, '@@||example.com/ads');
    });

    test('Create from text - with options', () {
      var filter = Filter.fromText('||ads.com^$domain=example.com,image,match-case');
      expect(filter, isA<BlockingFilter>());
      
      var blockingFilter = filter as BlockingFilter;
      expect(blockingFilter.contentType, ContentType.IMAGE);
      expect(blockingFilter.matchCase, true);
      expect(blockingFilter.domains, isNotNull);
    });

    test('Create from text - comment', () {
      var filter = Filter.fromText('! This is a comment');
      expect(filter, isA<CommentFilter>());
      expect(filter.text, '! This is a comment');
    });

    test('Create from text - invalid filter', () {
      expect(() => Filter.fromText(''), throwsA(isA<FilterParsingError>()));
      expect(() => Filter.fromText('||ads.com^$unknown'),
        throwsA(isA<FilterParsingError>()));
    });
  });

  group('URL Pattern Tests', () {
    test('Basic pattern matching', () {
      var pattern = Pattern('ads/*', false);
      
      expect(pattern.isLiteralPattern, false);
      expect(pattern.hasKeywords(), true);
      
      var request = URLRequest('https://example.com/ads/banner.jpg', 'example.com');
      expect(pattern.matchesLocation(request), true);
      
      request = URLRequest('https://example.com/not-ads/banner.jpg', 'example.com');
      expect(pattern.matchesLocation(request), false);
    });

    test('Domain anchor pattern', () {
      var pattern = Pattern('||example.com', false);
      
      var request = URLRequest('https://example.com/page', 'example.com');
      expect(pattern.matchesLocation(request), true);
      
      request = URLRequest('https://sub.example.com/page', 'example.com');
      expect(pattern.matchesLocation(request), true);
      
      request = URLRequest('https://notexample.com/page', 'notexample.com');
      expect(pattern.matchesLocation(request), false);
    });

    test('Start anchor pattern', () {
      var pattern = Pattern('|http://example.com', false);
      
      var request = URLRequest('http://example.com/page', 'example.com');
      expect(pattern.matchesLocation(request), true);
      
      request = URLRequest('https://example.com/page', 'example.com');
      expect(pattern.matchesLocation(request), false);
    });
  });

  group('Filter Tests', () {
    test('Blocking filter', () {
      var filter = BlockingFilter(
        '||ads.example.com^',
        'ads.example.com^',
        ContentType.ALL,
        false,
        null,
        false,
        null,
        null,
        null,
        null
      );

      var request = URLRequest('https://ads.example.com/banner', 'example.com');
      expect(filter.matches(request, ContentType.IMAGE), true);
      
      request = URLRequest('https://notads.example.com/banner', 'example.com');
      expect(filter.matches(request, ContentType.IMAGE), false);
    });

    test('Domain-specific filter', () {
      var filter = BlockingFilter(
        '||ads.com^$domain=example.com',
        'ads.com^',
        ContentType.ALL,
        false,
        'example.com',
        false,
        null,
        null,
        null,
        null
      );

      var request = URLRequest('https://ads.com/banner', 'example.com');
      expect(filter.matches(request, ContentType.IMAGE), true);
      
      request = URLRequest('https://ads.com/banner', 'otherdomain.com');
      expect(filter.matches(request, ContentType.IMAGE), false);
    });

    test('Content type filter', () {
      var filter = BlockingFilter(
        '||ads.com^$image',
        'ads.com^',
        ContentType.IMAGE,
        false,
        null,
        false,
        null,
        null,
        null,
        null
      );

      var request = URLRequest('https://ads.com/banner.jpg', 'example.com');
      expect(filter.matches(request, ContentType.IMAGE), true);
      expect(filter.matches(request, ContentType.SCRIPT), false);
    });
  });

  group('URL Handling Tests', () {
    test('Domain parsing', () {
      expect(extractDomain('https://www.example.com/path'), 'www.example.com');
      expect(extractDomain('http://sub.example.com:8080/path'), 'sub.example.com');
      expect(extractDomain('https://user:pass@example.com/path'), 'example.com');
    });

    test('Third-party checking', () {
      expect(isThirdParty('https://ads.com/banner', 'example.com'), true);
      expect(isThirdParty('https://sub.example.com/banner', 'example.com'), false);
      expect(isThirdParty('https://example.com/banner', 'example.com'), false);
    });

    test('Domain suffixes', () {
      var suffixes = getDomainSuffixes('sub.example.com');
      expect(suffixes, ['sub.example.com', 'example.com', 'com']);
    });
  });

  group('Content Type Tests', () {
    test('Content type mapping', () {
      expect(typeFromText('image'), ContentType.IMAGE);
      expect(typeFromText('script'), ContentType.SCRIPT);
      expect(typeFromText('unknown'), ContentType.OTHER);
    });

    test('Type to text conversion', () {
      expect(textFromType(ContentType.IMAGE), 'image');
      expect(textFromType(ContentType.SCRIPT), 'script');
      expect(textFromType(ContentType.OTHER), 'other');
    });
  });
}

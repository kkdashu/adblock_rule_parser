import 'dart:io';

import 'package:adblock_rule_parser/adblock_rule_parser.dart';
import 'package:adblock_rule_parser/src/filters/index.dart';

void log(String message) {
  print(message);
}

Future<List<String>> getRules() {
  final file = new File('assets/easylist.txt');
  final lines = file.readAsLines();
  return lines;
  // return Future.value([
  //   "###ads_banner1",
  // ]);
}

void main() async {
  final rules = await getRules();
  log(rules.length.toString());
  final List<ParsedFilter> parsedFilters = [];
  Stopwatch stopwatch = new Stopwatch()..start();
  for (final rule in rules) {
    try {
      parsedFilters.add(parse(rule));
    } catch (e) {
      log('Error parsing rule $rule: $e');
      continue;
    }
  }
  log(parsedFilters.length.toString());
  stopwatch.stop();
  // print('Parsed: $parsedFilters');
  print('Time: ${stopwatch.elapsedMilliseconds} ms');
  // final List<Filter> filters = [];
  // Stopwatch stopwatch = new Stopwatch()..start();
  // for (final rule in rules) {
  //   try {
  //     filters.add(Filter.fromText(rule));
  //   } catch (e) {
  //     log('Error parsing rule $rule: $e');
  //     continue;
  //   }
  // }
  // final types = filters.map((f) => f.type).toList();
  // print('Types: $types');
  // stopwatch.stop();
  // print('Time: ${stopwatch.elapsedMilliseconds} ms');
  // log(filters.length.toString());
}

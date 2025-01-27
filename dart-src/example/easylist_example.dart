import 'dart:io';

import 'package:adblock_rule_parser/adblock_rule_parser.dart';

void log(String message) {
  print(message);
}

Future<List<String>> getRules() {
  final file = new File('assets/easylist.txt');
  final lines = file.readAsLines();
  return lines;
}

void main() async {
  final rules = await getRules();
  log(rules.length.toString());
  final List<Filter> filters = [];
  Stopwatch stopwatch = new Stopwatch()..start();
  for (final rule in rules) {
    try {
      filters.add(Filter.fromText(rule));
    } catch (e) {
      log('Error parsing rule $rule: $e');
      continue;
    }
  }
  log(filters.length.toString());
  stopwatch.stop();
  print('filters: $filters');
  print('Time: ${stopwatch.elapsedMilliseconds} ms');
}

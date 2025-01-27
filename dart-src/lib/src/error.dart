/// 解析Filter错误
class ParseFilterException implements Exception {
  final String message;
  ParseFilterException(this.message);

  @override
  String toString() => 'ParseFilterException: $message';
}

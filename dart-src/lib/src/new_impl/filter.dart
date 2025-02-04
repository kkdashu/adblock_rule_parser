/// 参考 https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters 实现AdblockPlus的Filter解析
/// 过滤器分为 BlockingFilter、ContentFilter、CommentFilter、UnknownFilter
/// BlockingFilter 应该在网络层决定是否拦截请求
/// ContentFilter 应该在页面注入脚本处理
/// CommentFilter 与 UnknownFilter 可以忽略
sealed class Filter {
  Filter({required this.text});
  final String text;

  factory Filter.parse(String text) {
    return BlockingFilter._(text: text, exception: false);
  }

  bool match(String url);
}

/// Applied on the network level to decide whether a request should be blocked.
/// 可以在InAppWebView的shouldInterceptRequest回调中决定是否拦截请求
/// 注意解析以下特性：
/// - wildcard symbol (*)
/// - pipe symbol (|) 
/// - domain boundary symbol (||)
/// - separator symbol (^)
/// 如果包含$字符串，$后面的是Filter Options。
class BlockingFilter extends Filter {
  BlockingFilter._({required this.exception, required String text}): super(text: text);
  /// [https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters#allowlist]
  /// adblockplus 支持设置allowing filter
  /// @@ 开头的是allowing filter
  final bool exception;

  @override
  bool match(String url) {
    return true;
  }
}

/// [https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters#content-filters] 
/// (including hiding filters oftentimes referred to as element hiding filters)
/// Hide particular elements on a page, including element hiding with extended selectors (emulation) as well as snippets.
/// 可以在InAppWebView的onLoadStart回调中注入JS脚本处理ContentFilter
/// <domains><separator><body>
class ContentFilter extends Filter {
  ContentFilter._({required String text}): super(text: text);

  @override
  bool match(String url) {
    return true;
  }
}

/// 注释过滤器
/// ! 开头的是注释
class CommentFilter extends Filter {
  CommentFilter._({required String text}): super(text: text);

  @override
  bool match(String url) {
    return false;
  }
}

/// 未知过滤器
class UnknownFilter extends Filter {
  UnknownFilter._({required String text}): super(text: text);

  @override
  bool match(String url) {
    return false;
  }
}

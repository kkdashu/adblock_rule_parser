import 'package:collection/collection.dart';

const RESOURCE_TYPE = (1 << 24) - 1;
const CSP_TYPE = 1 << 25;

const DOCUMENT_TYPE = 1 << 27;
const GENERICBLOCK_TYPE = 1 << 28;
const ELEMENTHIDE_TYPE = 1 << 29;
const GENERICHIDE_TYPE = 1 << 30;
enum ContentType {
  /// Types of web resources
  OTHER(v: 1),
  SCRIPT(v: 2),
  IMAGE(v: 4),
  STYLESHEET(v: 8),
  OBJECT(v: 16),
  SUBDOCUMENT(v: 32),
  WEBSOCKET(v: 128),
  WEBRTC(v: 256),
  PING(v: 1024),
  XMLHTTPREQUEST(v: 2048), // 1 << 11
  
  MEDIA(v: 16384),
  FONT(v: 32768), // 1 << 15

  // Special filter options
  POPUP(v: 1 << 24),
  CSP(v: CSP_TYPE),

  // Allowing flags
  DOCUMENT(v: DOCUMENT_TYPE),
  GENERICBLOCK(v: GENERICBLOCK_TYPE),
  ELEMHIDE(v: ELEMENTHIDE_TYPE),
  GENERICHIDE(v: GENERICHIDE_TYPE),


  ///Bitmask for "types" (flags) that are for exception rules only, like
  ///`$document`, `$elemhide`, and so on.
  ALLOWING_TYPES(v: DOCUMENT_TYPE | GENERICBLOCK_TYPE | ELEMENTHIDE_TYPE | GENERICHIDE_TYPE),

  /// Bitmask for resource types like `$script`, `$image`, `$stylesheet`, and so on.
  
  /// If a filter has no explicit content type, it applies to all resource types
  /// (but not to any {@link module:contentTypes.SPECIAL_TYPES special types}).
  ///
  /// @const {number}
  ///
  /// @package
  ///
  /// The first 24 bits are reserved for resource types like "script", "image",
  /// and so on.
  /// https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/ResourceType
  RESOURCE(v: RESOURCE_TYPE),

  ///
  ///Bitmask for special "types" (options and flags) like `$csp`, `$elemhide`,
  ///and so on.
  SPECIAL_TYPES(v: ~RESOURCE_TYPE & (1 << 31) - 1),

  ///Bitmask for "types" that match against request context more than
  ///actual content type. When matching against context types, you
  ///should also include the request's resource type.
  CONTEXT_TYPES(v: CSP_TYPE),

  ;
  

  const ContentType({
    required this.v
  });

  final int v;

  static ContentType? fromInt(int v) {
    return ContentType.values.firstWhereOrNull((value) => value.v == v);
  }

  bool isType(ContentType type) {
    return (v & type.v) != 0;
  }

  static ContentType? fromText(String text) {
    return switch (text) {
      "OTHER" => OTHER,
      "SCRIPT" =>  SCRIPT,
      "IMAGE" => IMAGE,
      "STYLESHEET" => STYLESHEET,
      "OBJECT" => OBJECT,
      "SUBDOCUMENT" => SUBDOCUMENT,
      "WEBSOCKET" => WEBSOCKET,
      "WEBRTC" => WEBRTC,
      "PING" => PING,
      "XMLHTTPREQUEST" => XMLHTTPREQUEST,

      "MEDIA" => MEDIA,
      "FONT" => FONT,

      "POPUP" => POPUP,
      "CSP" => CSP,

      "DOCUMENT" => DOCUMENT,
      "GENERICBLOCK" => GENERICBLOCK,
      "ELEMHIDE" => ELEMHIDE,
      "GENERICHIDE" => GENERICHIDE,

      "ALLOWING_TYPES" => ALLOWING_TYPES,
      "RESOURCE" => RESOURCE,
      "SPECIAL_TYPES" => SPECIAL_TYPES,
      "CONTEXT_TYPES" => CONTEXT_TYPES,
      _ => null,
    };
  }
}

// Copyright (c) 2024. This code is licensed under MIT license (see LICENSE for details)

/// Content types that can be blocked
class ContentType {
  static const int OTHER = 1;
  static const int SCRIPT = 2;
  static const int IMAGE = 4;
  static const int STYLESHEET = 8;
  static const int OBJECT = 16;
  static const int SUBDOCUMENT = 32;
  static const int DOCUMENT = 64;
  static const int WEBSOCKET = 128;
  static const int WEBRTC = 256;
  static const int CSP = 512;
  static const int HEADER = 1024;
  static const int GENERICHIDE = 2048;
  static const int ELEMHIDE = 4096;
  static const int GENERICBLOCK = 8192;
  static const int PING = 16384;
  static const int XMLHTTPREQUEST = 32768;
  static const int OBJECT_SUBREQUEST = 65536;
  static const int MEDIA = 131072;
  static const int FONT = 262144;
  static const int POPUP = 524288;

  /// All content types that can be blocked
  static const int ALL = OTHER |
      SCRIPT |
      IMAGE |
      STYLESHEET |
      OBJECT |
      SUBDOCUMENT |
      DOCUMENT |
      WEBSOCKET |
      WEBRTC |
      CSP |
      HEADER |
      GENERICHIDE |
      ELEMHIDE |
      GENERICBLOCK |
      PING |
      XMLHTTPREQUEST |
      OBJECT_SUBREQUEST |
      MEDIA |
      FONT |
      POPUP;

  /// Maps type names to bit masks
  static const Map<String, int> typeMap = {
    'other': OTHER,
    'script': SCRIPT,
    'image': IMAGE,
    'stylesheet': STYLESHEET,
    'object': OBJECT,
    'subdocument': SUBDOCUMENT,
    'document': DOCUMENT,
    'websocket': WEBSOCKET,
    'webrtc': WEBRTC,
    'csp': CSP,
    'header': HEADER,
    'generichide': GENERICHIDE,
    'elemhide': ELEMHIDE,
    'genericblock': GENERICBLOCK,
    'ping': PING,
    'xmlhttprequest': XMLHTTPREQUEST,
    'object-subrequest': OBJECT_SUBREQUEST,
    'media': MEDIA,
    'font': FONT,
    'popup': POPUP,
  };

  /// Maps bit masks to type names
  static const Map<int, String> maskToType = {
    OTHER: 'other',
    SCRIPT: 'script',
    IMAGE: 'image',
    STYLESHEET: 'stylesheet',
    OBJECT: 'object',
    SUBDOCUMENT: 'subdocument',
    DOCUMENT: 'document',
    WEBSOCKET: 'websocket',
    WEBRTC: 'webrtc',
    CSP: 'csp',
    HEADER: 'header',
    GENERICHIDE: 'generichide',
    ELEMHIDE: 'elemhide',
    GENERICBLOCK: 'genericblock',
    PING: 'ping',
    XMLHTTPREQUEST: 'xmlhttprequest',
    OBJECT_SUBREQUEST: 'object-subrequest',
    MEDIA: 'media',
    FONT: 'font',
    POPUP: 'popup',
  };
}

/// Map of content type names to their corresponding bit flags
final Map<String, int> _contentTypeMap = {
  'OTHER': ContentType.OTHER,
  'SCRIPT': ContentType.SCRIPT,
  'IMAGE': ContentType.IMAGE,
  'STYLESHEET': ContentType.STYLESHEET,
  'OBJECT': ContentType.OBJECT,
  'SUBDOCUMENT': ContentType.SUBDOCUMENT,
  'DOCUMENT': ContentType.DOCUMENT,
  'WEBSOCKET': ContentType.WEBSOCKET,
  'WEBRTC': ContentType.WEBRTC,
  'CSP': ContentType.CSP,
  'HEADER': ContentType.HEADER,
  'GENERICHIDE': ContentType.GENERICHIDE,
  'ELEMHIDE': ContentType.ELEMHIDE,
  'GENERICBLOCK': ContentType.GENERICBLOCK,
  'PING': ContentType.PING,
  'XMLHTTPREQUEST': ContentType.XMLHTTPREQUEST,
  'OBJECT_SUBREQUEST': ContentType.OBJECT_SUBREQUEST,
  'MEDIA': ContentType.MEDIA,
  'FONT': ContentType.FONT,
  'POPUP': ContentType.POPUP,
};

/// Convert content type text to bit flag
int? contentTypeFromText(String text) {
  return _contentTypeMap[text.toUpperCase()];
}

/// Convert content type bit flag to text
String textFromType(int type) {
  for (var entry in _contentTypeMap.entries) {
    if (entry.value == type) {
      return entry.key.toLowerCase();
    }
  }
  return 'other';
}

/// Converts a content type string to its corresponding bit mask
int typeFromText(String text) {
  return ContentType.typeMap[text.toLowerCase()] ?? ContentType.OTHER;
}

/// Converts a bit mask to its corresponding content type string
String textFromTypeLegacy(int type) {
  return ContentType.maskToType[type] ?? 'other';
}

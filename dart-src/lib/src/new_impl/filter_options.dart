/// https://help.adblockplus.org/hc/en-us/articles/360062733293-How-to-write-filters#options

const RESOURCE_TYPE = (1 << 24) - 1;
const CSP_TYPE = 1 << 25;

const DOCUMENT_TYPE = 1 << 27;
const GENERICBLOCK_TYPE = 1 << 28;
const ELEMENTHIDE_TYPE = 1 << 29;
const GENERICHIDE_TYPE = 1 << 30;

enum TypeOptions {
  /// types of requests not covered in the list above
  OTHER(v: 1),
  /// external scripts loaded via the HTML script tag
  SCRIPT(v: 2),
  /// regular images, typically loaded via the HTML img tag
  IMAGE(v: 4),
  /// external CSS stylesheet files
  STYLESHEET(v: 8),
  /// content handled by browser plug-ins, e.g. Flash or Java
  OBJECT(v: 16),
  /// embedded pages, usually included via HTML inline frames (iframes)
  SUBDOCUMENT(v: 32),
  /// requests initiated via WebSocket object
  WEBSOCKET(v: 128),
  /// connections opened via RTCPeerConnection instances to ICE servers 
  WEBRTC(v: 256),
  /// requests started by or navigator.sendBeacon()
  PING(v: 1024),
  /// requests started using the XMLHttpRequest object or fetch() API
  XMLHTTPREQUEST(v: 2048), // 1 << 11
  
  /// regular media files like music and video
  MEDIA(v: 16384),
  /// external font files
  FONT(v: 32768), // 1 << 15

  // Special filter options
  /// pages opened in a new tab or window Note: Filters will not block pop-ups by default, only if the $popup type option is specified.
  POPUP(v: 1 << 24),
  CSP(v: CSP_TYPE),

  /// Allowing flags
  /// the page itself, but only works for exception rules. You can use this option to allowlist an entire iframe or website.
  DOCUMENT(v: DOCUMENT_TYPE),
  /// for exception rules only, just like generichide but turns off generic blocking rules (Adblock Plus 2.6.12 or higher is required)
  GENERICBLOCK(v: GENERICBLOCK_TYPE),
  /// for exception rules only, similar to document but only turns off element hiding rules on the page rather than all filter rules (Adblock Plus 1.2 or higher is required)
  ELEMHIDE(v: ELEMENTHIDE_TYPE),
  /// for exception rules only, similar to elemhide but only turns off generic element hiding rules on the page (Adblock Plus 2.6.12 or higher is required)
  GENERICHIDE(v: GENERICHIDE_TYPE),

  ;

  const TypeOptions({required this.v});
  final int v;

  factory TypeOptions.fromText(String text) {
    return switch (text) {
      _ => OTHER,
    };
  }
}

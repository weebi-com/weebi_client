import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

Future<String> fetchText(Uri uri) async {
  final response = await web.window.fetch(uri.toString().toJS).toDart;
  if (!response.ok) throw Exception('Fetch failed');
  final textJS = await response.text().toDart;
  return textJS.toDart;
}

void openUrl(String url, {String target = '_blank'}) {
  web.window.open(url, target);
}

void navigateTo(String url) {
  web.window.location.href = url;
}

String get locationHref => web.window.location.href;

String get locationOrigin => web.window.location.origin;

void replaceHistoryState(String url) {
  web.window.history.replaceState(null, '', url);
}

String? sessionStorageGet(String key) {
  return web.window.sessionStorage.getItem(key);
}

void sessionStorageSet(String key, String value) {
  web.window.sessionStorage.setItem(key, value);
}

void sessionStorageRemove(String key) {
  web.window.sessionStorage.removeItem(key);
}

void registerIFrameViewFactory(
  String viewType,
  String url,
  int width,
  int height,
) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = url
        ..width = width.toString()
        ..height = height.toString()
        ..style.border = 'none';
      return iframe;
    },
  );
}

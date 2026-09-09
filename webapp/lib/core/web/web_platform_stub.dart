Future<String> fetchText(Uri uri) async => '';

void openUrl(String url, {String target = '_blank'}) {}

void navigateTo(String url) {}

String get locationHref => 'http://localhost/#/billing';

String get locationOrigin => 'http://localhost';

void replaceHistoryState(String url) {}

String? sessionStorageGet(String key) => null;

void sessionStorageSet(String key, String value) {}

void sessionStorageRemove(String key) {}

void registerIFrameViewFactory(
  String viewType,
  String url,
  int width,
  int height,
) {}

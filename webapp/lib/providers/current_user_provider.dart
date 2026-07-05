import 'package:flutter/foundation.dart';
import 'package:protos_weebi/protos_weebi_io.dart'
    show FenceServiceClient, UserId, UserPermissions, UserPublic;
import 'package:web_admin/grpc/server.dart';

class CurrentUserProvider extends ChangeNotifier {
  CurrentUserProvider(this._fenceServiceClient);

  FenceServiceClient _fenceServiceClient;
  UserPublic? _user;
  Future<UserPublic?>? _loading;
  Object? _error;

  UserPublic? get user => _user;
  Object? get error => _error;
  bool get isLoading => _loading != null;
  UserPermissions get permissions =>
      _user?.permissions ?? UserPermissions.create();
  String get userId => _user?.userId ?? permissions.userId;
  String get firmId => permissions.firmId;
  FenceServiceClient get fenceServiceClient => _fenceServiceClient;

  set fenceServiceClient(FenceServiceClient value) {
    _fenceServiceClient = value;
  }

  Future<UserPublic?> load({bool force = false}) {
    if (!force && _user != null) return Future.value(_user);
    if (!force && _loading != null) return _loading!;

    _error = null;
    _loading = _fenceServiceClient
        .readOneUser(UserId(), options: callOptions)
        .then((response) {
      _user = response.user;
      _error = null;
      return _user;
    }).catchError((Object e) {
      _error = e;
      _user = null;
      throw e;
    }).whenComplete(() {
      _loading = null;
      notifyListeners();
    });

    return _loading!;
  }

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}

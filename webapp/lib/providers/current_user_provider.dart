import 'package:flutter/foundation.dart';
import 'package:protos_weebi/protos_weebi_io.dart'
    show FenceServiceClient, UserId, UserPermissions, UserPublic;
import 'package:web_admin/grpc/server.dart';

class CurrentUserProvider extends ChangeNotifier {
  CurrentUserProvider(this._fenceServiceClient);

  FenceServiceClient _fenceServiceClient;
  UserPublic? _user;
  Future<UserPublic?>? _loading;

  UserPublic? get user => _user;
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

    _loading = _fenceServiceClient
        .readOneUser(UserId(), options: callOptions)
        .then((response) {
      _user = response.user;
      notifyListeners();
      return _user;
    }).whenComplete(() {
      _loading = null;
    });

    return _loading!;
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}

import 'package:protos_weebi/protos_weebi_io.dart';

/// Manages current user session information
/// Single Responsibility: User session state only
class UserSession {
  String _firstName = '';
  String _lastName = '';
  String _mail = '';
  Phone _phone = Phone.create();

  // User Information (Read-only access)
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get fullName => '$_firstName $_lastName';
  String get mail => _mail;
  Phone get phone => _phone;

  /// Sets user information from UserPublic
  void setUserInfo(UserPublic user) {
    _firstName = user.firstname;
    _lastName = user.lastname;
    _mail = user.mail;
    _phone = user.phone;
    print('UserSession: Set user info for ${user.firstname} ${user.lastname}');
  }

  /// Clears all user session data
  void clearSession() {
    _firstName = '';
    _lastName = '';
    _mail = '';
    _phone = Phone.create();
    print('UserSession: Cleared user session');
  }

  /// Checks if user session is active
  bool get hasActiveSession => _firstName.isNotEmpty && _lastName.isNotEmpty;

  /// Gets a display-friendly user identifier
  String get userDisplayName {
    if (hasActiveSession) {
      return fullName;
    } else if (_mail.isNotEmpty) {
      return _mail;
    } else {
      return 'Anonymous User';
    }
  }

  /// Creates a UserPublic object from current session (for updates)
  UserPublic toUserPublic() {
    return UserPublic.create()
      ..firstname = _firstName
      ..lastname = _lastName
      ..mail = _mail
      ..phone = _phone;
  }
}


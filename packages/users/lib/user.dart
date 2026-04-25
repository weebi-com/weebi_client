import 'package:protos_weebi/protos_weebi_io.dart';

/// Extension methods for the UserPublic protobuf class to provide
/// convenient access and formatting of user data
extension UserPublicExtension on UserPublic {
  /// Gets the full name of the user
  String get fullName {
    if (!hasFirstname() || !hasLastname()) return '';
    return '$firstname $lastname';
  }

  /// Gets a formatted creation date string
  String get formattedCreatedAt {
    if (!hasLastSignIn()) return '';
    final date =
        DateTime.fromMillisecondsSinceEpoch(lastSignIn.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets a formatted last update date string
  String get formattedLastSignIn {
    if (!hasLastSignIn()) return '';
    final date =
        DateTime.fromMillisecondsSinceEpoch(lastSignIn.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets a map of user details for display
  Map<String, String> get detailsMap {
    return {
      'First Name': firstname,
      'Last Name': lastname,
      'Email': mail,
      'Last Sign In': formattedLastSignIn,
    };
  }

  /// Creates a copy of the user with updated fields
  UserPublic copyWith({
    String? userId,
    String? mail,
    String? firstname,
    String? lastname,
    Phone? phone,
    Timestamp? lastSignIn,
    UserPermissions? permissions,
    Map<String, String>? othersAttributes,
  }) {
    return UserPublic()
      ..userId = userId ?? this.userId
      ..mail = mail ?? this.mail
      ..firstname = firstname ?? this.firstname
      ..lastname = lastname ?? this.lastname
      ..phone = phone ?? this.phone
      ..lastSignIn = lastSignIn ?? this.lastSignIn
      ..permissions = permissions ?? this.permissions
      ..othersAttributes.addAll(othersAttributes ?? this.othersAttributes);
  }
} 
/// Gatekeeper - Session coordination and access management for Weebi applications
/// 
/// Provides a unified interface for:
/// - Device enrollment and identity management
/// - User session management
/// - Token coordination (access + refresh)
/// - Permission management (from JWT tokens)
/// - Mail management
library;

export 'src/gatekeeper.dart';
export 'src/default_permissions.dart';
export 'src/services/device_manager.dart';
export 'src/services/user_session.dart';
export 'src/services/mail_manager.dart';

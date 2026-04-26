# Changelog

## 1.0.7 - 2026 march

- bump models and auth and protos

## 1.0.6 - 2025 february

- bump protos, auth, models, services

## 1.0.0 - 2025-01-09

### Added
- Initial release of Gatekeeper package
- `Gatekeeper` class for complete session coordination
- `Gatekeeper` base class for extensibility
- `DeviceManager` for device enrollment and identity
- `UserSession` for user information caching
- `MailManager` for user mail operations
- Integration with `auth_weebi` for token and permission management
- Token management methods: `setTokens()`, `clearAllTokens()`, `restoreAllTokens()`
- Permission checks from JWT tokens (offline-first)
- Comprehensive documentation and integration guide

### Architecture
- Extracted from `mixins_weebi` package for better separation of concerns
- Infrastructure layer separate from app logic (MobX stores)
- Single responsibility: Session coordination and access management
- Clean dependencies: auth → gatekeeper → app logic

### Documentation
- README.md - Package overview and quick start
- GATEKEEPER_INTEGRATION_GUIDE.md - Complete integration guide
- Example code for common use cases

# changelog 

## 1.1.0

- keep android false

## 1.0.9

- isolate permission in user detail
- warn about licenses

## 1.0.8

- onCreate

## 1.0.7

- searchbar

## 1.0.6+1

- protobuf dynamic be able to hide specific fields 

## 1.0.6

- bump protos
- more flexible email regexp

## 1.0.5+1 - dec 2025

- bump intl ^0.20.2

## 1.0.5 - nov 2025

- bump auth 1.0.5.1

## 1.0.4 - 29 oct 2025

- display user password update in users packages
- refresh permissions
- fix UI in permissions

## 1.0.3 - oct 2025

- bump protos_weebi, auth
- bump collection 
- remove flutter_driver and test (dart)

## 1.0.2
- fl_country_code_picker_weebi: ^0.2.3

## 1.0.1

- flutter: ">=3.24.0" 
- fl_country_code_picker_weebi: ^0.2.2
- bump auth package 1.0.1

## 1.0.0

- **NEW**: Beautiful `UserCreateView` with comprehensive permission setup
- **NEW**: Country code picker integration for phone numbers  
- **NEW**: Real-time form validation and error handling
- **NEW**: Card-based modern UI design following Material 3 guidelines
- **NEW**: **Route Factory Pattern** - Clean route integration with `UserRoutes.getMaterialRoutes()`
- **NEW**: Package-provided routes (`/users`, `/users/create`) for seamless navigation
- **NEW**: Comprehensive integration guide with multiple integration options
- **ENHANCED**: Backend-generated user IDs (removed auto-generation)
- **ENHANCED**: Clean navigation with `Navigator.pushNamed()` - no callback complexity
- **ENHANCED**: FAB in UserListWidget navigates to `/users/create` route
- **ADDED**: fl_country_code_picker dependency for phone number support

* Initial release of users_weebi package
* User management with CRUD operations  
* Authentication via shared auth_weebi package
* Permission management with granular controls
* gRPC integration with FenceServiceClient
* UI components for user management
* Provider-based state management
* Clean architecture with separation of concerns
library ;

// Core functionality
export 'user.dart';
export 'permissions.dart';
export 'src/firm_license_seat_utils.dart';
export 'src/l10n/license_ui_strings.dart';
export 'src/l10n/user_ui_strings.dart';
export 'src/l10n/permissions_ui_strings.dart';

// Providers
export 'src/providers/user_provider.dart';

// Interceptors
export 'src/interceptors/log_interceptor.dart';

// Widgets
export 'src/widgets/user_detail_widget.dart';
export 'src/widgets/license_seat_status_card.dart';
export 'src/widgets/user_form_widget.dart';
export 'src/widgets/user_list_widget.dart';
export 'src/widgets/compact_permissions_widget.dart';
export 'src/widgets/elegant_permissions_widget.dart';
export 'src/widgets/user_search_widget.dart';
export 'src/widgets/user_mirror_widget.dart';
export 'src/widgets/user_create_view.dart';
export 'src/routes/user_routes.dart';

// Fence client providers
export 'fence_client_provider.dart';
export 'src/dynamic_permissions_analyzer.dart';
export 'dynamic_body.dart';

// Re-export auth_weebi for convenience
export 'package:auth_weebi/auth_weebi.dart';
// library boutiques_weebi;

// Core functionality
export 'boutique.dart';
export 'src/l10n/boutique_ui_strings.dart';
export 'dynamic_body.dart';

// Providers
export 'src/providers/boutique_provider.dart';

// Events
export 'src/events/boutique_events.dart';
export 'src/events/boutique_listener.dart';
export 'src/events/lazy_boutique_listener.dart';
export 'src/events/boutique_sync_integration.dart';

// Widgets
export 'src/widgets/boutique_list_widget.dart';
export 'src/widgets/boutique_list_with_bus.dart';
export 'src/widgets/boutique_widget.dart';
export 'src/widgets/boutique_create_view.dart';
export 'src/widgets/billing_currency_field.dart';
export 'src/widgets/secondary_display_currency_fields.dart';

export 'src/utils/drc_secondary_currency.dart';
export 'src/widgets/boutique_detail_view.dart';
export 'src/widgets/boutique_form_widget.dart';
export 'src/widgets/boutique_detail_widget.dart';
export 'src/widgets/chain_detail_widget.dart';

// Routes
export 'src/routes/boutique_routes.dart';

// Re-export auth_weebi for convenience
export 'package:auth_weebi/auth_weebi.dart';

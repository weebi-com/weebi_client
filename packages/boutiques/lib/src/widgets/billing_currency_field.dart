import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/boutique_ui_strings.dart';

/// Read-only ISO 4217 picker aligned with [BoutiquePb.currency] / chain billing currency.
class BillingCurrencyField extends StatefulWidget {
  const BillingCurrencyField(
      {super.key,
      required this.controller,
      this.showCurrencyFlags = false,
      this.labelText,
      this.tooltip,
      this.isDecorationBorderless = false});

  final TextEditingController controller;
  final bool showCurrencyFlags;
  final bool isDecorationBorderless;
  final String? labelText;
  final String? tooltip;

  @override
  State<BillingCurrencyField> createState() => _BillingCurrencyFieldState();
}

class _BillingCurrencyFieldState extends State<BillingCurrencyField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(BillingCurrencyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? BoutiqueUiStrings.billingCurrencyTooltip,
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        showCursor: false,
        enableInteractiveSelection: false,
        onTap: () {
          showCurrencyPicker(
            showFlag: widget.showCurrencyFlags,
            context: context,
            onSelect: (Currency c) {
              setState(() {
                widget.controller.text = c.code.toUpperCase();
              });
            },
          );
        },
        decoration: InputDecoration(
          labelText: widget.labelText ?? BoutiqueUiStrings.billingCurrencyLabel,
          border: widget.isDecorationBorderless ? null : const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.payments_outlined),
          suffixIcon: widget.controller.text.isEmpty
              ? const Icon(Icons.arrow_drop_down)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => widget.controller.clear());
                  },
                ),
        ),
      ),
    );
  }
}

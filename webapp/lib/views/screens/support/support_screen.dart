import 'package:design_weebi/design_weebi.dart' show ColorsWeebi;
import 'package:flutter/material.dart';
import 'package:web_admin/core/constants/contact.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/web/web_platform.dart' as web;
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Support / contact page. Email and WhatsApp.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.support,
            style: themeData.textTheme.headlineMedium,
          ),
          const SizedBox(height: kDefaultPadding),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ContactTile(
                    icon: Icons.mail_outline_rounded,
                    iconColor: null,
                    label: lang.supportEmailUs,
                    subtitle: 'hello@weebi.com',
                    onTap: () =>
                        web.openUrl('mailto:hello@weebi.com', target: '_self'),
                  ),
                  _ContactTile(
                    icon: Icons.chat_outlined,
                    iconColor: null,
                    isWhatsApp: true,
                    label: 'WhatsApp',
                    subtitle: lang.supportChatWhatsApp,
                    onTap: () => web.openUrl(
                      'https://wa.me/${Contact.weebiWhatsapp}',
                      target: '_blank',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final dynamic icon;
  final Color? iconColor;
  final bool isWhatsApp;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    this.iconColor,
    this.isWhatsApp = false,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isWhiteBackground = themeData.brightness == Brightness.light;
    final color = iconColor ??
        (isWhatsApp
            ? (isWhiteBackground ? ColorsWeebi.whatsapp : Colors.white)
            : themeData.colorScheme.primary);

    final Widget leadingIcon;
    if (icon is IconData) {
      leadingIcon = Icon(icon as IconData, color: color, size: 26);
    } else {
      // Robust handling for custom icon types (like FalconData)
      leadingIcon = Icon(Icons.help_outline, color: color, size: 26);
    }

    return ListTile(
      leading: leadingIcon,
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: onTap,
    );
  }
}

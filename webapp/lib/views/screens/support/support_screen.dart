// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:design_weebi/design_weebi.dart' show ColorsWeebi;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web_admin/core/constants/contact.dart';
import 'package:web_admin/core/constants/dimens.dart';
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
                    onTap: () => html.window.open('mailto:hello@weebi.com', '_self'),
                  ),
                  _ContactTile(
                    icon: FontAwesomeIcons.whatsapp,
                    iconColor: null,
                    label: 'WhatsApp',
                    subtitle: lang.supportChatWhatsApp,
                    onTap: () => html.window.open(
                      'https://wa.me/${Contact.weebiWhatsapp}',
                      '_blank',
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
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isWhiteBackground = themeData.brightness == Brightness.light;
    final color = iconColor ??
        (icon == FontAwesomeIcons.whatsapp
            ? (isWhiteBackground ? ColorsWeebi.whatsapp : Colors.white)
            : themeData.colorScheme.primary);

    return ListTile(
      leading: Icon(icon, color: color, size: 26),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: onTap,
    );
  }
}

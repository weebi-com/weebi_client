// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// Help / FAQ page. Explains web console scope and links to resources.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.help,
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
                  Text(
                    lang.helpScopeTitle,
                    style: themeData.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.helpScopeBody,
                    style: themeData.textTheme.bodyMedium,
                  ),
                  const Divider(height: 24),
                  Text(
                    lang.helpResourcesTitle,
                    style: themeData.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LinkTile(
                    icon: Icons.school_rounded,
                    label: lang.helpReadFaq,
                    onTap: () {
                      final locale = Localizations.localeOf(context).languageCode;
                      final langPath = (locale == 'fr') ? 'fr' : 'en';
                      html.window.open('https://www.weebi.com/$langPath/user-guide/', '_blank');
                    },
                  ),
                  _LinkTile(
                    icon: Icons.subscriptions_rounded,
                    label: lang.helpWatchDemos,
                    onTap: () => html.window.open('https://youtube.com/@Weebi', '_blank'),
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

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: themeData.colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: onTap,
    );
  }
}

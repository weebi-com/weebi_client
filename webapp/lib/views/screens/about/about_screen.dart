import 'package:flutter/material.dart';
import 'package:web_admin/core/constants/dimens.dart';
import 'package:web_admin/core/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/core/web/web_platform.dart' as web;
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

/// About page. Blog, partners. Adapted from OS app for web console.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final lang = Lang.of(context);
    final linkStyle = TextStyle(
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.underline,
      color: themeData.extension<AppColorScheme>()?.hyperlink ??
          themeData.colorScheme.primary,
    );

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.about,
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
                    lang.aboutBlog,
                    style: themeData.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => web.openUrl('https://weebi.com/fr/posts/',
                        target: '_blank'),
                    child: Text(
                      'https://weebi.com/fr/posts/',
                      style: linkStyle,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    lang.aboutPartners,
                    style: themeData.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PartnerItem(
                    name: 'Jokkolabs Dakar',
                    url: 'https://www.facebook.com/jokkolabsDakar/',
                    onTap: () => web.openUrl(
                        'https://www.facebook.com/jokkolabsDakar/',
                        target: '_blank'),
                  ),
                  const SizedBox(height: 8),
                  _PartnerItem(
                    name: 'NTFIV Sénégal',
                    url: 'http://www.intracen.org/NTF4/Senegal-TI/',
                    onTap: () => web.openUrl(
                        'http://www.intracen.org/NTF4/Senegal-TI/',
                        target: '_blank'),
                  ),
                  const SizedBox(height: 8),
                  _PartnerItem(
                    name: 'L\'Agence Française de Développement (AFD)',
                    url: 'https://www.afd.fr/',
                    onTap: () => web.openUrl('https://www.afd.fr/',
                        target: '_blank')),
                  const SizedBox(height: 8),
                  _PartnerItem(
                    name: 'La Société Générale',
                    url: 'https://www.societe-generale.com/',
                    onTap: () => web.openUrl(
                        'https://www.societe-generale.com/',
                        target: '_blank')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerItem extends StatelessWidget {
  final String name;
  final String url;
  final VoidCallback onTap;

  const _PartnerItem({
    required this.name,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final linkStyle = TextStyle(
      decoration: TextDecoration.underline,
      color: themeData.extension<AppColorScheme>()?.hyperlink ??
          themeData.colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: themeData.textTheme.bodyMedium),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.translucent,
            child: Text(url, style: linkStyle),
          ),
        ],
      ),
    );
  }
}

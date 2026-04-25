import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/legal/enterprise_terms_version.dart';

import '../../../core/constants/dimens.dart';

/// Which bundled markdown asset to show; paths are registered in `app_router.dart`.
enum EnterpriseLegalDocument {
  termsEn,
  cgvFr,
}

extension EnterpriseLegalDocumentX on EnterpriseLegalDocument {
  String get assetKey => switch (this) {
        EnterpriseLegalDocument.termsEn => 'lib/cgv_en.md',
        EnterpriseLegalDocument.cgvFr => 'lib/cgv_fr.md',
      };
}

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final EnterpriseLegalDocument document;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String? _markdown;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text =
          await rootBundle.loadString(widget.document.assetKey);
      if (mounted) {
        setState(() {
          _markdown = text;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _markdown = null;
          _loadError = e;
        });
      }
    }
  }

  String _title(Lang lang) {
    return switch (widget.document) {
      EnterpriseLegalDocument.termsEn => lang.legalDocTitleTermsEn,
      EnterpriseLegalDocument.cgvFr => lang.legalDocTitleCgvFr,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(lang)),
      ),
      body: _buildBody(context, theme, lang),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, Lang lang) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Text(
            _loadError.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }
    if (_markdown == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Markdown(
            data: _markdown!,
            selectable: true,
            padding: const EdgeInsets.all(kDefaultPadding * 1.5),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.headlineMedium,
              h2: theme.textTheme.titleLarge,
              p: theme.textTheme.bodyLarge,
              a: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            kDefaultPadding * 1.5,
            0,
            kDefaultPadding * 1.5,
            kDefaultPadding,
          ),
          child: Text(
            '${lang.legalDocumentVersionId}: $kEnterpriseTermsVersionId',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

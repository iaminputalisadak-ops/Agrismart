import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

/// Bottom sheet: choose English, Hindi, Nepali, or Russian.
Future<void> showLanguagePicker(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final rootContext = context;
  final current = LocaleController.instance.locale.languageCode;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  l10n.languageTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _langTile(ctx, rootContext, l10n, code: 'en', label: l10n.langEnglish, selected: current == 'en'),
              _langTile(ctx, rootContext, l10n, code: 'hi', label: l10n.langHindi, selected: current == 'hi'),
              _langTile(ctx, rootContext, l10n, code: 'ne', label: l10n.langNepali, selected: current == 'ne'),
              _langTile(ctx, rootContext, l10n, code: 'ru', label: l10n.langRussian, selected: current == 'ru'),
            ],
          ),
        ),
      );
    },
  );
}

Widget _langTile(
  BuildContext sheetContext,
  BuildContext rootContext,
  AppLocalizations l10n, {
  required String code,
  required String label,
  required bool selected,
}) {
  return ListTile(
    leading: Icon(selected ? Icons.check_circle : Icons.language_outlined),
    title: Text(label),
    selected: selected,
    onTap: () async {
      await LocaleController.instance.setLanguageCode(code);
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      if (rootContext.mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(content: Text(l10n.languageUpdated)),
        );
      }
    },
  );
}

import 'package:flutter/material.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/utils/trusted_url_launcher.dart';
import '../../../shared/providers/app_providers.dart';

typedef ExternalUriProbe = TrustedUriProbe;
typedef ExternalUriLauncher = TrustedUriLauncher;

/// Attempts to open a vetted History source outside the app.
///
/// Platform handlers can be unavailable on a device or browser. Returning a
/// result instead of propagating that failure lets every source affordance
/// provide the same user-visible feedback.
Future<bool> launchHistorySource(
  Uri uri, {
  ExternalUriProbe? canOpen,
  ExternalUriLauncher? open,
}) async {
  return launchTrustedExternal(uri, canOpen: canOpen, open: open);
}

/// Opens a History source or explains why the platform could not do so.
Future<void> openHistorySource(
  BuildContext context,
  Uri uri,
  DisplayLanguage language,
) async {
  if (await launchHistorySource(uri) || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(AppTranslations.get('hist_source_open_error', language)),
      ),
    );
}

import 'package:url_launcher/url_launcher.dart';

import 'trusted_url_policy.dart';

typedef TrustedUriProbe = Future<bool> Function(Uri uri);
typedef TrustedUriLauncher = Future<bool> Function(Uri uri);

/// Opens a catalog-controlled URL only after validating it at the platform
/// sink. Callers can inject the platform functions for deterministic tests.
Future<bool> launchTrustedExternal(
  Uri uri, {
  TrustedUriProbe? canOpen,
  TrustedUriLauncher? open,
}) async {
  final trustedUri = TrustedUrlPolicy.parseExternal(uri.toString());
  if (trustedUri == null) return false;

  final probe = canOpen ?? canLaunchUrl;
  final launcher =
      open ??
      (Uri target) => launchUrl(target, mode: LaunchMode.externalApplication);
  try {
    if (!await probe(trustedUri)) return false;
    return await launcher(trustedUri);
  } catch (_) {
    return false;
  }
}

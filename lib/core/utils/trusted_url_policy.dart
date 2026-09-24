/// Central policy for URLs that bundled catalog data may hand to the platform.
class TrustedUrlPolicy {
  // Keep this list explicit. The CDN is used only for provider cover images;
  // arbitrary subdomains must not become trusted external navigation targets.
  static const Set<String> allowedHosts = {
    'kitobkhon.net',
    'maorif.tj',
    'cdn.kitobkhon.net',
    'khirad.tj',
  };

  const TrustedUrlPolicy._();

  static Uri? parseExternal(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme.toLowerCase() != 'https') return null;
    if (uri.host.trim().isEmpty || uri.userInfo.isNotEmpty) return null;
    if (uri.hasPort && uri.port != 443) return null;

    final host = uri.host.toLowerCase();
    final isAllowed = allowedHosts.contains(host);
    return isAllowed ? uri : null;
  }
}

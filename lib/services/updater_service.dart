import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReleaseInfo {
  final String version;
  final String url;
  final String changelog;

  ReleaseInfo({
    required this.version,
    required this.url,
    required this.changelog,
  });
}

class UpdaterService {
  static const String _repoOwner = 'weberq';
  static const String _repoName = 'Pranay-Funds';

  /// Checks if a newer version is available on GitHub.
  /// Returns [ReleaseInfo] if an update is available, otherwise null.
  Future<ReleaseInfo?> checkForUpdates() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest release from GitHub
      final url = Uri.parse(
          'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest');
      final response = await http
          .get(url, headers: {'Accept': 'application/vnd.github.v3+json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String htmlUrl = data['html_url'] ?? '';
        final String body = data['body'] ?? '';

        // Strip 'v' prefix if present (e.g., v1.0.1 -> 1.0.1)
        final latestVersion =
            tagName.startsWith('v') ? tagName.substring(1) : tagName;

        if (_isNewer(latestVersion, currentVersion)) {
          return ReleaseInfo(
            version: latestVersion,
            url: htmlUrl,
            changelog: body,
          );
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
    return null;
  }

  /// Launch the update URL in the browser
  Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Compare semantic versions. Returns true if [latest] > [current].
  bool _isNewer(String latest, String current) {
    try {
      List<int> latestParts = latest.split('.').map(int.parse).toList();
      List<int> currentParts = current.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      // If we are here, major/minor/patch are equal so far.
      // If latest has more parts (e.g. 1.0.1 vs 1.0), it's newer.
      return latestParts.length > currentParts.length;
    } catch (e) {
      return false; // Parsing failed, assume no update
    }
  }
}

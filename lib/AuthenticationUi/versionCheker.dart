import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateChecker {
  /// Call this function in your splash or main screen
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      String? latestVersion;
      String? storeUrl;

      if (Platform.isIOS) {
        /// 🔹 iOS App Store version check
        final response = await http.get(Uri.parse(
            'https://itunes.apple.com/lookup?bundleId=${packageInfo.packageName}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['resultCount'] > 0) {
            latestVersion = data['results'][0]['version'];
            storeUrl = data['results'][0]['trackViewUrl'];
          }
        }
      } else if (Platform.isAndroid) {
        /// 🔹 Android Play Store version check (via public API)
        final response = await http.get(Uri.parse(
            'https://play.google.com/store/apps/details?id=${packageInfo.packageName}&hl=en'));
        if (response.statusCode == 200) {
          // Extract version info manually (approximation)
          final regex = RegExp(r'Current Version</div><span.*?>(.*?)</span>');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            latestVersion = match.group(1)?.trim();
          }
          storeUrl =
          'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
        }
      }

      if (latestVersion == null || storeUrl == null) return;

      if (_isVersionNewer(latestVersion, currentVersion)) {
        _showModernUpdateDialog(context, latestVersion, currentVersion, storeUrl);
      }
    } catch (e) {
      debugPrint("Error checking update: $e");
    }
  }

  /// 🔍 Compare versions like "1.0.2" < "1.0.5"
  static bool _isVersionNewer(String latest, String current) {
    List<int> latestParts =
    latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  /// 🧠 Modern dialog (Material for Android / Cupertino for iOS)
  static void _showModernUpdateDialog(BuildContext context,
      String latestVersion, String currentVersion, String storeUrl) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Update Available"),
          content: Text(
            "A new version ($latestVersion) is available.\nYou are currently using $currentVersion.",
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(storeUrl))) {
                  await launchUrl(Uri.parse(storeUrl),
                      mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Update Now"),
            ),
            CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () => Navigator.pop(context),
              child: const Text("Later"),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 15),
                const Icon(Icons.system_update, size: 50, color: Colors.blue),
                const SizedBox(height: 15),
                Text(
                  "Update Available",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "A new version ($latestVersion) is available.\nYou are using $currentVersion.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(storeUrl))) {
                      await launchUrl(Uri.parse(storeUrl),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  label: const Text("Update Now"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Maybe Later"),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

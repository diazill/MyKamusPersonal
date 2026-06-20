import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/firestore_service.dart';
import '../widgets/update_dialog.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final firestoreService = FirestoreService();
      
      // 1. Get latest version info from Firestore
      final updateInfo = await firestoreService.checkUpdate();
      if (updateInfo == null) return;
      
      final String latestVersion = updateInfo['latest_version'] ?? '0.0.0';
      final String apkUrl = updateInfo['apk_url'] ?? '';
      final String exeUrl = updateInfo['exe_url'] ?? '';
      final String releaseNotes = updateInfo['release_notes'] ?? 'Ada pembaruan baru.';
      final bool isMandatory = updateInfo['is_mandatory'] ?? false;
      
      // 2. Get current app version
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      
      // 3. Compare versions
      if (_isNewerVersion(currentVersion, latestVersion)) {
        // Determine the download URL based on platform
        String downloadUrl = '';
        if (Platform.isAndroid) {
          downloadUrl = apkUrl;
        } else if (Platform.isWindows) {
          downloadUrl = exeUrl;
        }
        
        // If there's a valid URL for the current platform, show the dialog
        if (downloadUrl.isNotEmpty && context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: !isMandatory, // Prevent dismiss if mandatory
            builder: (context) => UpdateDialog(
              latestVersion: latestVersion,
              releaseNotes: releaseNotes,
              downloadUrl: downloadUrl,
              isMandatory: isMandatory,
            ),
          );
        }
      }
    } catch (e) {
      print('UpdateChecker error: $e');
    }
  }

  // Simple version comparison logic (e.g. "1.0.1" vs "1.0.2")
  static bool _isNewerVersion(String currentVersion, String latestVersion) {
    List<String> currentParts = currentVersion.split('.');
    List<String> latestParts = latestVersion.split('.');

    for (int i = 0; i < currentParts.length && i < latestParts.length; i++) {
      int currentPart = int.tryParse(currentParts[i]) ?? 0;
      int latestPart = int.tryParse(latestParts[i]) ?? 0;

      if (latestPart > currentPart) {
        return true; // Latest is newer
      } else if (latestPart < currentPart) {
        return false; // Current is newer
      }
    }
    
    // If we get here, they are equal up to the checked parts.
    // e.g. "1.0" vs "1.0.1"
    return latestParts.length > currentParts.length;
  }
}

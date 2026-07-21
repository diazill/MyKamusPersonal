import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/firestore_service.dart';
import '../widgets/update_dialog.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context, {bool manualCheck = false}) async {
    try {
      final firestoreService = FirestoreService();
      
      // 1. Get latest version info from Firestore
      final updateInfo = await firestoreService.checkUpdate();
      if (updateInfo == null) {
        if (manualCheck && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda sudah menggunakan versi terbaru.')),
          );
        }
        return;
      }
      
      final String latestVersion = updateInfo['latest_version'] ?? '0.0.0';
      final String versionWithoutBuild = latestVersion.contains('+') ? latestVersion.split('+')[0] : latestVersion;
      
      final String apkUrl = updateInfo['apk_url']?.toString().isNotEmpty == true 
          ? updateInfo['apk_url'] 
          : 'https://github.com/diazill/MyKamusPersonal/releases/download/v$versionWithoutBuild/app-release.apk';
          
      final String exeUrl = updateInfo['exe_url']?.toString().isNotEmpty == true 
          ? updateInfo['exe_url'] 
          : 'https://github.com/diazill/MyKamusPersonal/releases/download/v$versionWithoutBuild/MyKamusPersonal_Installer_v$versionWithoutBuild.exe';
          
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
        } else if (context.mounted && manualCheck) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ada versi baru ($latestVersion) namun link unduhan belum tersedia di database.')),
          );
        }
      } else {
        if (manualCheck && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anda sudah menggunakan versi terbaru. (Lokal: $currentVersion, Server: $latestVersion)')),
          );
        }
      }
    } catch (e) {
      print('UpdateChecker error: $e');
      if (manualCheck && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memeriksa pembaruan: $e')),
        );
      }
    }
  }

  // Simple version comparison logic (e.g. "1.0.1" vs "1.0.2")
  static bool _isNewerVersion(String currentVersion, String latestVersion) {
    List<int> parseVersion(String version) {
      String v = version;
      int build = 0;
      if (v.contains('+')) {
        var parts = v.split('+');
        v = parts[0];
        build = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      }
      List<String> parts = v.split('.');
      int major = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0;
      int minor = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      int patch = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
      return [major, minor, patch, build];
    }

    List<int> current = parseVersion(currentVersion);
    List<int> latest = parseVersion(latestVersion);

    for (int i = 0; i < 4; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    
    return false;
  }
}

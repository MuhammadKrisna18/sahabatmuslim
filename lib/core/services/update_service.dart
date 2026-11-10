import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adhan_reminder/core/constants/api_constants.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String title;
  final String changelog;
  final String? downloadUrl;
  final String htmlUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.title,
    required this.changelog,
    required this.downloadUrl,
    required this.htmlUrl,
    required this.hasUpdate,
  });
}

class UpdateService {
  final Dio _dio = Dio();
  static const String _repoOwner = ApiConstants.githubRepoOwner;
  static const String _repoName = ApiConstants.githubRepoName;

  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return '1.0.0';
    }
  }

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      const url = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final tagName = (data['tag_name'] as String? ?? '').replaceAll('v', '').trim();
        final title = data['name'] as String? ?? 'Pembaruan Tersedia';
        final changelog = data['body'] as String? ?? 'Perbaikan bug dan peningkatan performa.';
        final htmlUrl = data['html_url'] as String? ?? 'https://github.com/$_repoOwner/$_repoName/releases';

        String? downloadUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null && assets.isNotEmpty) {
          for (final asset in assets) {
            final assetName = (asset['name'] as String? ?? '').toLowerCase();
            if (assetName.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }

        final hasUpdate = _isNewerVersion(currentVersion, tagName);

        return UpdateInfo(
          latestVersion: tagName,
          currentVersion: currentVersion,
          title: title,
          changelog: changelog,
          downloadUrl: downloadUrl,
          htmlUrl: htmlUrl,
          hasUpdate: hasUpdate,
        );
      }
    } catch (e) {
      debugPrint('UpdateService check error: $e');
    }
    return null;
  }

  bool _isNewerVersion(String current, String remote) {
    if (remote.isEmpty) return false;

    try {
      final cleanCurrent = current.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanRemote = remote.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '');

      final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final remoteParts = cleanRemote.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
    } catch (_) {}

    return false;
  }

  Future<void> openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<String?> downloadApk(
    String downloadUrl,
    String fileName, {
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      Directory? targetDir;
      try {
        final extDirs = await getExternalCacheDirectories();
        if (extDirs != null && extDirs.isNotEmpty) {
          targetDir = extDirs.first;
        }
      } catch (_) {}
      targetDir ??= await getTemporaryDirectory();

      final filePath = '${targetDir.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );

      return filePath;
    } catch (e) {
      debugPrint('Download APK error: $e');
      return null;
    }
  }

  Future<bool> installApk(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final result = await OpenFilex.open(
          filePath,
          type: 'application/vnd.android.package-archive',
        );
        return result.type == ResultType.done;
      }
    } catch (e) {
      debugPrint('Install APK error: $e');
    }
    return false;
  }
}


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/services/update_service.dart';

enum DownloadStatus { initial, downloading, downloaded, failed }

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final UpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
  });

  static Future<void> show(
    BuildContext context, {
    required UpdateInfo updateInfo,
    required UpdateService updateService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        updateService: updateService,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  DownloadStatus _status = DownloadStatus.initial;
  double _progress = 0.0;
  String _progressText = '';
  String? _downloadedFilePath;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _startDownload() async {
    final downloadUrl = widget.updateInfo.downloadUrl;
    if (downloadUrl == null) {
      widget.updateService.openInBrowser(widget.updateInfo.htmlUrl);
      return;
    }

    setState(() {
      _status = DownloadStatus.downloading;
      _progress = 0.0;
      _progressText = 'Memulai unduhan...';
    });

    _cancelToken = CancelToken();
    final fileName = 'sahabatmuslim-v${widget.updateInfo.latestVersion}.apk';

    final filePath = await widget.updateService.downloadApk(
      downloadUrl,
      fileName,
      cancelToken: _cancelToken,
      onProgress: (received, total) {
        if (total > 0 && mounted) {
          setState(() {
            _progress = received / total;
            final receivedMB = (received / (1024 * 1024)).toStringAsFixed(1);
            final totalMB = (total / (1024 * 1024)).toStringAsFixed(1);
            final percentage = (_progress * 100).toInt();
            _progressText = '$percentage% ($receivedMB MB / $totalMB MB)';
          });
        }
      },
    );

    if (!mounted) return;

    if (filePath != null) {
      setState(() {
        _status = DownloadStatus.downloaded;
        _downloadedFilePath = filePath;
      });
      // Auto trigger installer
      await widget.updateService.installApk(filePath);
    } else {
      setState(() {
        _status = DownloadStatus.failed;
        _progressText = 'Gagal mengunduh berkas.';
      });
    }
  }

  Future<void> _installDownloadedApk() async {
    if (_downloadedFilePath != null) {
      final success = await widget.updateService.installApk(_downloadedFilePath!);
      if (!success && mounted) {
        // Fallback to browser
        widget.updateService.openInBrowser(widget.updateInfo.htmlUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.grey[850] : Colors.grey[100];

    return PopScope(
      canPop: _status != DownloadStatus.downloading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Center(
                child: Text(
                  'Pembaruan Tersedia! 🚀',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Version Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'v${widget.updateInfo.currentVersion}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'v${widget.updateInfo.latestVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Changelog Box
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Pembaruan:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.updateInfo.changelog.trim().isEmpty
                            ? 'Peningkatan performa dan kestabilan aplikasi.'
                            : widget.updateInfo.changelog,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Download Status / Progress
              if (_status == DownloadStatus.downloading) ...[
                LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  _progressText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ] else if (_status == DownloadStatus.failed) ...[
                Text(
                  _progressText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              if (_status == DownloadStatus.initial) ...[
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text('Perbarui Sekarang', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
                ),
              ] else if (_status == DownloadStatus.downloading) ...[
                OutlinedButton(
                  onPressed: () {
                    _cancelToken?.cancel();
                    setState(() => _status = DownloadStatus.initial);
                  },
                  child: const Text('Batalkan Unduhan'),
                ),
              ] else if (_status == DownloadStatus.downloaded) ...[
                ElevatedButton.icon(
                  onPressed: _installDownloadedApk,
                  icon: const Icon(Icons.install_mobile_rounded, color: Colors.white),
                  label: const Text('Pasang Pembaruan', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
                ),
              ] else if (_status == DownloadStatus.failed) ...[
                ElevatedButton.icon(
                  onPressed: () => widget.updateService.openInBrowser(widget.updateInfo.htmlUrl),
                  icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
                  label: const Text('Buka via Browser', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/core/di/injection.dart';
import 'package:adhan_reminder/core/services/update_service.dart';
import 'package:adhan_reminder/core/widgets/update_dialog.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentVersion = '...';
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await getIt<UpdateService>().getCurrentVersion();
    if (mounted) {
      setState(() {
        _currentVersion = version;
      });
    }
  }

  Future<void> _manualCheckUpdate() async {
    if (_isCheckingUpdate) return;

    setState(() {
      _isCheckingUpdate = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memeriksa pembaruan dari GitHub...'),
        duration: Duration(seconds: 2),
      ),
    );

    final updateService = getIt<UpdateService>();
    final updateInfo = await updateService.checkForUpdate();

    if (!mounted) return;

    setState(() {
      _isCheckingUpdate = false;
    });

    if (updateInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memeriksa pembaruan. Pastikan internet Anda aktif.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else if (updateInfo.hasUpdate) {
      UpdateDialog.show(
        context,
        updateInfo: updateInfo,
        updateService: updateService,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aplikasi sudah versi terbaru (v${updateInfo.currentVersion}) 🎉'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tampilan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Tema Aplikasi'),
                subtitle: const Text('Pilih mode terang, gelap, atau otomatis'),
                trailing: DropdownButton<ThemeMode>(
                  value: provider.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      provider.setThemeMode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Sistem'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Terang'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Gelap'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Ukuran Teks Al-Qur\'an',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Teks Arab'),
                subtitle: Slider(
                  value: provider.arabicFontSize,
                  min: 20.0,
                  max: 60.0,
                  divisions: 8,
                  label: provider.arabicFontSize.round().toString(),
                  onChanged: (value) => provider.setArabicFontSize(value),
                  activeColor: AppColors.primary,
                ),
              ),
              ListTile(
                title: const Text('Teks Latin/Terjemahan'),
                subtitle: Slider(
                  value: provider.latinFontSize,
                  min: 10.0,
                  max: 24.0,
                  divisions: 7,
                  label: provider.latinFontSize.round().toString(),
                  onChanged: (value) => provider.setLatinFontSize(value),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Tentang & Pembaruan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('Versi Aplikasi'),
                subtitle: Text('Sahabat Muslim v$_currentVersion'),
              ),
              ListTile(
                leading: _isCheckingUpdate
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.system_update, color: AppColors.primary),
                title: const Text('Periksa Pembaruan'),
                subtitle: const Text('Cek apakah ada versi terbaru di GitHub Release'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isCheckingUpdate ? null : _manualCheckUpdate,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            ],
          );
        },
      ),
    );
  }
}

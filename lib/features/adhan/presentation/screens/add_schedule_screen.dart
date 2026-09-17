import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class AddScheduleScreen extends StatefulWidget {
  final AdhanSchedule existingSchedule;

  const AddScheduleScreen({super.key, required this.existingSchedule});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  TimeOfDay? _selectedTime;
  String? _selectedSoundName;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  String? _customSoundPath;
  Uint8List? _customSoundBytes;
  final TextEditingController _customNameController = TextEditingController(text: 'File Suara Sendiri');

  final List<Map<String, String>> _availableSounds = [
    {
      'name': 'Adzan Azzam Dweik',
      'url': 'assets/adzan_azzam_dweik.mp3'
    },
    {
      'name': 'Pilihan Sendiri (Dari HP)',
      'url': 'custom'
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay(hour: widget.existingSchedule.hour, minute: widget.existingSchedule.minute);


    _audioPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        usageType: AndroidUsageType.alarm,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.gainTransient,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.duckOthers},
      ),
    ));

    if (widget.existingSchedule.isLocal) {
      _selectedSoundName = 'Pilihan Sendiri (Dari HP)';
      _customSoundPath = widget.existingSchedule.soundUrl;
      _customNameController.text = widget.existingSchedule.soundName;
    } else {
      _selectedSoundName = widget.existingSchedule.soundName;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        _selectedSoundName = 'Pilihan Sendiri (Dari HP)';
        if (kIsWeb) {
          _customSoundBytes = result.files.single.bytes;
          _customSoundPath = result.files.single.name;
        } else {
          _customSoundPath = result.files.single.path;
        }

        _customNameController.text = result.files.single.name.split('.').first;
      });
    }
  }

  void _previewSound() async {
    if (_selectedSoundName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih suara adzan terlebih dahulu!')),
      );
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_selectedSoundName == 'Pilihan Sendiri (Dari HP)') {
        if (_customSoundPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih file audio terlebih dahulu!')),
          );
          return;
        }

        final provider = Provider.of<AdhanProvider>(context, listen: false);
        await _audioPlayer.setVolume(provider.globalVolume);
        if (kIsWeb && _customSoundBytes != null) {
          await _audioPlayer.play(BytesSource(_customSoundBytes!));
        } else {
          await _audioPlayer.play(DeviceFileSource(_customSoundPath!));
        }
      } else {
        final selectedSound = _availableSounds.firstWhere(
          (s) => s['name'] == _selectedSoundName,
        );
        final provider = Provider.of<AdhanProvider>(context, listen: false);
        await _audioPlayer.setVolume(provider.globalVolume);
        if (selectedSound['url']!.startsWith('assets/')) {
          await _audioPlayer.play(AssetSource(selectedSound['url']!.replaceFirst('assets/', '')));
        } else {
          await _audioPlayer.play(UrlSource(selectedSound['url']!));
        }
      }

      setState(() {
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  void _saveSchedule() async {

    if (_selectedTime == null || _selectedSoundName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Jam dan Suara Adzan wajib dipilih!')),
      );
      return;
    }

    if (_selectedSoundName == 'Pilihan Sendiri (Dari HP)' && _customSoundPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Anda belum memilih file audio!')),
      );
      return;
    }

    final isCustom = _selectedSoundName == 'Pilihan Sendiri (Dari HP)';
    String finalUrl = '';

    if (isCustom) {
      finalUrl = _customSoundPath!;
    } else {
      final selectedSound = _availableSounds.firstWhere(
        (s) => s['name'] == _selectedSoundName,
      );
      finalUrl = selectedSound['url']!;
    }

    final scheduleToSave = AdhanSchedule(
      id: widget.existingSchedule.id,
      hour: _selectedTime!.hour,
      minute: _selectedTime!.minute,
      soundName: isCustom
          ? (_customNameController.text.trim().isEmpty ? 'File Suara Sendiri' : _customNameController.text.trim())
          : _selectedSoundName!,
      soundUrl: finalUrl,
      isLocal: isCustom,
      isActive: widget.existingSchedule.isActive,
      volume: widget.existingSchedule.volume,
    );

    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Konfirmasi Perubahan',
            style: TextStyle(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menyimpan pengaturan adzan ini?',
            style: TextStyle(
              color: context.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => context.pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      if (!mounted) return;
      context.pop(scheduleToSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        title: Text(
          'Pengaturan ${widget.existingSchedule.id}',
          style: GoogleFonts.amiri(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: AppColors.primary.withOpacity(0.1),
              height: 1.0,
            ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                leading: Icon(Icons.access_time_filled, size: 40, color: AppColors.primary),
                title: Text(
                  'Waktu Adzan ${widget.existingSchedule.id}',
                  style: TextStyle(color: context.textSecondaryColor, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _selectedTime!.format(context),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                trailing: Icon(Icons.lock_outline, color: AppColors.primary.withOpacity(0.3), size: 30),
              ),
            ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 30),

            const Text(
              'Pilih Suara Adzan (*Wajib):',
              style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold),
            ).animate().fade(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: context.backgroundColor,
                        value: _selectedSoundName,
                        hint: Text('Pilih Suara', style: TextStyle(color: Color(0xFF94A3B8))),
                        icon: Icon(Icons.arrow_drop_down, color: context.textSecondaryColor),
                        style: TextStyle(color: context.textPrimaryColor, fontSize: 16),
                        isExpanded: true,
                        items: _availableSounds.map((sound) {
                          return DropdownMenuItem(
                            value: sound['name'],
                            child: Text(sound['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSoundName = value;
                            });
                            if (_isPlaying) {
                              _audioPlayer.stop();
                              setState(() {
                                _isPlaying = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _isPlaying ? Colors.red.withOpacity(0.3) : AppColors.primary.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                    ]
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                      size: 54,
                      color: _isPlaying ? Colors.redAccent : AppColors.primary,
                    ),
                    onPressed: _previewSound,
                  ),
                ),
              ],
            ).animate().fade(delay: 300.ms, duration: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOut),

            if (_selectedSoundName == 'Pilihan Sendiri (Dari HP)')
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _pickCustomFile,
                      icon: const Icon(Icons.folder_open),
                      label: Text(
                        _customSoundPath == null
                          ? 'Telusuri File Audio... (*Wajib)'
                          : 'File: ${_customSoundPath!.split('/').last.split('\\').last}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                    if (_customSoundPath != null)
                      TextField(
                        controller: _customNameController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: InputDecoration(
                          labelText: 'Nama Suara (Bisa diubah)',
                          labelStyle: TextStyle(color: context.textSecondaryColor),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
                          filled: true,
                          fillColor: AppColors.primary.withOpacity(0.05),
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              onPressed: _saveSchedule,
              child: const Text(
                'SIMPAN PENGATURAN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ).animate().fade(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}

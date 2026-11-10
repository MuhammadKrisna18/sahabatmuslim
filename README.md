# Sahabat Muslim 🕌

Aplikasi pendamping ibadah Muslim modern, lengkap, dan hemat daya berbasis Flutter. Dirancang dengan prinsip Clean Architecture untuk performa optimal, antarmuka elegan, serta keandalan tinggi saat digunakan sehari-hari.

---

## ✨ Fitur Unggulan

### 1. 🔔 Jadwal Sholat & Adzan Otomatis
- **Perhitungan Akurat Berbasis Lokasi**: Menggunakan koordinat GPS perangkat dengan algoritma waktu sholat presisi (Subuh, Terbit, Dzuhur, Ashar, Maghrib, Isya).
- **Alarm & Notifikasi Tepat Waktu**: Pengingat alarm otomatis saat waktu sholat tiba dengan toleransi alarm eksak Android.
- **Dukungan Hari Jum'at**: Otomatis mendeteksi waktu sholat Dzuhur sebagai sholat Jum'at pada hari Jum'at.
- **Kustomisasi Suara Adzan**: Pilihan suara adzan bawaan serta kemampuan memilih file audio kustom langsung dari penyimpanan lokal perangkat.
- **Hemat Baterai**: Arsitektur state management reaktif dengan pembaharuan detik terisolasi (`ValueNotifier`) agar tidak memicu rebuild berulang pada widget tree utama.

### 2. 🧭 Kompas Arah Kiblat Presisi
- **Sensor Magnetometer Terintegrasi**: Mengarahkan perangkat ke Ka'bah secara real-time dengan sudut presisi.
- **Indikator Visual & Haptic**: Notifikasi visual ketika arah jarum kompas telah sejajar dan tepat mengarah ke Ka'bah.
- **Responsif Terhadap Notch & Navigation Bar**: Tata letak adaptif yang nyaman digunakan di berbagai ukuran layar.

### 3. 📖 Al-Qur'an Digital & Audio Murottal
- **30 Juz & 114 Surah Lengkap**: Teks Arab standar Kemenag/Madinah, transliterasi Latin, dan terjemahan bahasa Indonesia lengkap.
- **Multi-Qori Murottal**: Pilihan lantunan murottal dari qori ternama dunia (Syeikh Mishary Rashid Alafasy, Abdurrahman As-Sudais, Maher Al-Muaiqly, Alaa Aqel, dan lainnya).
- **Mode Offline (Download Murottal)**: Unduh surah pilihan ke penyimpanan lokal agar dapat didengarkan kapan saja tanpa kuota internet.
- **Pembersihan File Otomatis**: Menghapus file sementara/korup secara otomatis jika proses pengunduhan terputus atau gagal.
- **Penanda Terakhir Dibaca (Bookmark)**: Akses cepat untuk melanjutkan bacaan terakhir langsung dari halaman utama Al-Qur'an.
- **Kustomisasi Tipografi**: Pengaturan ukuran font Arab dan Latin sesuai kenyamanan mata pengguna.

### 4. 🤲 Kumpulan Doa & Dzikir Harian
- Koleksi doa harian lengkap beserta lafal Arab, transliterasi Latin, dan terjemahan.
- Animasi bertahap yang halus dan efisien dengan scrolling bebas hambatan.

### 5. 🧎 Panduan Tata Cara Sholat
- Panduan visual dan teks langkah demi langkah sholat wajib dan sunnah.
- Disertai bacaan niat, takbiratul ihram, ruku', sujud, hingga salam.

### 6. 🚀 Notifikasi Pembaruan Otomatis (In-App Auto Update)
- Mendeteksi rilis versi terbaru langsung dari GitHub Releases secara otomatis saat aplikasi dibuka atau melalui menu Pengaturan.
- Menampilkan dialog update interaktif berisi catatan rilis (changelog) dan tombol unduh APK langsung.

---

## 🏗️ Arsitektur & Teknologi

Proyek ini dibangun menggunakan **Clean Architecture** yang memisahkan tanggung jawab kode ke dalam tiga layer utama:

```
lib/
├── core/                  # Utilitas bersama, konfigurasi tema, routing, dan layanan sistem
│   ├── constants/         # Konstanta warna, string, dan endpoint API
│   ├── di/                # Dependency Injection menggunakan GetIt
│   ├── network/           # Client HTTP dan penanganan koneksi
│   ├── routes/            # Konfigurasi routing menggunakan GoRouter
│   ├── services/          # Service alarm, notifikasi, dan auto-update
│   ├── theme/             # Tema terang (Light) dan gelap (Dark)
│   └── widgets/           # Komponen widget global (GlassCard, DynamicScaffold, dsb.)
└── features/              # Fitur modular (Setiap fitur dibagi per layer)
    ├── adhan/             # Fitur jadwal adzan & alarm sholat
    ├── qibla/             # Fitur kompas arah kiblat
    ├── quran/             # Fitur Al-Qur'an digital & pemutar audio murottal
    ├── doa/               # Fitur doa dan dzikir harian
    ├── sholat/            # Fitur tata cara sholat
    └── settings/          # Fitur pengaturan tipografi dan preferensi
        ├── data/          # Datasources, Models, dan Implementasi Repository
        ├── domain/        # Entities, Use Cases, dan Kontrak Repository
        └── presentation/  # Providers (State Management), Screens, dan Widgets
```

### Tech Stack
- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.5.4`)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Audio Engine**: [audioplayers](https://pub.dev/packages/audioplayers)
- **Animasi & UI**: [flutter_animate](https://pub.dev/packages/flutter_animate), [google_fonts](https://pub.dev/packages/google_fonts), [shimmer](https://pub.dev/packages/shimmer)
- **Testing**: `flutter_test`, `mocktail` (19 Unit Tests & Integration Tests)

---

## 🔄 CI/CD Pipeline (GitHub Actions)

Proyek ini dilengkapi alur otomatisasi rilis berbasis GitHub Actions (`.github/workflows/release.yml`):
1. **Trigger**: Otomatis aktif saat tag rilis di-push (misal: `git push origin v1.0.1`).
2. **Build**: Melakukan `flutter pub get`, verifikasi `flutter analyze`, menjalankan `flutter test`, dan mengompilasi APK rilis (`flutter build apk --release`).
3. **Publish**: Mengunggah APK yang dihasilkan ke GitHub Releases secara otomatis sehingga pengguna aplikasi langsung menerima notifikasi update di HP masing-masing.

---

## 🚀 Panduan Memulai (Developer Setup)

### Prasyarat
- Flutter SDK (versi >= 3.5.4)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK Platform 34+

### Langkah Instalasi
1. Clone repositori ini:
   ```bash
   git clone https://github.com/MuhammadKrisna18/sahabatmuslim.git
   cd sahabatmuslim
   ```

2. Unduh semua dependensi:
   ```bash
   flutter pub get
   ```

3. Jalankan linter dan unit testing:
   ```bash
   flutter analyze
   flutter test
   ```

4. Jalankan aplikasi di emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

### Build APK Rilis Secara Manual
```bash
flutter build apk --release
```
File APK siap instal akan tersedia di direktori `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📚 Sumber Data Terbuka
- **Audio Murottal**: [MP3Quran.net](https://www.mp3quran.net) & [Archive.org](https://archive.org/details/AlaaAql) (Lisensi Public Domain / Non-Commercial).
- **Teks Al-Qur'an & Terjemahan**: Format JSON terverifikasi tersimpan secara lokal di dalam aset aplikasi.

---

## 📄 Lisensi
Dikelola di bawah lisensi terbuka untuk tujuan edukasi, dakwah, dan pemanfaatan publik yang bermanfaat.

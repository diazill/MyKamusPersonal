# 🌸 MyKamusPersonal (Zen Scholar)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

## 📖 Overview
**MyKamusPersonal** (dengan tema desain *Zen Scholar*) adalah aplikasi pencatatan dan manajemen kosakata bahasa Jepang pribadi. Aplikasi ini dirancang untuk membantu pembelajar bahasa Jepang mencatat, melacak, dan mengelola kata (Kosakata) maupun kalimat bahasa Jepang yang sedang dipelajari, lengkap dengan sistem pengulangan berkala (SRS - Spaced Repetition System). Aplikasi ini mengusung desain *Glassmorphism* modern yang bersih dan elegan.

## ⚙️ Spesifikasi Teknis
- **Framework:** Flutter (Dart)
- **Database / Backend:** Firebase Cloud Firestore
- **Target Platform:** Android (APK) & Windows Desktop (.exe Installer via Inno Setup)
- **UI/UX:** Zen Scholar Design System (Glassmorphism & Modern Typography with Google Fonts)
- **Key Dependencies:** 
  - `firebase_core` & `cloud_firestore` (Data storage & sync)
  - `animated_notch_bottom_bar` (Navigasi modern)
  - `file_picker` (Fitur import data)
  - `google_fonts` (Tipografi modern)

## ✨ Fitur Utama
- **📊 Beranda (Dashboard):** Menampilkan statistik dinamis dan ringkasan pembelajaran secara real-time.
- **📚 Pustaka (Library):** Daftar lengkap kata dan kalimat yang telah disimpan, mendukung fitur pencarian dan filter.
- **➕ Tambah Data (Multi-tab):** Form input komprehensif dengan antarmuka tab untuk memisahkan input **Kata** dan **Kalimat**. Mendukung isian detail: *Teks Jepang (Kanji/Kana), Cara Baca, Arti, Romaji, Catatan Tambahan, Tag, Level SRS, dan Jadwal Review Selanjutnya*.
- **📥 Import Data:** Memungkinkan pengguna untuk mengimpor daftar kosakata secara massal melalui file JSON dengan indikator progres yang responsif.
- **⚙️ Setelan (Settings):** Pengaturan aplikasi dan manajemen data.
- **🔔 Notifikasi Terpusat:** Sistem notifikasi in-app (Snackbar) yang konsisten dan elegan di seluruh aplikasi.

## 🚀 Cara Download & Instalasi

### Untuk Pengguna (End-User)
Aplikasi ini dirancang untuk Android dan Windows.
- **Android:** Buka tab **Releases** di GitHub ini, unduh file `.apk`, dan instal di perangkat Android Anda (pastikan opsi "Install from Unknown Sources" aktif).
- **Windows:** Buka tab **Releases**, unduh file *Installer* `.exe`, dan jalankan untuk menginstal aplikasi di PC Anda.

### Untuk Developer (Menjalankan dari Source Code)
1. **Prasyarat:** Pastikan Anda telah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install) dan memiliki project Firebase yang sudah disiapkan.
2. **Clone Repository:**
   ```bash
   git clone https://github.com/USERNAME_ANDA/myKamusPersonal.git
   cd myKamusPersonal
   ```
3. **Konfigurasi Firebase:**
   Pastikan Anda telah melakukan *setup* Firebase untuk Flutter (menambahkan `google-services.json` dsb) dan menyesuaikan `firebase_options.dart` dengan environment Anda.
4. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
5. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

## 🤝 Panduan Kontribusi (Contributing)
Kami menyambut kontribusi dari siapa saja! Jika Anda ingin menambahkan fitur, memperbaiki bug, atau meningkatkan kode, silakan ikuti langkah berikut:

1. **Fork** repository ini.
2. Buat *branch* baru untuk fitur atau perbaikan Anda:
   ```bash
   git checkout -b fitur-keren-saya
   ```
3. Lakukan perubahan pada kode dan buat *commit*:
   ```bash
   git commit -m 'Menambahkan fitur keren'
   ```
4. **Push** ke *branch* tersebut di fork Anda:
   ```bash
   git push origin fitur-keren-saya
   ```
5. Buka **Pull Request** di repository utama ini.

Pastikan kode Anda mengikuti standar *linting* Flutter yang digunakan dalam project ini dengan menjalankan `flutter analyze` sebelum membuat Pull Request.

# Gift_Bouquet

## Deskripsi Proyek

**Gift_Bouquet** adalah aplikasi mobile berbasis Flutter yang dirancang untuk memudahkan pengguna dalam memesan dan membeli berbagai macam hadiah dan bunga secara online. Aplikasi ini menyediakan antarmuka yang intuitif dan fitur lengkap, mulai dari penjelajahan produk, proses pemesanan yang efisien, hingga manajemen notifikasi promosi.

Di sisi lain, aplikasi ini juga dilengkapi dengan panel admin untuk pengelolaan produk, pemantauan transaksi, dan pencetakan laporan, memastikan operasional bisnis yang lancar dan terorganisir.

## Fitur Utama

### Untuk Pengguna
- **Autentikasi & Profil:**
    - Login, Register, Logout
    - Melihat dan Mengedit Profil Pengguna
- **Manajemen Produk:**
    - Melihat Daftar Produk hadiah dan bunga
    - Memesan Produk dengan detail jumlah, alamat, dan metode pembayaran
    - Membayar Pesanan
- **Riwayat & Notifikasi:**
    - Melihat Riwayat Transaksi yang telah dilakukan
    - Melihat Riwayat Notifikasi Promosi yang diterima
    - Membersihkan Riwayat Notifikasi Promosi
- **Utilitas:**
    - Mendeteksi Gerak Perangkat (misal: goyangan) sebagai pemicu notifikasi promosi
    - Melihat Lokasi Toko di peta

### Untuk Admin
- **Autentikasi & Profil:**
    - Login, Logout
    - Melihat dan Mengedit Profil Admin
- **Manajemen Produk:**
    - Menambah, Mengedit, dan Menghapus Data Produk
    - Melihat Daftar Produk untuk tujuan manajemen
- **Manajemen Transaksi:**
    - Melihat Daftar Transaksi pengguna
    - Mengelola Status Transaksi (memverifikasi pembayaran, membatalkan, dll.)
    - Mencetak Laporan Transaksi

## Teknologi yang Digunakan

### Frontend (Aplikasi Mobile)
- **Framework:** Flutter (dengan bahasa Dart)
- **State Management:** (Implied, could be Provider, BLoC, etc. - based on project structure)
- **HTTP Client:** `http` package
- **Local Storage:** `shared_preferences` (untuk menyimpan notifikasi dan data pengguna lokal)
- **Notifications:** `flutter_local_notifications`
- **Sensors:** `sensors_plus` (untuk accelerometer)
- **Mapping & Location:** `flutter_map`, `geolocator`, `latlong2`, `geocoding`
- **Image Handling:** `image_picker`
- **UI/UX Components:** `accordion`, `google_fonts`, `email_validator`, `uuid`

### Backend (API Server)
- **Runtime:** Node.js
- **Web Framework:** Express.js
- **ORM (Object-Relational Mapping):** Sequelize
- **Database:** Relasional (misalnya PostgreSQL, MySQL/MariaDB)
- **Authentication:** JSON Web Tokens (JWT)
- **Password Hashing:** (Diasumsikan menggunakan algoritma hashing standar seperti Bcrypt)
- **Deployment Platform:** Google Cloud Run

## Cara Instalasi dan Menjalankan Proyek

### Prasyarat
- Flutter SDK terinstal (versi minimal 3.7.0)
- Node.js dan npm/yarn terinstal
- Akses ke server database (lokal atau cloud)
- Kredensial untuk akses ke backend API yang sudah di-deploy.

### Langkah-langkah Frontend (Flutter App)

1.  **Clone Repositori:**
    ```bash
    git clone <URL_REPO_GITHUB_ANDA>
    cd gift_bouqet
    ```
2.  **Install Dependensi Flutter:**
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi Lingkungan (jika ada API Key/URL spesifik):**
    Pastikan URL backend API yang digunakan di `lib/service/transaksiService.dart` dan `lib/service/userService.dart` sudah benar mengarah ke deployment backend Anda.
4.  **Jalankan Aplikasi:**
    ```bash
    flutter run
    ```
    Atau jalankan melalui IDE (VS Code / Android Studio).

## Kontribusi

Kontribusi disambut baik! Jika Anda memiliki saran atau menemukan bug, silakan buka *issue* atau kirim *pull request*.

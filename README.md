# SpeakUp

SpeakUp adalah aplikasi pelaporan dan penanganan perundungan (*bullying*) di sekolah. Aplikasi ini membantu siswa menyampaikan laporan secara lebih aman, mendukung pelaporan anonim dan unggah bukti, serta membantu Guru BK melakukan validasi, mediasi, tindak lanjut, dan pencatatan kasus secara terstruktur.

Aplikasi ini terdiri dari tiga bagian utama:

1. **SpeakUp Backend**: Layanan backend berbasis Supabase untuk database, autentikasi, penyimpanan berkas, dan pengelolaan data.
2. **SpeakUp Mobile**: Aplikasi mobile berbasis Flutter untuk Android dan iOS (`speakup_mobile/`).
3. **SpeakUp Web**: Aplikasi web berbasis Flutter untuk browser (`speakup_web/`).

## Anggota Tim dan Pembagian Peran

* Bagus Purboyo (2300016116) — Front-end Developer
* Meylani (2400016012) — UI/UX Designer dan Dokumentasi
* Ariani Putri Andini (2400016018) — UI/UX Designer dan Dokumentasi
* M. Anang Alief Al Ikhsan (2438016017) — Back-end Developer

## Teknologi yang Digunakan

* **Frontend Mobile:** Flutter dan Dart
* **Frontend Web:** Flutter Web dan Dart
* **Backend dan Database:** Supabase
* **Autentikasi:** Supabase Auth
* **Penyimpanan Berkas:** Supabase Storage
* **Komunikasi Data:** Supabase Client/API
* **Desain UI/UX:** Figma
* **Version Control:** Git dan GitHub
* **Dokumentasi:** Markdown, DOCX, dan PDF

## Perubahan Terbaru

Sejak pembaruan terakhir, berikut fitur dan perbaikan yang telah ditambahkan:

### 1. Manajemen Pengguna Admin

* Menambahkan **CRUD penuh pengguna** untuk role Admin, meliputi tambah, edit, hapus, dan ubah role.
* Menambahkan *Action Menu* pada daftar pengguna agar Admin dapat mengubah data diri dan kata sandi pengguna.
* Menyesuaikan layout tab Admin dengan menghapus tab **Pengaturan** pada *bottom navigation* karena pengaturan akun dipindahkan ke halaman Profil.
* Memindahkan ikon **Notifikasi** untuk Admin ke sudut kanan atas (*AppBar*) agar konsisten dengan tampilan Kepala Sekolah dan Orang Tua.

### 2. Fitur Laporan dan Mediasi

* Menyempurnakan antarmuka halaman Detail Laporan.
* Menambahkan fitur penyelesaian mediasi melalui tombol **Selesaikan Mediasi**.
* Menerapkan pembatasan wewenang agar validasi dan penyelesaian laporan hanya dapat dilakukan oleh Guru BK.
* Admin tidak memiliki hak untuk memvalidasi atau menyelesaikan laporan.

### 3. Halaman dan UI Baru

* Menambahkan halaman Statistik/Tren (*Trend Chart*) untuk Kepala Sekolah.
* Menambahkan halaman Pengaturan Notifikasi dan Edit Profil pada submenu Profil.

### 4. Responsivitas Aplikasi Web

* **Fixed Top Navbar:** Menambahkan navbar atas yang tetap tampil pada versi web untuk semua role dan memuat *Profile Dropdown*, Pengaturan Akun, serta Logout.
* **Teacher Dashboard:** Menyesuaikan dashboard Guru BK menggunakan *grid layout* yang responsif pada web.
* **Create Report:** Menggunakan layout dialog atau *popup* responsif pada aplikasi web tanpa memengaruhi desain aplikasi mobile.
* **Login Web:** Menambahkan fungsi tombol **Enter** pada kolom kata sandi untuk mengirim proses login secara langsung.

### 5. Backend dan Fitur Lanjutan

* Menambahkan fitur **Hubungi Mediator/Pihak Terkait** agar Guru BK dapat mengirim notifikasi kepada orang tua atau pihak terkait selama proses mediasi.
* Menambahkan proses pengambilan seluruh data mediasi pengguna yang masih aktif tanpa harus mengaksesnya melalui daftar laporan.
* Memperbaiki sinkronisasi data untuk mendukung proses mediasi dengan beberapa role pengguna.
* Menyesuaikan pengelolaan autentikasi, database, dan penyimpanan bukti menggunakan Supabase.

## Fitur Utama

* Pelaporan perundungan secara anonim.
* Pengunggahan bukti berupa foto, video, atau dokumen.
* Pelacakan perkembangan dan status laporan.
* Validasi laporan oleh Guru BK.
* Manajemen pengguna dan hak akses berdasarkan role.
* Penjadwalan dan penyelesaian mediasi.
* Pencatatan tindak lanjut kasus.
* Notifikasi kepada orang tua atau pihak terkait.
* Statistik dan tren kasus untuk Kepala Sekolah.
* Pengaturan profil dan notifikasi.
* Tampilan responsif pada aplikasi web.

## Cara Menjalankan Aplikasi

### 1. Persiapan

Pastikan perangkat telah memiliki:

* Flutter SDK
* Dart SDK
* Git
* Browser Google Chrome

Pastikan Flutter sudah terpasang dengan benar menggunakan perintah berikut:

```bash
flutter doctor
```

### 2. Mengambil Dependency

Masuk ke direktori aplikasi web, kemudian instal seluruh dependency yang dibutuhkan:

```bash
cd speakup_web
flutter pub get
```

### 3. Menjalankan Aplikasi

Jalankan aplikasi pada browser Google Chrome menggunakan konfigurasi Supabase berikut:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL="https://dnznelktfptccxudbeib.supabase.co" --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuem5lbGt0ZnB0Y2N4dWRiZWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyNzE1ODYsImV4cCI6MjA5OTg0NzU4Nn0.Cnms8zNqeI0Ge0fiuUAmICK44ZaWtioRIT0f6oKAOiM"
```

### 4. Membuat Versi Produksi Web

Untuk membuat versi produksi aplikasi web, gunakan perintah berikut:

```bash
flutter build web --dart-define=SUPABASE_URL="https://dnznelktfptccxudbeib.supabase.co" --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuem5lbGt0ZnB0Y2N4dWRiZWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyNzE1ODYsImV4cCI6MjA5OTg0NzU4Nn0.Cnms8zNqeI0Ge0fiuUAmICK44ZaWtioRIT0f6oKAOiM"
```

Hasil proses build akan tersimpan pada direktori:

```text
build/web
```

## Keamanan Konfigurasi

Aplikasi menggunakan **Supabase Anon Key** untuk menghubungkan frontend dengan layanan Supabase. Keamanan akses data tetap harus dilindungi menggunakan kebijakan **Row Level Security (RLS)** pada setiap tabel yang digunakan.

Jangan mengunggah **Supabase Service Role Key**, kata sandi database, atau informasi rahasia lainnya ke repository publik.

## URL Aplikasi yang Telah Di-deploy

https://speakupfixxx.netlify.app/

## URL Repository GitHub

https://github.com/SpeakUp-DPSI/SpeakUp-FIXXXXX

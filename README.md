# SpeakUp Prototype

SpeakUp adalah aplikasi pelaporan dan penanganan perundungan (bullying) di sekolah. Aplikasi ini terdiri dari tiga bagian utama:
1. **SpeakUp Backend**: API berbasis Laravel (`speakup_backend/`).
2. **SpeakUp Mobile**: Aplikasi mobile berbasis Flutter untuk iOS dan Android (`speakup_mobile/`).
3. **SpeakUp Web**: Aplikasi web (desktop) berbasis Flutter untuk browser (`speakup_web/`).

## Perubahan Terbaru (Update Terkini)
Sejak pull terakhir, berikut adalah fitur dan perbaikan yang ditambahkan:

### 1. Manajemen Pengguna (Admin)
- Menambahkan **CRUD Penuh Pengguna** untuk role Admin (Tambah, Edit, Hapus, dan Ubah Role).
- Menambahkan Action Menu pada daftar pengguna agar Admin dapat mengubah data diri dan kata sandi pengguna dengan mudah.
- Penyesuaian layout tab Admin: Menghapus tab "Pengaturan" pada *bottom navigation* karena pengaturan akun dipindahkan secara eksklusif ke halaman Profil.
- Ikon "Notifikasi" untuk Admin telah dipindahkan ke sudut kanan atas (*AppBar*) mengikuti desain Kepala Sekolah dan Orang Tua.

### 2. Fitur Laporan & Mediasi
- Menyempurnakan antarmuka Detail Laporan.
- Menambahkan fitur penyelesaian mediasi (`Selesaikan Mediasi`).
- Menerapkan pembatasan wewenang validasi dan penyelesaian laporan agar **hanya bisa dilakukan oleh Guru BK** (Admin tidak dapat memvalidasi/menyelesaikan laporan).

### 3. Halaman & UI Baru
- Penambahan halaman Statistik/Tren (`Trend Chart`) untuk Kepala Sekolah.
- Penambahan halaman Pengaturan Notifikasi dan Edit Profil di sub-menu Profil.

### 4. Responsivitas Aplikasi Web
- **Fixed Top Navbar:** Menambahkan navbar atas yang fixed pada Web untuk semua role yang berisi Profile Dropdown (Pengaturan Akun dan Logout) agar lebih mudah diakses.
- **Teacher Dashboard (Web):** Menyesuaikan tampilan dashboard pada web (Grid layout responsif untuk web).
- **Create Report (Web):** Mengembalikan desain Create Report pada web apps ke layout dialog/popup responsif tanpa memengaruhi desain di mobile apps.
- **Login Web:** Menambahkan fungsionalitas tombol "Enter" pada field password untuk submit login langsung di Web Apps.

### 5. Backend & Fitur Lanjutan
- **Hubungi Mediator/Pihak Terkait (Guru BK):** Penambahan endpoint baru `POST /api/mediations/{id}/contact` untuk mengirim notifikasi push ke orang tua/pihak terkait dari sisi Guru BK saat proses mediasi.
- Penambahan endpoint `GET /api/mediations` untuk mengambil seluruh mediasi user yang aktif tanpa harus mengakses dari list report.
- Perbaikan sinkronisasi respons API untuk mendukung multi-role mediasi.

# SpeakUp-Web
# SpeakUp-FIXXXXX

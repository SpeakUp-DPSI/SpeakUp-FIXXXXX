# Software Requirement Specification (SRS)
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

**Versi:** 1.0
**Repo:** SpeakUp-DPSI/SpeakUp-FIXXXXX

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini mendefinisikan kebutuhan fungsional dan non-fungsional dari aplikasi **SpeakUp**, sebuah platform pelaporan dan penanganan kasus perundungan (bullying) di lingkungan sekolah. Dokumen ini menjadi acuan pengembangan untuk tiga komponen sistem: aplikasi mobile (siswa), aplikasi web (staff sekolah), dan backend (Supabase).

### 1.2 Ruang Lingkup
SpeakUp memungkinkan siswa melaporkan kasus perundungan (termasuk secara anonim), staff sekolah (Guru BK, Kepala Sekolah, Admin) memvalidasi dan menindaklanjuti laporan melalui proses mediasi, serta orang tua memantau laporan yang diajukan oleh anaknya.

### 1.3 Definisi & Singkatan
| Istilah | Keterangan |
|---|---|
| BK | Bimbingan Konseling |
| RLS | Row Level Security (kontrol akses data di level baris tabel database) |
| SoT | Source of Truth |
| Mediasi | Proses pertemuan yang difasilitasi Guru BK untuk menyelesaikan kasus |
| Tindak Lanjut (Follow-up) | Tindakan konkret yang diambil setelah laporan divalidasi |

### 1.4 Pengguna Sistem (Aktor)
| Role | Deskripsi |
|---|---|
| **Siswa** | Pelapor utama; membuat laporan, memantau statusnya, terlibat dalam mediasi |
| **Orang Tua (Ortu)** | Memantau laporan yang dibuat oleh anaknya, menerima notifikasi terkait mediasi |
| **Guru BK** | Memvalidasi laporan, menjadwalkan & memfasilitasi mediasi, membuat tindak lanjut |
| **Kepala Sekolah (Kepsek)** | Memantau statistik & tren kasus sekolah secara agregat |
| **Admin** | Mengelola akun pengguna (CRUD), melihat audit log, mengawasi sistem secara keseluruhan |

---

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
SpeakUp terdiri dari:
- **SpeakUp Mobile** (Flutter, iOS/Android) — digunakan siswa & orang tua.
- **SpeakUp Web** (Flutter Web) — digunakan Guru BK, Kepala Sekolah, dan Admin.
- **Backend** — Supabase (PostgreSQL + Auth + Storage + Row Level Security + Postgres Functions), menggantikan backend Laravel pada iterasi awal proyek.

### 2.2 Karakteristik Pengguna
Pengguna adalah warga sekolah (siswa, orang tua, guru, kepala sekolah) dengan tingkat literasi digital umum/menengah — antarmuka dirancang sederhana, berbasis ikon, dan mendukung alur singkat (maks. 3 langkah untuk membuat laporan).

### 2.3 Batasan
- Autentikasi & penyimpanan data terpusat di Supabase; tidak ada mode offline.
- Kontrol akses data (siapa boleh lihat/ubah apa) ditegakkan di level database lewat Row Level Security, bukan hanya di sisi aplikasi.
- Role pengguna bersifat tunggal per akun (satu akun = satu role: admin/siswa/guru_bk/kepsek/ortu).

---

## 3. Kebutuhan Fungsional

### FR-1 Autentikasi
- FR-1.1 Sistem menyediakan login dengan email & password.
- FR-1.2 Sistem menyediakan registrasi mandiri untuk siswa/ortu; akun staff (admin/guru_bk/kepsek) dibuat oleh Admin.
- FR-1.3 Sistem mengarahkan pengguna ke dashboard sesuai role setelah login (role-based redirect).
- FR-1.4 Sistem menyediakan reset password.

### FR-2 Pelaporan (Report)
- FR-2.1 Siswa dapat membuat laporan baru dengan kategori (Perundungan Verbal, Fisik, Sosial, Cyberbullying, Pemerasan, Lainnya), deskripsi, lokasi kejadian, tanggal kejadian, dan pihak yang terlibat.
- FR-2.2 Siswa dapat menandai laporan sebagai anonim.
- FR-2.3 Siswa dapat melampirkan bukti (foto/dokumen) pada laporan.
- FR-2.4 Sistem menghasilkan kode laporan unik secara otomatis (format `REP-YYYYMMDD-XXXXXX`).
- FR-2.5 Siswa/Ortu dapat memantau status & riwayat perubahan status laporan.
- FR-2.6 Guru BK/Admin/Kepsek dapat melihat seluruh laporan yang masuk.
- FR-2.7 Ortu hanya dapat melihat laporan yang dibuat oleh anaknya sendiri.

### FR-3 Validasi Laporan
- FR-3.1 Guru BK dapat memvalidasi (menyatakan valid/ditolak) laporan yang masuk beserta catatan.
- FR-3.2 Admin **tidak** dapat memvalidasi atau menyelesaikan laporan (wewenang eksklusif Guru BK).
- FR-3.3 Setiap perubahan status laporan tercatat otomatis pada riwayat status.

### FR-4 Mediasi
- FR-4.1 Guru BK dapat menjadwalkan mediasi untuk laporan yang sudah divalidasi (tanggal, waktu, lokasi).
- FR-4.2 Guru BK yang membuat jadwal otomatis menjadi mediator laporan tersebut.
- FR-4.3 Sistem menambahkan peserta mediasi (siswa terkait, guru BK) dengan status konfirmasi (pending/confirmed/rejected/attended).
- FR-4.4 Peserta dapat mengonfirmasi/menolak kehadiran mediasi.
- FR-4.5 Guru BK dapat menghubungi peserta mediasi (mengirim notifikasi pengingat).
- FR-4.6 Guru BK dapat menyelesaikan (mark as completed) mediasi beserta hasilnya.
- FR-4.7 Pengguna dapat melihat daftar seluruh mediasi yang melibatkan dirinya (sebagai mediator maupun peserta).

### FR-5 Tindak Lanjut (Follow-up)
- FR-5.1 Guru BK dapat mencatat tindakan tindak lanjut atas suatu laporan (aksi yang diambil, tanggal).

### FR-6 Dashboard & Statistik
- FR-6.1 Sistem menampilkan dashboard berbeda berdasarkan role (dynamic dashboard).
- FR-6.2 Kepala Sekolah & Admin dapat melihat statistik agregat (total laporan, laporan hari ini, bulan ini, per status) dan tren kasus dari waktu ke waktu.

### FR-7 Manajemen Pengguna (Admin)
- FR-7.1 Admin dapat menambah, mengedit, menghapus, dan mengubah role pengguna.
- FR-7.2 Admin dapat melihat audit log aktivitas sistem.

### FR-8 Notifikasi
- FR-8.1 Sistem mengirim notifikasi in-app untuk: perubahan status laporan, jadwal mediasi, dan pengingat.
- FR-8.2 Pengguna dapat menandai notifikasi sebagai sudah dibaca.
- FR-8.3 Pengguna dapat mengatur preferensi notifikasi.

### FR-9 Profil
- FR-9.1 Pengguna dapat melihat & mengedit profil (nama, telepon, foto profil).
- FR-9.2 Pengguna dapat mengganti password.

---

## 4. Kebutuhan Non-Fungsional

| Kode | Kategori | Deskripsi |
|---|---|---|
| NFR-1 | Keamanan | Seluruh akses data ditegakkan lewat Row Level Security di database — pengguna tidak bisa mengakses data di luar kewenangan rolenya meski melewati bug di aplikasi. |
| NFR-2 | Privasi | Laporan anonim tidak menampilkan identitas pelapor kepada pihak yang tidak berwenang. |
| NFR-3 | Ketersediaan | Layanan backend (Supabase) bertipe managed cloud, target uptime mengikuti SLA penyedia. |
| NFR-4 | Usability | Alur pembuatan laporan maksimal 3 langkah (Identitas → Bukti → Review). |
| NFR-5 | Kompatibilitas | Mobile app berjalan di Android & iOS; web app berjalan di browser modern (desktop). |
| NFR-6 | Skalabilitas | Struktur data & RLS dirancang agar query tetap efisien seiring pertambahan jumlah laporan/pengguna. |
| NFR-7 | Auditabilitas | Setiap perubahan status laporan & aktivitas penting tercatat di `report_status_histories` dan `audit_logs`. |

---

## 5. Matriks Hak Akses Ringkas

| Fitur | Siswa | Ortu | Guru BK | Kepsek | Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| Buat laporan | ✅ | ❌ | ❌ | ❌ | ❌ |
| Lihat laporan sendiri/anak | ✅ | ✅ | — | — | — |
| Lihat semua laporan | ❌ | ❌ | ✅ | ✅ | ✅ |
| Validasi laporan | ❌ | ❌ | ✅ | ❌ | ❌ |
| Jadwalkan mediasi | ❌ | ❌ | ✅ | ❌ | ❌ |
| Lihat statistik agregat | ❌ | ❌ | ✅ | ✅ | ✅ |
| Kelola akun pengguna | ❌ | ❌ | ❌ | ❌ | ✅ |
| Lihat audit log | ❌ | ❌ | ❌ | ❌ | ✅ |

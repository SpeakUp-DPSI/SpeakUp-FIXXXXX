# Information Architecture
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 1.0  
**Tanggal:** Juni 2025  
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta  
**Mata Kuliah:** Desain dan Pengembangan Sistem Informasi  
**Dosen Pengampu:** Farid Suryanto, S.Pd., MT.

---

## 1. Gambaran Umum Arsitektur

SpeakUp dibagi menjadi enam area utama berdasarkan peran pengguna. Pembagian ini memastikan setiap aktor hanya melihat fitur dan informasi yang relevan dengan tanggung jawabnya.

```
SPEAKUP
│
├── 1. Halaman Publik          ← Tanpa login
├── 2. Dashboard Siswa         ← Login sebagai Siswa
├── 3. Dashboard Guru BK       ← Login sebagai Guru BK
├── 4. Dashboard Kepala Sekolah ← Login sebagai Kepala Sekolah
├── 5. Dashboard Orang Tua/Wali ← Login sebagai Orang Tua/Wali
└── 6. Pengaturan              ← Semua pengguna (sesuai hak akses)
```

---

## 2. Sitemap Lengkap

```
SPEAKUP
│
├── 1. HALAMAN PUBLIK
│   │
│   ├── 1.1 Beranda
│   │   ├── Informasi Sistem
│   │   │   ├── Deskripsi Sistem
│   │   │   ├── Tujuan Sistem
│   │   │   └── Manfaat Sistem
│   │   ├── Alur Penggunaan Sistem
│   │   │   ├── Cara Membuat Laporan
│   │   │   ├── Cara Mengunggah Bukti
│   │   │   ├── Cara Mendapatkan Kode Laporan
│   │   │   └── Cara Mengecek Status Laporan
│   │   └── Akses Cepat
│   │       ├── Tombol Buat Laporan
│   │       ├── Tombol Cek Status Laporan
│   │       └── Kontak Bantuan Guru BK
│   │
│   ├── 1.2 Edukasi Anti Perundungan
│   │   ├── Pengertian Perundungan
│   │   ├── Jenis-Jenis Perundungan
│   │   │   ├── Perundungan Fisik
│   │   │   ├── Perundungan Verbal
│   │   │   ├── Perundungan Sosial
│   │   │   └── Cyberbullying
│   │   ├── Dampak Perundungan
│   │   │   ├── Dampak Psikologis
│   │   │   ├── Dampak Sosial
│   │   │   └── Dampak Akademik
│   │   └── Cara Melapor
│   │       ├── Panduan Pelaporan
│   │       ├── Ketentuan Laporan
│   │       └── Perlindungan Identitas Pelapor
│   │
│   ├── 1.3 Buat Laporan
│   │   ├── Form Data Kejadian
│   │   │   ├── Jenis Perundungan
│   │   │   ├── Tanggal Kejadian
│   │   │   ├── Waktu Kejadian
│   │   │   ├── Lokasi Kejadian
│   │   │   ├── Pihak yang Terlibat
│   │   │   └── Kronologi Kejadian
│   │   ├── Pilihan Identitas Pelapor
│   │   │   ├── Lapor dengan Identitas
│   │   │   └── Lapor Secara Anonim
│   │   ├── Upload Bukti
│   │   │   ├── Foto
│   │   │   ├── Video
│   │   │   ├── Dokumen
│   │   │   └── Keterangan Bukti
│   │   ├── Review Laporan
│   │   │   ├── Ringkasan Data Laporan
│   │   │   ├── Validasi Kelengkapan Data
│   │   │   └── Persetujuan Pengiriman
│   │   └── Konfirmasi Pengiriman
│   │       ├── Pesan Laporan Berhasil Dikirim
│   │       ├── Kode Laporan
│   │       └── Instruksi Cek Status Laporan
│   │
│   └── 1.4 Cek Status Laporan
│       ├── Input Kode Laporan
│       ├── Validasi Kode Laporan
│       └── Detail Status Laporan
│           ├── Status Laporan
│           ├── Tanggal Laporan
│           ├── Tahap Penanganan
│           ├── Catatan Umum dari Guru BK
│           └── Riwayat Perubahan Status
│
├── 2. DASHBOARD SISWA
│   │
│   ├── 2.1 Dashboard Utama Siswa
│   │   ├── Ringkasan Laporan
│   │   ├── Jumlah Laporan Dibuat
│   │   ├── Laporan Sedang Diproses
│   │   └── Laporan Selesai
│   │
│   ├── 2.2 Buat Laporan Baru
│   │   ├── Form Laporan
│   │   ├── Upload Bukti
│   │   └── Konfirmasi Pengiriman
│   │
│   ├── 2.3 Riwayat Laporan
│   │   ├── Daftar Laporan
│   │   ├── Kode Laporan
│   │   ├── Tanggal Laporan
│   │   └── Status Laporan
│   │
│   ├── 2.4 Detail Status Laporan
│   │   ├── Informasi Laporan
│   │   ├── Status Penanganan
│   │   ├── Catatan Perkembangan
│   │   └── Riwayat Status
│   │
│   └── 2.5 Bantuan
│       ├── Panduan Penggunaan Sistem
│       ├── Pertanyaan Umum (FAQ)
│       └── Kontak Guru BK
│
├── 3. DASHBOARD GURU BK
│   │
│   ├── 3.1 Dashboard Utama
│   │   ├── Total Laporan Masuk
│   │   ├── Laporan Menunggu Validasi
│   │   ├── Laporan Valid
│   │   ├── Laporan Diproses
│   │   ├── Laporan Mediasi
│   │   └── Laporan Selesai
│   │
│   ├── 3.2 Manajemen Laporan
│   │   ├── Daftar Laporan Masuk
│   │   │   ├── Kode Laporan
│   │   │   ├── Tanggal Laporan
│   │   │   ├── Jenis Perundungan
│   │   │   ├── Status Laporan
│   │   │   └── Aksi Lihat Detail
│   │   ├── Detail Laporan
│   │   │   ├── Data Kejadian
│   │   │   ├── Kronologi Kejadian
│   │   │   ├── Identitas Pelapor
│   │   │   ├── Data Korban
│   │   │   ├── Data Terlapor
│   │   │   └── Data Saksi
│   │   ├── Validasi Laporan
│   │   │   ├── Pemeriksaan Kelengkapan Data
│   │   │   ├── Pemeriksaan Kronologi
│   │   │   ├── Penentuan Valid atau Tidak Valid
│   │   │   └── Catatan Validasi
│   │   ├── Pemeriksaan Bukti
│   │   │   ├── Daftar Bukti
│   │   │   ├── Preview Bukti
│   │   │   ├── Keterangan Bukti
│   │   │   └── Catatan Pemeriksaan Bukti
│   │   └── Update Status
│   │       ├── Baru
│   │       ├── Menunggu Validasi
│   │       ├── Valid
│   │       ├── Diproses
│   │       ├── Mediasi
│   │       ├── Tindak Lanjut
│   │       ├── Selesai
│   │       └── Ditolak
│   │
│   ├── 3.3 Mediasi
│   │   ├── Buat Jadwal Mediasi
│   │   │   ├── Tanggal Mediasi
│   │   │   ├── Waktu Mediasi
│   │   │   ├── Tempat Mediasi
│   │   │   └── Agenda Mediasi
│   │   ├── Daftar Jadwal Mediasi
│   │   │   ├── Jadwal Mendatang
│   │   │   ├── Jadwal Berlangsung
│   │   │   └── Jadwal Selesai
│   │   ├── Peserta Mediasi
│   │   │   ├── Guru BK
│   │   │   ├── Korban
│   │   │   ├── Terlapor
│   │   │   ├── Orang Tua/Wali
│   │   │   └── Pihak Sekolah
│   │   └── Hasil Mediasi
│   │       ├── Catatan Mediasi
│   │       ├── Kesepakatan Mediasi
│   │       ├── Rekomendasi Lanjutan
│   │       └── Status Hasil Mediasi
│   │
│   ├── 3.4 Tindak Lanjut
│   │   ├── Catatan Pembinaan
│   │   ├── Rekomendasi Tindakan
│   │   ├── Sanksi atau Pembinaan
│   │   ├── Pemantauan Perkembangan Siswa
│   │   └── Penyelesaian Kasus
│   │
│   ├── 3.5 Riwayat Perilaku Siswa
│   │   ├── Data Siswa
│   │   │   ├── Nama Siswa
│   │   │   ├── NIS
│   │   │   ├── Kelas
│   │   │   └── Kontak Orang Tua/Wali
│   │   ├── Riwayat Kasus
│   │   │   ├── Kasus Sebagai Korban
│   │   │   ├── Kasus Sebagai Terlapor
│   │   │   └── Kasus Sebagai Saksi
│   │   └── Catatan Guru BK
│   │       ├── Catatan Konseling
│   │       ├── Catatan Pembinaan
│   │       └── Catatan Perkembangan
│   │
│   └── 3.6 Laporan / Rekapitulasi
│       ├── Rekap Harian
│       ├── Rekap Mingguan
│       ├── Rekap Bulanan
│       ├── Grafik Kasus
│       │   ├── Grafik Berdasarkan Jenis Perundungan
│       │   ├── Grafik Berdasarkan Status Laporan
│       │   └── Grafik Berdasarkan Periode Waktu
│       └── Export Laporan
│           ├── Export PDF
│           ├── Export Excel
│           └── Cetak Laporan
│
├── 4. DASHBOARD KEPALA SEKOLAH
│   │
│   ├── 4.1 Statistik Kasus
│   │   ├── Total Kasus Perundungan
│   │   ├── Jumlah Kasus Baru
│   │   ├── Jumlah Kasus Diproses
│   │   ├── Jumlah Kasus Selesai
│   │   └── Jumlah Kasus Ditolak
│   │
│   ├── 4.2 Grafik Tren Perundungan
│   │   ├── Tren Kasus Harian
│   │   ├── Tren Kasus Bulanan
│   │   ├── Tren Jenis Perundungan
│   │   └── Tren Penyelesaian Kasus
│   │
│   ├── 4.3 Rekapitulasi Kasus
│   │   ├── Rekap Berdasarkan Jenis Perundungan
│   │   ├── Rekap Berdasarkan Kelas
│   │   ├── Rekap Berdasarkan Status
│   │   └── Rekap Berdasarkan Periode
│   │
│   ├── 4.4 Monitoring Penanganan
│   │   ├── Daftar Kasus Aktif
│   │   ├── Progres Penanganan Kasus
│   │   ├── Kasus yang Membutuhkan Perhatian
│   │   └── Evaluasi Tindak Lanjut
│   │
│   └── 4.5 Laporan Kebijakan
│       ├── Ringkasan Kasus
│       ├── Analisis Permasalahan
│       ├── Rekomendasi Pencegahan
│       └── Laporan untuk Pengambilan Keputusan
│
├── 5. DASHBOARD ORANG TUA/WALI
│   │
│   ├── 5.1 Notifikasi
│   │   ├── Notifikasi Anak Terlibat Kasus
│   │   ├── Notifikasi Jadwal Mediasi
│   │   ├── Notifikasi Perubahan Status
│   │   └── Notifikasi Hasil Tindak Lanjut
│   │
│   ├── 5.2 Detail Informasi Anak
│   │   ├── Data Anak
│   │   ├── Status Keterlibatan dalam Kasus
│   │   ├── Ringkasan Kasus
│   │   └── Catatan Terbatas dari Guru BK
│   │
│   ├── 5.3 Jadwal Mediasi
│   │   ├── Tanggal Mediasi
│   │   ├── Waktu Mediasi
│   │   ├── Tempat Mediasi
│   │   ├── Agenda Mediasi
│   │   └── Peserta Mediasi
│   │
│   ├── 5.4 Konfirmasi Kehadiran
│   │   ├── Hadir
│   │   ├── Tidak Hadir
│   │   └── Ajukan Perubahan Jadwal
│   │
│   └── 5.5 Hasil Tindak Lanjut
│       ├── Ringkasan Hasil Mediasi
│       ├── Rekomendasi Guru BK
│       ├── Catatan Pembinaan
│       └── Status Penyelesaian Kasus
│
└── 6. PENGATURAN
    │
    ├── 6.1 Profil Pengguna
    │   ├── Data Akun
    │   ├── Data Pribadi
    │   └── Ubah Profil
    │
    ├── 6.2 Hak Akses (Admin)
    │   ├── Role Siswa
    │   ├── Role Guru BK
    │   ├── Role Kepala Sekolah
    │   └── Role Orang Tua/Wali
    │
    ├── 6.3 Keamanan Akun
    │   ├── Ubah Password
    │   ├── Verifikasi Akun
    │   └── Pengaturan Privasi
    │
    └── 6.4 Logout
```

---

## 3. Diagram Area Berdasarkan Pengguna

```
┌─────────────────────────────────────────────────────────────┐
│                        SPEAKUP                              │
│                                                             │
│  ┌────────────────┐   Semua Pengguna (tanpa login)          │
│  │  PUBLIK AREA   │                                         │
│  │  - Beranda     │                                         │
│  │  - Edukasi     │                                         │
│  │  - Buat Laporan│                                         │
│  │  - Cek Status  │                                         │
│  └────────────────┘                                         │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │  SISWA   │ │ GURU BK  │ │ KEP.SEK  │ │ ORG TUA  │       │
│  │          │ │          │ │          │ │          │       │
│  │Dashboard │ │Dashboard │ │Statistik │ │Notifikasi│       │
│  │Buat Lap. │ │Mgmt Lap. │ │Grafik    │ │Info Anak │       │
│  │Riwayat   │ │Mediasi   │ │Rekap     │ │Mediasi   │       │
│  │Status    │ │Tindak    │ │Monitoring│ │Konfirmasi│       │
│  │Bantuan   │ │Lanjut    │ │Kebijakan │ │Hasil     │       │
│  │          │ │Riwayat   │ │          │ │          │       │
│  │          │ │Rekap     │ │          │ │          │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │  PENGATURAN  (semua pengguna, sesuai hak akses)    │     │
│  │  Profil | Hak Akses (Admin) | Keamanan | Logout    │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Navigasi Sistem

### 4.1 Primary Navigation per Peran

| Pengguna | Menu Utama |
|---|---|
| Siswa | Beranda, Edukasi, Buat Laporan, Cek Status, Dashboard, Bantuan, Pengaturan |
| Guru BK | Dashboard Utama, Manajemen Laporan, Mediasi, Tindak Lanjut, Riwayat Perilaku Siswa, Laporan/Rekapitulasi, Pengaturan |
| Kepala Sekolah | Statistik Kasus, Grafik Tren, Rekapitulasi Kasus, Monitoring Penanganan, Laporan Kebijakan, Pengaturan |
| Orang Tua/Wali | Notifikasi, Detail Informasi Anak, Jadwal Mediasi, Konfirmasi Kehadiran, Hasil Tindak Lanjut, Pengaturan |
| Admin | Profil Pengguna, Hak Akses, Keamanan Akun, Pengaturan Sistem |

### 4.2 Secondary Navigation (Submenu)

**Manajemen Laporan (Guru BK):**
```
Manajemen Laporan
├── Daftar Laporan Masuk
├── Detail Laporan
├── Validasi Laporan
├── Pemeriksaan Bukti
└── Update Status
```

**Dashboard Orang Tua/Wali:**
```
Dashboard Orang Tua/Wali
├── Notifikasi
├── Detail Informasi Anak
├── Jadwal Mediasi
├── Konfirmasi Kehadiran
└── Hasil Tindak Lanjut
```

### 4.3 Contextual Navigation

| Konteks | Aksi yang Muncul |
|---|---|
| Setelah siswa mengirim laporan | Simpan kode laporan, cek status laporan, kembali ke beranda |
| Saat siswa membuka detail status | Lihat riwayat status, kembali ke riwayat laporan, hubungi Guru BK |
| Saat Guru BK membuka detail laporan | Validasi laporan, periksa bukti, update status, buat jadwal mediasi |
| Saat Guru BK membuka menu mediasi | Tambah jadwal, ubah jadwal, tentukan peserta, catat hasil |
| Saat Guru BK membuka tindak lanjut | Tambah catatan pembinaan, buat rekomendasi, selesaikan kasus |
| Saat orang tua membuka jadwal mediasi | Konfirmasi hadir, tidak hadir, ajukan perubahan jadwal |
| Saat kepala sekolah membuka grafik | Filter periode, lihat detail rekap, export laporan |

---

## 5. User Flow

### 5.1 Siswa — Membuat Laporan

```
Login / Akses Publik
        ↓
Pilih "Buat Laporan"
        ↓
Isi Form Data Kejadian
(Jenis, Tanggal, Waktu, Lokasi, Pihak, Kronologi)
        ↓
Pilih Identitas Pelapor
┌───────────┬─────────────┐
│ Dengan    │   Anonim    │
│ Identitas │             │
└─────┬─────┴──────┬──────┘
      │            │
  Isi Nama,    Lanjut tanpa
  Kelas, Kontak identitas
      └────────────┘
              ↓
     Upload Bukti (opsional)
              ↓
       Review Laporan
              ↓
      Kirim Laporan
              ↓
  Sistem simpan + generate Kode Laporan
              ↓
    Tampilkan Kode Laporan
              ↓
  Laporan masuk ke Dashboard Guru BK
```

### 5.2 Siswa — Mengecek Status Laporan

```
Login → Dashboard Siswa
        ↓
   Riwayat Laporan
        ↓
  Pilih Satu Laporan
        ↓
  Detail Status Laporan
  - Informasi Laporan
  - Status Penanganan
  - Catatan Perkembangan
  - Riwayat Perubahan Status
```

### 5.3 Guru BK — Menangani Laporan

```
Login → Dashboard Utama Guru BK
              ↓
    Manajemen Laporan → Daftar Laporan Masuk
              ↓
       Buka Detail Laporan
    (Data Kejadian, Kronologi, Pihak, Saksi)
              ↓
       Pemeriksaan Bukti
              ↓
       Validasi Laporan
       ┌──────┴──────┐
      Valid        Ditolak
       ↓               ↓
    Diproses     Catat alasan
       ↓         Update status
  Buat Jadwal Mediasi (jika perlu)
       ↓
  Tentukan Peserta Mediasi
       ↓
   Catat Hasil Mediasi
       ↓
  Tindak Lanjut / Pembinaan
       ↓
  Update Status → Selesai
       ↓
  Rekap / Arsip Kasus
```

### 5.4 Guru BK — Membuat Rekapitulasi

```
Login → Dashboard Guru BK
        ↓
  Laporan / Rekapitulasi
        ↓
  Pilih Periode (Harian / Mingguan / Bulanan)
        ↓
  Lihat Grafik Kasus
  (Jenis, Status, Periode)
        ↓
  Export Laporan (PDF / Excel / Cetak)
```

### 5.5 Kepala Sekolah — Monitoring

```
Login → Dashboard Kepala Sekolah
              ↓
       Statistik Kasus
    (Total, Baru, Diproses, Selesai, Ditolak)
              ↓
    Grafik Tren Perundungan
    (Harian / Bulanan / Jenis / Penyelesaian)
              ↓
      Rekapitulasi Kasus
    (Jenis, Kelas, Status, Periode)
              ↓
    Monitoring Penanganan
    (Kasus Aktif, Progres, Perhatian, Evaluasi)
              ↓
     Laporan Kebijakan
   (Ringkasan, Analisis, Rekomendasi, Keputusan)
```

### 5.6 Orang Tua/Wali — Mengikuti Proses Mediasi

```
Login → Dashboard Orang Tua/Wali
              ↓
         Notifikasi
      (Anak terlibat kasus)
              ↓
    Buka Detail Informasi Anak
    (Data, Status Keterlibatan, Ringkasan)
              ↓
       Jadwal Mediasi
    (Tanggal, Waktu, Tempat, Agenda)
              ↓
    Konfirmasi Kehadiran
    ┌─────┬────────┬──────────────┐
    │Hadir│Tdk Hadir│Ajukan Ubah  │
    └──┬──┴────┬───┴─────────┬───┘
       └───────┴─────────────┘
              ↓
       Ikuti Mediasi
              ↓
     Hasil Tindak Lanjut
    (Ringkasan, Rekomendasi, Status Selesai)
```

### 5.7 Admin — Mengelola Akun

```
Login → Pengaturan
        ↓
   Profil Pengguna
   (Lihat & kelola data akun)
        ↓
     Hak Akses
   (Atur role: Siswa, Guru BK, Kepala Sekolah, Orang Tua)
        ↓
   Keamanan Akun
   (Password, verifikasi, privasi)
        ↓
   Simpan Perubahan
        ↓
   Sistem update data & hak akses
```

---

## 6. Alur Status Laporan

```
┌─────────────────────────────────────────────────────────────┐
│                    ALUR STATUS LAPORAN                      │
│                                                             │
│  [Laporan Dibuat]                                           │
│        ↓                                                    │
│  [Laporan Masuk]   ← sistem generate kode laporan          │
│        ↓                                                    │
│  [Menunggu Validasi]   ← Guru BK memeriksa                 │
│        ↓                                                    │
│   ┌────┴──────┐                                             │
│  [Valid]   [Ditolak]                                        │
│    ↓                                                        │
│  [Diproses]   ← Guru BK mulai menangani                    │
│    ↓                                                        │
│  [Mediasi]   ← pertemuan pihak terkait                     │
│    ↓                                                        │
│  [Tindak Lanjut]   ← pembinaan & pemantauan               │
│    ↓                                                        │
│  [Selesai]   ← diarsipkan                                  │
└─────────────────────────────────────────────────────────────┘
```

| Status | Aktor | Aksi |
|---|---|---|
| Laporan Dibuat | Siswa | Mengisi form, memilih identitas, upload bukti |
| Laporan Masuk | Sistem | Menyimpan data, generate kode laporan |
| Menunggu Validasi | Guru BK | Memeriksa kelengkapan data dan bukti |
| Valid | Guru BK | Laporan disetujui untuk diproses |
| Ditolak | Guru BK | Laporan tidak memenuhi ketentuan |
| Diproses | Guru BK | Penanganan aktif dimulai |
| Mediasi | Guru BK + Pihak Terkait | Pertemuan mediasi dilaksanakan |
| Tindak Lanjut | Guru BK | Pembinaan, sanksi, pemantauan |
| Selesai | Guru BK | Kasus diarsipkan |

---

## 7. Content Inventory

| Halaman / Menu | Informasi yang Ditampilkan | Aksi Pengguna |
|---|---|---|
| Beranda | Deskripsi, tujuan, manfaat, alur, akses cepat | Membuka laporan / cek status |
| Edukasi Anti Perundungan | Pengertian, jenis, dampak, cara melapor | Membaca konten edukasi |
| Buat Laporan | Form kejadian, identitas, upload bukti, review | Mengisi, memilih, mengunggah, mengirim |
| Konfirmasi Pengiriman | Pesan berhasil, kode laporan, instruksi | Menyimpan kode laporan |
| Cek Status Laporan | Input kode, status, tahap, catatan, riwayat | Memantau perkembangan |
| Dashboard Utama Siswa | Ringkasan: dibuat, diproses, selesai | Memilih laporan |
| Riwayat Laporan | Daftar laporan: kode, tanggal, status | Membuka detail laporan |
| Detail Status Laporan | Info laporan, status, catatan, riwayat | Memantau status |
| Dashboard Utama Guru BK | Total, menunggu, valid, diproses, mediasi, selesai | Memantau dan memilih laporan |
| Manajemen Laporan | Daftar, detail, validasi, bukti, update status | Memproses laporan |
| Mediasi | Jadwal, peserta, agenda, hasil | Membuat jadwal, mencatat hasil |
| Tindak Lanjut | Catatan, rekomendasi, sanksi, pemantauan | Mencatat dan menyelesaikan kasus |
| Riwayat Perilaku Siswa | Data siswa, riwayat kasus, catatan BK | Melihat riwayat perilaku |
| Laporan / Rekapitulasi | Rekap harian/mingguan/bulanan, grafik, export | Membuat laporan, mengunduh data |
| Dashboard Kepala Sekolah | Statistik, grafik tren, rekap, monitoring, kebijakan | Monitoring dan pengambilan keputusan |
| Dashboard Orang Tua/Wali | Notifikasi, info anak, jadwal mediasi, konfirmasi, hasil | Memantau dan mengonfirmasi kehadiran |
| Pengaturan | Profil, hak akses, keamanan, logout | Mengelola akun |

---

## 8. Rekomendasi Struktur Wireframe

### 8.1 Halaman Publik
```
HEADER
└── Logo SpeakUp | Menu: Beranda | Edukasi | Buat Laporan | Cek Status | Login

HERO SECTION
└── Judul + deskripsi singkat
└── [Tombol: Buat Laporan] [Tombol: Cek Status]

SECTION: Informasi Sistem
└── Deskripsi | Tujuan | Manfaat

SECTION: Alur Penggunaan
└── Step 1 → Step 2 → Step 3 → Step 4 (visual timeline)

SECTION: Edukasi Singkat
└── Jenis Perundungan (card)

SECTION: Kontak
└── Kontak Guru BK | Kontak Sekolah

FOOTER
```

### 8.2 Form Buat Laporan
```
HEADER
JUDUL: Form Pelaporan Kasus Perundungan

INFO BANNER: "Identitas Anda dapat dirahasiakan"

FORM DATA KEJADIAN
└── Jenis Perundungan (dropdown)
└── Tanggal & Waktu Kejadian
└── Lokasi Kejadian
└── Pihak yang Terlibat
└── Kronologi (textarea)

PILIHAN IDENTITAS
└── (○) Lapor dengan Identitas  (○) Lapor Anonim

UPLOAD BUKTI
└── Drop zone + keterangan

REVIEW
└── Ringkasan data sebelum kirim

AKSI: [Kembali] [Kirim Laporan]
```

### 8.3 Dashboard Siswa
```
SIDEBAR: Dashboard | Buat Laporan | Riwayat | Bantuan | Pengaturan | Logout

MAIN CONTENT:
├── Kartu Statistik: [Dibuat] [Diproses] [Selesai]
└── Tabel Riwayat: Kode | Tanggal | Jenis | Status | Aksi
```

### 8.4 Dashboard Guru BK
```
SIDEBAR: Dashboard | Manajemen Laporan | Mediasi | Tindak Lanjut | Riwayat | Rekap | Pengaturan | Logout

MAIN CONTENT:
├── Kartu Statistik: [Total] [Menunggu] [Valid] [Diproses] [Mediasi] [Selesai]
└── Tabel Laporan: Kode | Tanggal | Jenis | Status | [Lihat] [Validasi] [Update]
```

### 8.5 Dashboard Kepala Sekolah
```
SIDEBAR: Statistik | Grafik | Rekapitulasi | Monitoring | Kebijakan | Pengaturan | Logout

MAIN CONTENT:
├── Kartu Statistik: [Total] [Baru] [Diproses] [Selesai] [Ditolak]
├── Grafik Tren (line chart / bar chart)
└── Tabel Monitoring: Kode | Status | Progres | Catatan
```

### 8.6 Dashboard Orang Tua/Wali
```
SIDEBAR: Notifikasi | Info Anak | Jadwal Mediasi | Konfirmasi | Hasil | Pengaturan | Logout

MAIN CONTENT:
├── Notifikasi (banner / list)
├── Info Anak: Nama | Kelas | Status Keterlibatan
├── Jadwal Mediasi: Tanggal | Waktu | Tempat | Agenda
└── Aksi: [Hadir] [Tidak Hadir] [Ajukan Perubahan]
```

---

## 9. Prinsip Arsitektur Informasi SpeakUp

| Prinsip | Implementasi |
|---|---|
| **User-Centered** | Setiap dashboard disesuaikan dengan kebutuhan dan peran masing-masing pengguna |
| **Keamanan & Privasi** | Hak akses ketat; laporan anonim tidak menyimpan identitas pelapor |
| **Efisiensi Navigasi** | Menu disusun berdasarkan frekuensi dan urgensi penggunaan |
| **Transparansi** | Siswa dapat memantau status laporan secara real-time tanpa harus bertanya langsung |
| **Skalabilitas** | Struktur mendukung penambahan fitur: notifikasi WhatsApp/email, filter lanjutan, role permission detail |
| **Kejelasan Hierarki** | Informasi disusun dari yang paling umum (beranda) ke yang paling spesifik (detail laporan) |

---

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*

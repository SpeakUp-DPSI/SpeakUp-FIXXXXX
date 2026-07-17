# Software Requirements Specification (SRS)
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 1.0  
**Tanggal:** Juni 2025  
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta  
**Mata Kuliah:** Desain dan Pengembangan Sistem Informasi  
**Dosen Pengampu:** Farid Suryanto, S.Pd., MT.

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen
Dokumen SRS ini mendefinisikan seluruh kebutuhan fungsional dan non-fungsional dari aplikasi **SpeakUp**. Dokumen ini menjadi acuan bagi tim pengembang dalam merancang, membangun, dan menguji sistem.

### 1.2 Ruang Lingkup Sistem
**SpeakUp** adalah aplikasi berbasis web/mobile yang memfasilitasi:
- Pelaporan kasus perundungan oleh siswa (termasuk opsi anonim)
- Validasi dan penanganan laporan oleh Guru BK
- Monitoring statistik kasus oleh Kepala Sekolah
- Keterlibatan Orang Tua/Wali dalam proses mediasi
- Pengelolaan akun dan hak akses oleh Admin

### 1.3 Definisi dan Singkatan

| Istilah | Keterangan |
|---|---|
| SRS | Software Requirements Specification |
| SpeakUp | Nama aplikasi sistem pelaporan perundungan |
| Guru BK | Guru Bimbingan dan Konseling |
| NIS | Nomor Induk Siswa |
| Kode Laporan | Kode unik yang dihasilkan sistem setelah laporan dikirim |
| Anonim | Pelaporan tanpa mencantumkan identitas pelapor |
| Mediasi | Pertemuan antara pihak yang terlibat untuk menyelesaikan kasus |

### 1.4 Referensi
- Dokumen Arsitektur Informasi Sistem Pelaporan dan Penanganan Kasus Perundungan (2025/2026)

---

## 2. Deskripsi Umum Sistem

### 2.1 Gambaran Sistem
SpeakUp menyediakan platform terpusat untuk melaporkan, memvalidasi, menangani, dan memantau kasus perundungan di lingkungan sekolah. Sistem terbagi menjadi enam area utama:

1. **Halaman Publik** — akses tanpa login untuk informasi dan pelaporan
2. **Dashboard Siswa** — manajemen laporan oleh siswa
3. **Dashboard Guru BK** — pusat pengelolaan dan penanganan laporan
4. **Dashboard Kepala Sekolah** — monitoring dan evaluasi
5. **Dashboard Orang Tua/Wali** — informasi terbatas dan konfirmasi mediasi
6. **Pengaturan** — manajemen akun dan hak akses

### 2.2 Karakteristik Pengguna

| Pengguna | Peran | Kebutuhan Utama |
|---|---|---|
| Siswa | Pelapor | Membuat laporan, memantau status, akses anonim |
| Guru BK | Pengelola | Validasi, mediasi, tindak lanjut, rekapitulasi |
| Kepala Sekolah | Pemantau | Statistik, tren, monitoring, kebijakan |
| Orang Tua/Wali | Pendamping | Notifikasi, jadwal mediasi, konfirmasi kehadiran |
| Admin | Pengelola Sistem | Manajemen akun, hak akses, keamanan |

### 2.3 Asumsi dan Ketergantungan
- Sistem membutuhkan koneksi internet aktif
- Pengguna memiliki perangkat dengan browser modern atau smartphone
- Sekolah menyediakan data awal siswa, guru, dan orang tua untuk pendaftaran akun
- Server mendukung penyimpanan file (foto, video, dokumen)

---

## 3. Kebutuhan Fungsional

### 3.1 Halaman Publik

#### FR-PUB-01: Beranda
- Sistem menampilkan deskripsi, tujuan, dan manfaat SpeakUp
- Sistem menampilkan alur penggunaan: cara membuat laporan, mengunggah bukti, mendapatkan kode laporan, dan mengecek status
- Sistem menyediakan tombol akses cepat: **Buat Laporan** dan **Cek Status Laporan**
- Sistem menampilkan kontak bantuan Guru BK

#### FR-PUB-02: Edukasi Anti Perundungan
- Sistem menampilkan pengertian perundungan
- Sistem menampilkan jenis perundungan: fisik, verbal, sosial, cyberbullying
- Sistem menampilkan dampak perundungan: psikologis, sosial, akademik
- Sistem menampilkan panduan pelaporan, ketentuan laporan, dan informasi perlindungan identitas pelapor

#### FR-PUB-03: Buat Laporan (Publik)
- Sistem menyediakan form data kejadian: jenis perundungan, tanggal, waktu, lokasi, pihak terlibat, kronologi
- Sistem menyediakan pilihan identitas pelapor: dengan identitas atau anonim
- Jika memilih anonim, sistem tidak menyimpan data identitas pelapor
- Jika memilih dengan identitas, sistem meminta nama, kelas, dan kontak
- Sistem menyediakan fitur upload bukti: foto, video, dokumen, beserta keterangan bukti
- Sistem menampilkan review laporan sebelum pengiriman
- Sistem memvalidasi kelengkapan data sebelum laporan dikirim
- Sistem menampilkan konfirmasi pengiriman beserta kode laporan unik
- Sistem menyimpan instruksi cara mengecek status laporan

#### FR-PUB-04: Cek Status Laporan (Publik)
- Sistem menyediakan form input kode laporan
- Sistem memvalidasi kode laporan
- Sistem menampilkan: status laporan, tanggal laporan, tahap penanganan, catatan umum Guru BK, dan riwayat perubahan status

---

### 3.2 Dashboard Siswa

#### FR-STD-01: Dashboard Utama Siswa
- Sistem menampilkan ringkasan laporan: jumlah laporan dibuat, laporan sedang diproses, laporan selesai

#### FR-STD-02: Buat Laporan Baru
- Sistem mengarahkan siswa ke form laporan (sama dengan FR-PUB-03)
- Sistem mengaitkan laporan dengan akun siswa yang login

#### FR-STD-03: Riwayat Laporan
- Sistem menampilkan daftar seluruh laporan yang pernah dibuat siswa
- Setiap entri menampilkan: kode laporan, tanggal laporan, status laporan

#### FR-STD-04: Detail Status Laporan
- Sistem menampilkan informasi laporan, status penanganan, catatan perkembangan, dan riwayat perubahan status

#### FR-STD-05: Bantuan
- Sistem menampilkan panduan penggunaan SpeakUp
- Sistem menampilkan pertanyaan umum (FAQ)
- Sistem menampilkan kontak Guru BK

---

### 3.3 Dashboard Guru BK

#### FR-BK-01: Dashboard Utama
- Sistem menampilkan ringkasan jumlah laporan berdasarkan status: total masuk, menunggu validasi, valid, diproses, mediasi, selesai

#### FR-BK-02: Manajemen Laporan
- Sistem menampilkan daftar laporan masuk dengan kolom: kode laporan, tanggal, jenis perundungan, status, aksi
- Sistem menampilkan detail laporan: data kejadian, kronologi, identitas pelapor, data korban, data terlapor, data saksi
- Guru BK dapat melakukan validasi laporan: memeriksa kelengkapan data, kronologi, menentukan valid/tidak valid beserta catatan validasi
- Guru BK dapat memeriksa bukti: daftar bukti, preview, keterangan, catatan pemeriksaan
- Guru BK dapat memperbarui status laporan ke: Baru, Menunggu Validasi, Valid, Diproses, Mediasi, Tindak Lanjut, Selesai, Ditolak

#### FR-BK-03: Mediasi
- Guru BK dapat membuat jadwal mediasi: tanggal, waktu, tempat, agenda
- Sistem menampilkan daftar jadwal mediasi: mendatang, berlangsung, selesai
- Guru BK dapat menentukan peserta mediasi: Guru BK, korban, terlapor, orang tua/wali, pihak sekolah
- Guru BK dapat mencatat hasil mediasi: catatan, kesepakatan, rekomendasi lanjutan, status hasil

#### FR-BK-04: Tindak Lanjut
- Guru BK dapat mencatat pembinaan, rekomendasi tindakan, sanksi, pemantauan perkembangan siswa, dan penyelesaian kasus

#### FR-BK-05: Riwayat Perilaku Siswa
- Sistem menampilkan data siswa: nama, NIS, kelas, kontak orang tua/wali
- Sistem menampilkan riwayat kasus siswa: sebagai korban, terlapor, atau saksi
- Guru BK dapat mencatat: catatan konseling, catatan pembinaan, catatan perkembangan

#### FR-BK-06: Laporan / Rekapitulasi
- Sistem menyediakan rekap harian, mingguan, bulanan
- Sistem menampilkan grafik kasus: berdasarkan jenis perundungan, status laporan, dan periode waktu
- Sistem menyediakan fitur export laporan: PDF, Excel, cetak

---

### 3.4 Dashboard Kepala Sekolah

#### FR-KS-01: Statistik Kasus
- Sistem menampilkan: total kasus, jumlah kasus baru, diproses, selesai, ditolak

#### FR-KS-02: Grafik Tren Perundungan
- Sistem menampilkan tren kasus harian dan bulanan
- Sistem menampilkan tren jenis perundungan dan tren penyelesaian kasus

#### FR-KS-03: Rekapitulasi Kasus
- Sistem menampilkan rekap berdasarkan: jenis perundungan, kelas, status, dan periode

#### FR-KS-04: Monitoring Penanganan
- Sistem menampilkan daftar kasus aktif, progres penanganan, kasus yang membutuhkan perhatian, evaluasi tindak lanjut

#### FR-KS-05: Laporan Kebijakan
- Sistem menampilkan ringkasan kasus, analisis permasalahan, rekomendasi pencegahan, dan laporan untuk pengambilan keputusan

---

### 3.5 Dashboard Orang Tua/Wali

#### FR-OT-01: Notifikasi
- Sistem mengirimkan notifikasi ketika: anak terlibat kasus, ada jadwal mediasi, perubahan status, hasil tindak lanjut

#### FR-OT-02: Detail Informasi Anak
- Sistem menampilkan data anak, status keterlibatan, ringkasan kasus, catatan terbatas dari Guru BK

#### FR-OT-03: Jadwal Mediasi
- Sistem menampilkan tanggal, waktu, tempat, agenda, dan peserta mediasi

#### FR-OT-04: Konfirmasi Kehadiran
- Orang tua/wali dapat memilih: hadir, tidak hadir, atau ajukan perubahan jadwal

#### FR-OT-05: Hasil Tindak Lanjut
- Sistem menampilkan ringkasan hasil mediasi, rekomendasi Guru BK, catatan pembinaan, status penyelesaian kasus

---

### 3.6 Pengaturan

#### FR-SET-01: Profil Pengguna
- Pengguna dapat melihat dan mengubah data akun dan data pribadi

#### FR-SET-02: Hak Akses (Admin)
- Admin dapat mengatur role: siswa, Guru BK, kepala sekolah, orang tua/wali

#### FR-SET-03: Keamanan Akun
- Pengguna dapat mengubah password
- Sistem menyediakan verifikasi akun
- Pengguna dapat mengatur pengaturan privasi

#### FR-SET-04: Logout
- Sistem menyediakan fungsi logout yang mengakhiri sesi pengguna

---

## 4. Kebutuhan Non-Fungsional

### 4.1 Keamanan (Security)
- Sistem menggunakan autentikasi berbasis sesi atau JWT
- Data laporan dienkripsi saat penyimpanan dan transmisi (HTTPS)
- Akses data dibatasi berdasarkan role pengguna
- Laporan anonim tidak menyimpan data identitas pelapor di database
- Sistem mencatat log aktivitas untuk keperluan audit

### 4.2 Performa (Performance)
- Halaman utama dimuat dalam waktu ≤ 3 detik pada koneksi normal
- Upload bukti mendukung file hingga 10 MB per file
- Sistem mampu menangani minimal 100 pengguna konkuren

### 4.3 Ketersediaan (Availability)
- Sistem tersedia 99% uptime selama jam sekolah (07.00–17.00)
- Sistem menyediakan pesan error yang informatif saat terjadi gangguan

### 4.4 Skalabilitas (Scalability)
- Arsitektur mendukung penambahan fitur: notifikasi WhatsApp/email, integrasi data siswa, export otomatis, grafik analitik lanjutan, pencarian dan filter kasus, role permission yang lebih detail

### 4.5 Usability
- Antarmuka menggunakan bahasa Indonesia
- Navigasi menu jelas dan sesuai peran pengguna
- Formulir dilengkapi validasi dan pesan error yang mudah dipahami
- Sistem responsif untuk perangkat desktop dan mobile

### 4.6 Privasi
- Identitas pelapor anonim tidak dapat diakses oleh siapapun termasuk Admin
- Data siswa hanya dapat dilihat oleh pihak yang berwenang sesuai hak akses
- Dashboard orang tua/wali hanya menampilkan informasi yang relevan dengan anak mereka

---

## 5. Hak Akses Pengguna

| Fitur | Siswa | Guru BK | Kepala Sekolah | Orang Tua/Wali | Admin |
|---|---|---|---|---|---|
| Melihat Halaman Publik | ✅ | ✅ | ✅ | ✅ | ✅ |
| Membaca Edukasi | ✅ | ✅ | ✅ | ✅ | ✅ |
| Membuat Laporan | ✅ | ❌ | ❌ | ❌ | ❌ |
| Melapor Anonim | ✅ | ❌ | ❌ | ❌ | ❌ |
| Upload Bukti | ✅ | ✅ | ❌ | ❌ | ❌ |
| Mendapatkan Kode Laporan | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cek Status Laporan | ✅ | ✅ | ✅ | Terbatas | ✅ |
| Melihat Dashboard Siswa | ✅ | ❌ | ❌ | ❌ | ❌ |
| Melihat Laporan Masuk | ❌ | ✅ | Terbatas | ❌ | ✅ |
| Melihat Detail Laporan | Terbatas | ✅ | Terbatas | Terbatas | ✅ |
| Validasi Laporan | ❌ | ✅ | ❌ | ❌ | ❌ |
| Pemeriksaan Bukti | ❌ | ✅ | ❌ | ❌ | ❌ |
| Update Status Laporan | ❌ | ✅ | ❌ | ❌ | ❌ |
| Membuat Jadwal Mediasi | ❌ | ✅ | ❌ | ❌ | ❌ |
| Melihat Jadwal Mediasi | Terbatas | ✅ | ✅ | ✅ | ✅ |
| Konfirmasi Kehadiran Mediasi | ❌ | ❌ | ❌ | ✅ | ❌ |
| Mencatat Tindak Lanjut | ❌ | ✅ | ❌ | ❌ | ❌ |
| Melihat Hasil Tindak Lanjut | Terbatas | ✅ | ✅ | Terbatas | ✅ |
| Melihat Riwayat Perilaku Siswa | ❌ | ✅ | Terbatas | ❌ | ✅ |
| Melihat Statistik Kasus | ❌ | ✅ | ✅ | ❌ | ✅ |
| Melihat Laporan Kebijakan | ❌ | ❌ | ✅ | ❌ | ✅ |
| Export Laporan | ❌ | ✅ | ✅ | ❌ | ✅ |
| Mengelola Hak Akses | ❌ | ❌ | ❌ | ❌ | ✅ |
| Mengubah Profil Pengguna | ✅ | ✅ | ✅ | ✅ | ✅ |
| Logout | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 6. Alur Status Laporan

```
Laporan Dibuat
      ↓
Laporan Masuk
      ↓
Menunggu Validasi
      ↓
Valid ──────── Ditolak
  ↓
Diproses
  ↓
Mediasi
  ↓
Tindak Lanjut
  ↓
Selesai
```

| Status | Penjelasan |
|---|---|
| Laporan Dibuat | Siswa mengisi form, memilih identitas, dan mengunggah bukti |
| Laporan Masuk | Sistem menyimpan laporan dan menghasilkan kode laporan |
| Menunggu Validasi | Guru BK memeriksa kelengkapan data dan bukti |
| Valid | Laporan dinyatakan layak untuk diproses |
| Ditolak | Laporan tidak dapat diproses karena data tidak valid atau bukti kurang |
| Diproses | Guru BK mulai melakukan penanganan |
| Mediasi | Pertemuan dengan pihak terkait |
| Tindak Lanjut | Guru BK mencatat pembinaan dan pemantauan |
| Selesai | Kasus diselesaikan dan diarsipkan |

---

## 7. Batasan Sistem

- Sistem tidak terintegrasi secara otomatis dengan sistem akademik sekolah (versi awal)
- Notifikasi hanya melalui antarmuka sistem; notifikasi WhatsApp/email sebagai pengembangan lanjutan
- Laporan anonim tidak dapat dihubungkan kembali ke identitas pelapor oleh siapapun
- Admin tidak dapat mengakses konten laporan anonim secara langsung

---

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*

# Source of Truth (SoT) Documentation — Index
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

**Repo:** SpeakUp-DPSI/SpeakUp-FIXXXXX
**Backend:** Supabase (`dnznelktfptccxudbeib.supabase.co`)
**Disusun:** Juli 2026

---

## Daftar Dokumen

| # | Dokumen | File | Isi Ringkas |
|---|---|---|---|
| 1 | Software Requirement Specification (SRS) | `01_SRS.md` | Aktor, kebutuhan fungsional & non-fungsional, matriks hak akses |
| 2 | User Flow | `02_User_Flow.md` | Alur penggunaan per role: onboarding, buat laporan, validasi, mediasi, statistik, manajemen pengguna, notifikasi |
| 3 | System Logic | `03_System_Logic.md` | Arsitektur sistem, prinsip RLS, trigger & function otomatis, logika status, realtime, storage |
| 4 | Information Architecture | `04_Information_Architecture.md` | Peta navigasi mobile & web, struktur tab per role, hierarki entitas data |
| 5 | Database Design | `05_Database_Design.md` | ERD, kamus tabel lengkap, enum, RLS, riwayat migrasi/patch |
| 6 | API Specification | `06_API_Specification.md` | Seluruh endpoint Supabase (table API, RPC, Auth, Storage) yang dipakai aplikasi |
| 7 | Design System | `07_Design_System.md` | Palet warna, tipografi, komponen UI, layout responsif mobile vs web |

---

## Catatan Penting untuk Pembaca

- **Backend Laravel sudah tidak dipakai.** README repo masih menyebut `speakup_backend/` (Laravel) sebagai salah satu komponen utama, namun proyek telah **bermigrasi penuh ke Supabase** — kode Laravel tersisa di repo sebagai referensi historis logika bisnis, bukan backend yang aktif berjalan. Dokumen API Specification (dok. #6) merefleksikan kondisi *setelah* migrasi.
- **Dokumen Database Design bersifat living document.** Skema telah melalui beberapa siklus perbaikan pasca-migrasi (lihat tabel "Riwayat Migrasi & Patch" di dok. #5) karena ditemukan ketidaksesuaian antara asumsi awal skema dan kode aplikasi yang sudah berjalan lebih dulu. Setiap perubahan skema baru sebaiknya dicatat di tabel yang sama agar riwayat tetap utuh.
- **Keputusan desain yang perlu diketahui tim:**
  - Sistem role/permission Spatie (Laravel) disederhanakan menjadi satu kolom enum `profiles.role` di Postgres — bukan tabel roles/permissions terpisah.
  - Bucket Storage `evidence` sengaja dibuat **publik** (bukan privat + signed URL) demi kesederhanaan integrasi dengan kode aplikasi yang sudah ada.
  - Kontrol akses data sepenuhnya ditegakkan lewat **Row Level Security** di database, bukan logika manual di sisi aplikasi Flutter.

## Rekomendasi Dokumen Lanjutan (belum dibuat, bisa disusun berikutnya bila dibutuhkan)
- Deployment/Environment Guide (cara setup `.env`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` untuk kedua app Flutter)
- Testing Plan / Test Case per fitur
- Panduan onboarding developer baru (setup lokal, struktur folder feature-first)

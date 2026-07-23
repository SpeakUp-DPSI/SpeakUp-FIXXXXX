# System Logic
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

---

## 1. Arsitektur Sistem

```
┌─────────────────────┐     ┌─────────────────────┐
│   SpeakUp Mobile     │     │    SpeakUp Web       │
│   (Flutter, siswa    │     │  (Flutter Web, guru  │
│   & ortu)            │     │  BK/kepsek/admin)     │
└──────────┬───────────┘     └──────────┬───────────┘
           │                            │
           │      supabase_flutter SDK  │
           └─────────────┬──────────────┘
                          v
           ┌──────────────────────────────┐
           │           SUPABASE            │
           │ ┌──────────────────────────┐ │
           │ │  Auth (auth.users)        │ │
           │ ├──────────────────────────┤ │
           │ │  Postgres (public schema) │ │
           │ │  + Row Level Security     │ │
           │ │  + Trigger & Functions    │ │
           │ ├──────────────────────────┤ │
           │ │  Storage (evidence,       │ │
           │ │  avatars buckets)         │ │
           │ ├──────────────────────────┤ │
           │ │  Realtime (notifications) │ │
           │ └──────────────────────────┘ │
           └──────────────────────────────┘
```

Backend Laravel pada iterasi awal proyek (`speakup_backend/`) sudah **digantikan sepenuhnya** oleh Supabase. Kedua aplikasi Flutter berkomunikasi langsung ke Supabase lewat SDK resmi (`supabase_flutter`), tanpa perantara REST API kustom.

---

## 2. Prinsip Kontrol Akses (Authorization Logic)

Kontrol akses **tidak** ditentukan oleh kode Flutter, melainkan ditegakkan di level database lewat **Row Level Security (RLS)** Postgres. Ini berarti:

- Aplikasi mengirim query Supabase apa adanya (mis. `select * from reports`), dan Postgres secara otomatis menyaring baris mana yang boleh dikembalikan berdasarkan identitas (`auth.uid()`) dan role pengguna yang sedang login.
- Bug atau celah di sisi aplikasi tidak bisa membocorkan data lintas-role, karena penyaringan terjadi di database, bukan di client.

### 2.1 Fungsi Helper RLS
| Fungsi | Fungsi |
|---|---|
| `current_role()` | Mengembalikan role user yang sedang login, dibaca dari `profiles.role` |
| `is_staff()` | True jika role user adalah admin/guru_bk/kepsek |
| `is_admin()` | True jika role user adalah admin |
| `child_id_of_current_user()` | Mengembalikan `child_id` milik user (dipakai untuk ortu memantau laporan anaknya) |
| `is_mediation_participant(id)` | True jika user adalah peserta mediasi tertentu |
| `is_mediation_mediator(id)` | True jika user adalah mediator dari mediasi tertentu |

Dua fungsi terakhir sengaja dipisah sebagai `SECURITY DEFINER` untuk memutus **circular dependency** antara policy tabel `mediations` dan `mediation_participants` (keduanya saling mengecek satu sama lain) — pola ini mencegah error *infinite recursion* pada RLS.

### 2.2 Ringkasan Aturan Akses per Tabel
| Tabel | Siapa boleh SELECT | Siapa boleh INSERT/UPDATE |
|---|---|---|
| `reports` | Reporter sendiri, ortu (via child_id), staff | Insert: siswa (reporter_id = diri sendiri). Update: staff, atau reporter sendiri selagi status masih draft |
| `evidence` | Sama seperti report induknya | Insert: pemilik laporan / staff |
| `validations` | Sama seperti report induknya | Insert: guru_bk/admin saja |
| `mediations` | Mediator, peserta, staff, pemilik laporan | Insert: guru_bk/admin. Update: staff/mediator |
| `mediation_participants` | Peserta sendiri, mediator, staff | Insert: guru_bk/admin. Update: staff/peserta sendiri |
| `follow_ups` | Sama seperti report induknya | Insert: guru_bk/admin |
| `notifications` | Hanya penerima (user_id = diri sendiri) | Insert: staff/sistem |
| `audit_logs` | Admin saja | Insert: siapa saja yang login (mencatat aktivitasnya sendiri) |
| `profiles` | Diri sendiri, staff, ortu (untuk profil anaknya) | Update: diri sendiri, atau admin |

---

## 3. Logika Otomatis di Database (Trigger & Function)

### 3.1 `handle_new_user()`
Dipicu setelah insert baru di `auth.users` (saat signup). Membuat baris `profiles` otomatis, membaca `name`, `phone`, `role` dari metadata signup. Menghindari kebutuhan insert manual dari aplikasi setelah registrasi.

### 3.2 `generate_report_code()`
Dipicu sebelum insert ke `reports`. Menghasilkan kode unik format `REP-YYYYMMDD-XXXXXX` jika belum diisi, sehingga aplikasi tidak perlu men-generate kode di sisi client (mencegah duplikasi/race condition).

### 3.3 `track_report_status_history()` / `track_report_status_initial()`
Dipicu setelah update status `reports` (dan setelah insert pertama). Otomatis mencatat setiap perubahan status ke `report_status_histories`, tanpa aplikasi perlu insert manual di setiap tempat yang mengubah status.

### 3.4 `set_mediator_id_default()`
Dipicu sebelum insert ke `mediations`. Jika `mediator_id` tidak dikirim oleh aplikasi, otomatis diisi dari user yang sedang login — mencerminkan aturan bisnis "guru BK yang menjadwalkan mediasi otomatis menjadi mediatornya".

### 3.5 `guess_evidence_file_type()`
Dipicu sebelum insert ke `evidence`. Menebak `file_type` (image/video/pdf/document) dari ekstensi `file_name`, sebagai fallback karena aplikasi tidak selalu mengirim tipe file secara eksplisit.

### 3.6 `dashboard_statistics()` (RPC)
Dipanggil dari dashboard Kepala Sekolah/Admin. Menghitung agregat (total, hari ini, bulan ini, per status) langsung di database — lebih efisien daripada menarik seluruh baris `reports` ke client lalu menghitung manual. Dibatasi hanya bisa dipanggil oleh staff.

### 3.7 `get_my_mediations()` (RPC)
Mengembalikan seluruh mediasi yang melibatkan user yang login (sebagai mediator atau peserta), lengkap dengan data ringkas pelapor & peserta dalam satu panggilan (mengurangi jumlah round-trip query dari aplikasi).

### 3.8 `contact_participant(mediation_id)` (RPC)
Dipanggil saat Guru BK menekan "Hubungi Peserta". Membuat notifikasi in-app untuk seluruh peserta mediasi terkait. Dibatasi hanya bisa dipanggil oleh mediator laporan tersebut atau staff.

---

## 4. Logika Status Laporan

```
draft ──> submitted ──> waiting_validation ──┬──> valid ──> processing ──> mediation ──> follow_up ──> completed
                                              └──> rejected
```

- Perubahan status **hanya** dilakukan oleh Guru BK (Admin dibatasi dari memvalidasi/menyelesaikan laporan — ditegakkan di logika UI dan disarankan juga ditegakkan lewat RLS/`CHECK` tambahan bila diperlukan).
- Setiap transisi status otomatis tercatat ke riwayat (lihat 3.3).

---

## 5. Logika Realtime & Notifikasi

- Tabel `notifications` menjadi sumber tunggal untuk seluruh notifikasi in-app.
- Aplikasi berlangganan (`subscribe`) ke channel Realtime Supabase yang memfilter `user_id = auth.uid()`, sehingga badge unread count dan daftar notifikasi ter-update otomatis tanpa polling.
- Insert ke `notifications` dipicu oleh: perubahan status laporan, pembuatan jadwal mediasi, dan pemanggilan `contact_participant()`.

---

## 6. Penyimpanan File (Storage)

| Bucket | Visibilitas | Path Convention | Digunakan Untuk |
|---|---|---|---|
| `evidence` | Publik | `{report_id}/{nama_file}` | Bukti laporan (foto/dokumen) |
| `avatars` | Publik | `{user_id}/{nama_file}` | Foto profil pengguna |

> Catatan: bucket `evidence` sengaja dibuat publik (bukan privat + signed URL) atas keputusan tim, demi kesederhanaan implementasi di sisi aplikasi. Konsekuensinya, siapa pun yang mengetahui/menebak path file dapat mengakses bukti laporan tanpa login — perlu dipertimbangkan ulang jika kebutuhan privasi meningkat di kemudian hari.

# User Flow
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

---

## 1. Flow: Onboarding & Autentikasi

```
[Splash Screen]
      |
      v
Sudah pernah login? ──Ya──> [Auto-login via session] ──> Dashboard (sesuai role)
      |
      Tidak
      v
[Onboarding Screen] (hanya first-launch)
      |
      v
[Login Screen] <──────────────┐
      |                       |
      ├── Belum punya akun ──>[Register Screen] (siswa/ortu)
      |                       |     |
      |                       |     v
      |                       |  [Isi nama, email, no. HP, password, role]
      |                       |     |
      |                       |     v
      |                       |  Submit ──> auth.signUp() ──> profil otomatis dibuat
      |                       └─────┘             |
      |                                            v
      ├── Lupa password ──> [Forgot Password] ──> [Reset Password]
      |
      v
[Input email + password] ──> Submit
      |
      v
Role terdeteksi dari profiles.role
      |
      ├─ siswa   ──> Student Dashboard
      ├─ ortu    ──> Parent Dashboard
      ├─ guru_bk ──> Teacher Dashboard
      ├─ kepsek  ──> Principal Dashboard
      └─ admin   ──> Admin Dashboard
```

---

## 2. Flow: Siswa — Membuat Laporan

```
[Student Dashboard]
      |
      v
Tap "Buat Laporan"
      |
      v
[Create Report Screen] (dialog/full-screen)
      |
      ├─ Pilih kategori (Perundungan Verbal/Fisik/Sosial/Cyberbullying/Pemerasan/Lainnya)
      ├─ Isi judul, deskripsi
      ├─ Isi lokasi & tanggal kejadian
      ├─ Tandai sebagai anonim? (toggle)
      ├─ Lampirkan bukti (foto/dokumen) — opsional, multi-file
      └─ Tambah pihak terlibat (terlapor/saksi) — opsional
      |
      v
Tap "Lanjut / Review"
      |
      v
[Review Report Screen] — tampilkan ringkasan sebelum kirim
      |
      ├── Edit ──> kembali ke Create Report Screen
      |
      v
Tap "Kirim Laporan"
      |
      v
insert ke reports (trigger: generate report_code otomatis)
      |
      v
upload evidence ke Storage bucket 'evidence' + insert ke tabel evidence
      |
      v
insert ke report_status_histories (status awal: submitted)
      |
      v
[Report Success Screen] — tampilkan kode laporan
      |
      v
Kembali ke Dashboard / Lihat Detail Laporan
```

---

## 3. Flow: Siswa/Ortu — Memantau Laporan

```
[Dashboard] ──> Tab "Laporan" (History untuk siswa)
      |
      v
[Dynamic List Screen] — daftar laporan milik sendiri (siswa) / milik anak (ortu)
      |
      v
Tap salah satu laporan
      |
      v
[Report Detail Screen]
      |
      ├─ Lihat status saat ini & riwayat status
      ├─ Lihat bukti yang dilampirkan
      ├─ Lihat jadwal mediasi (jika ada)
      └─ Lihat catatan tindak lanjut (jika ada)
```

---

## 4. Flow: Guru BK — Validasi & Tindak Lanjut Laporan

```
[Teacher Dashboard] ──> Tab "Laporan"
      |
      v
[Dynamic List Screen] — semua laporan masuk (semua siswa)
      |
      v
Filter/cari berdasarkan status
      |
      v
Tap laporan berstatus "waiting_validation"
      |
      v
[Report Detail Screen]
      |
      v
Tap "Validasi Laporan"
      |
      ├─ Pilih: Valid / Ditolak
      ├─ Isi catatan validasi
      v
insert ke validations + update reports.status
      |
      v
Jika Valid ──> muncul opsi:
      |
      ├──> [Jadwalkan Mediasi] ─────────┐
      └──> [Buat Tindak Lanjut] ────┐   |
                                     v   v
                          [Create Follow-up]  [Create Mediation Screen]
                                     |             |
                                     v             v
                          insert follow_ups   insert mediations
                                              (mediator_id = guru BK yang login)
                                                    |
                                                    v
                                          tambah mediation_participants
                                                    |
                                                    v
                                          notifikasi terkirim ke peserta
```

---

## 5. Flow: Guru BK — Mengelola Mediasi

```
[Teacher Dashboard] ──> Tab "Mediasi"
      |
      v
[Mediation Screen] — daftar mediasi yang difasilitasi guru BK ini
      |
      v
Tap salah satu mediasi
      |
      v
[Mediation Detail Page]
      |
      ├─ Lihat jadwal, lokasi, peserta & status konfirmasi
      ├─ Tap "Hubungi Peserta" ──> kirim notifikasi pengingat ke peserta
      ├─ Tap "Mediation Chat" ──> [Mediation Chat Screen] (komunikasi terkait mediasi)
      └─ Tap "Selesaikan Mediasi"
              |
              v
        Isi hasil mediasi
              |
              v
        update mediations.status = completed
              |
              v
        update reports.status = completed
```

---

## 6. Flow: Kepala Sekolah — Statistik & Tren

```
[Principal Dashboard]
      |
      v
Ringkasan cepat: total laporan, hari ini, bulan ini, per status
(diambil dari RPC dashboard_statistics())
      |
      v
Tap "Lihat Tren" / "Trend Chart"
      |
      v
[Trend Chart Screen] — grafik jumlah laporan per periode, per kategori
```

---

## 7. Flow: Admin — Manajemen Pengguna

```
[Admin Dashboard] ──> Tab pengguna
      |
      v
[Daftar Pengguna]
      |
      ├─ Tap "Tambah Pengguna" ──> [Form Tambah] ──> auth.admin.createUser() + set role
      |
      ├─ Tap salah satu pengguna ──> Action Menu:
      |        ├─ Edit data diri
      |        ├─ Ubah role
      |        ├─ Reset/ubah password
      |        └─ Hapus pengguna
      |
      v
[Audit Log Screen] (menu terpisah, admin-only)
      |
      v
Lihat riwayat aktivitas sistem (siapa melakukan apa, kapan)
```

---

## 8. Flow: Notifikasi (semua role)

```
Event terjadi (status laporan berubah / jadwal mediasi dibuat / peserta dihubungi)
      |
      v
insert ke tabel notifications (user_id = penerima)
      |
      v
Realtime channel Supabase mendorong update ke aplikasi
      |
      v
Badge unread count bertambah di ikon notifikasi (AppBar)
      |
      v
User tap ikon notifikasi ──> [Notification Screen]
      |
      v
Tap salah satu notifikasi
      |
      ├─ is_read diupdate jadi true
      └─ Navigasi ke halaman terkait (detail laporan / detail mediasi)
```

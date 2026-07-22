# Information Architecture
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

---

## 1. Peta Navigasi — SpeakUp Mobile

```
Splash
 └─ Onboarding (first-launch only)
     └─ Login ──┬── Register
                 └── Forgot Password ── Reset Password

[Shell Navigation — Bottom Tab, 5 branch, tab ditampilkan/disembunyikan per role]
 ├─ Dashboard (dinamis per role)
 │   ├─ Student Dashboard
 │   ├─ Parent Dashboard
 │   ├─ Teacher (Guru BK) Dashboard
 │   ├─ Principal (Kepsek) Dashboard
 │   │   └─ Trend Chart
 │   └─ Admin Dashboard
 │       └─ Audit Log
 │
 ├─ Reports / History (dinamis: History untuk siswa, Report List untuk staff)
 │   └─ Report Detail
 │       ├─ Create Mediation (Guru BK)
 │       └─ Create Follow-up (Guru BK)
 │
 ├─ Mediations
 │   └─ Mediation Detail
 │       ├─ Mediation Chat
 │       └─ Hubungi Peserta
 │
 ├─ Notifications
 │
 └─ Profile
     ├─ Edit Profile
     ├─ Change Password
     └─ Settings (Notifikasi)

[Full-screen overlay, di luar shell]
 ├─ Create Report (dialog/popup)
 ├─ Review Report
 └─ Report Success
```

---

## 2. Peta Navigasi — SpeakUp Web

Struktur navigasi serupa dengan mobile, disesuaikan untuk layout desktop:

```
Login (dengan submit via tombol "Enter" pada password)
 └─ Fixed Top Navbar (semua role)
     ├─ Logo / Nama Sekolah
     ├─ Profile Dropdown ── Pengaturan Akun | Logout
     └─ (kepsek/ortu/admin) Ikon Notifikasi di kanan atas

[Layout utama per role]
 ├─ Teacher Dashboard (Grid layout responsif)
 │   ├─ Ringkasan laporan masuk
 │   └─ Ringkasan mediasi berjalan
 │
 ├─ Report Management
 │   ├─ Daftar Laporan (filter status/kategori)
 │   ├─ Create Report (dialog/popup responsif — khusus web)
 │   └─ Report Detail
 │       ├─ Validasi Laporan
 │       ├─ Jadwalkan Mediasi
 │       └─ Buat Tindak Lanjut
 │
 ├─ Mediation Management
 │   └─ Mediation Detail ── Selesaikan Mediasi
 │
 ├─ User Management (Admin) ── CRUD Pengguna
 ├─ Audit Log (Admin)
 ├─ Trend Chart / Statistik (Kepsek)
 └─ Profile ── Edit Profile | Notification Settings
```

---

## 3. Struktur Tab per Role (Bottom Navigation Mobile)

| Tab | Siswa | Ortu | Guru BK | Kepsek | Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ |
| Laporan/Riwayat | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mediasi | — | — | ✅ | — | — |
| Notifikasi | ✅ | ✅ | ✅ | ✅¹ | ✅¹ |
| Profil | ✅ | ✅ | ✅ | ✅ | ✅ |

¹ Untuk Kepsek & Ortu, ikon notifikasi dipindah ke AppBar kanan atas (mengikuti Admin), bukan di bottom tab.

---

## 4. Hierarki Entitas Data (ringkas — detail lihat Database Design)

```
profiles (user)
 ├─< reports (dibuat oleh 1 profile)
 │    ├─< evidence
 │    ├─< validations (oleh guru_bk)
 │    ├─< mediations
 │    │    └─< mediation_participants >─ profiles
 │    ├─< follow_ups (oleh guru_bk)
 │    ├─< report_participants (terlapor/saksi)
 │    └─< report_status_histories
 └─< notifications (diterima oleh 1 profile)

profiles (ortu) ─ child_id → profiles (siswa)
```

---

## 5. Konten & Kategori Laporan

**Kategori Laporan:**
- Perundungan Verbal
- Perundungan Fisik
- Perundungan Sosial
- Cyberbullying
- Pemerasan
- Lainnya (input bebas)

**Status Laporan:** draft → submitted → waiting_validation → valid/rejected → processing → mediation → follow_up → completed

**Status Mediasi:** scheduled → ongoing → completed / cancelled

**Status Peserta Mediasi:** pending → confirmed/rejected → attended

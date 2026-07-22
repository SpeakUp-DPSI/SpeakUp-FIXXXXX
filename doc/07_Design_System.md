# Design System
## SpeakUp — Aplikasi Pelaporan & Penanganan Perundungan Sekolah

> Diambil dari implementasi aktual di `speakup_mobile/lib/core/theme/app_theme.dart`
> dan pola desain yang konsisten dipakai di `speakup_web`.

---

## 1. Color Palette

### 1.1 Primary (Biru)
| Token | Hex | Kegunaan |
|---|---|---|
| primary600 | `#2E63C6` | Warna utama tombol, elemen aktif |
| primary500 | `#4376D9` | Variasi primary |
| primary200 | `#A8C8EB` | Border/aksen ringan |
| primary100 | `#D1E4F5` | Background aksen |
| primary50 | `#E8F2FB` | Background sangat ringan |

### 1.2 Secondary
| Token | Hex |
|---|---|
| secondary600 | `#1A56DB` |
| secondary100 | `#DBEAFE` |

### 1.3 Neutral (Grayscale)
| Token | Hex | Kegunaan |
|---|---|---|
| neutral900 | `#111827` | Teks utama (paling gelap) |
| neutral700 | `#374151` | Teks sekunder |
| neutral600 | `#4B5563` | Teks tersier |
| neutral500 | `#6B7280` | Placeholder/disabled |
| neutral400 | `#9CA3AF` | Hint text |
| neutral300 | `#D1D5DB` | Border |
| neutral200 | `#E5E7EB` | Divider |
| neutral100 | `#F3F4F6` | Background card |
| neutral50 | `#F9FAFB` | Background halaman |

### 1.4 Semantic Colors
| Token | Hex | Kegunaan |
|---|---|---|
| success600 | `#059669` | Status valid/berhasil |
| success100 | `#D1FAE5` | Background badge sukses |
| warning600 | `#D97706` | Status menunggu/perlu perhatian |
| warning100 | `#FEF3C7` | Background badge warning |
| danger600 | `#DC2626` | Status ditolak/error |
| info600 | `#2563EB` | Informasi umum |
| info100 | `#DBEAFE` | Background badge info |

---

## 2. Typography

- **Font Engine:** `google_fonts` package (Flutter) — memungkinkan penggunaan Google Fonts tanpa bundling manual.
- **Base:** Material 3 (`useMaterial3: true`), skema warna diturunkan dari `ColorScheme.fromSeed(seedColor: primary600)`.

**Rekomendasi skala tipografi (mengikuti konvensi Material 3):**
| Style | Ukuran | Bobot | Kegunaan |
|---|---|---|---|
| Headline | 24–28px | Bold | Judul halaman |
| Title | 18–20px | Bold/SemiBold | Judul kartu/section |
| Body | 14–16px | Regular | Teks konten |
| Label | 12–14px | Medium | Label form, caption |
| Button | 16px | Bold | Teks tombol |

---

## 3. Komponen

### 3.1 Button
**Elevated Button (Primary Action)**
- Background: `primary600`
- Foreground: putih
- Border radius: `12px`
- Padding: `20px horizontal, 14px vertical`
- Min size: `88×50`
- Text: `16px, bold`

**Outlined Button (Secondary Action)**
- Foreground: `primary600`
- Border: `1.5px solid primary600`
- Border radius: `12px`
- Padding & text sama seperti Elevated Button

### 3.2 Input Field
- Filled, background putih
- Border radius: `12px`
- Border default: biru (`Colors.blueAccent`)
- Border saat fokus: `primary600`, tebal `2px`
- Border saat error: `danger600`
- Padding konten: `16px horizontal, 16px vertical`
- Hint text: `neutral400, 14px`

### 3.3 Status Badge (konvensi, berdasarkan enum status)
| Status | Warna Badge |
|---|---|
| draft / submitted | neutral / info100 |
| waiting_validation | warning100 + warning600 |
| valid | success100 + success600 |
| rejected | danger600 (background merah muda) |
| processing / mediation / follow_up | info100 + info600 |
| completed | success100 + success600 |

### 3.4 Card
- Background: putih atau `neutral50`
- Border radius: mengikuti konvensi `12px` (konsisten dengan button/input)
- Elevation ringan / border tipis `neutral200`

---

## 4. Layout & Responsivitas

### 4.1 Mobile (`speakup_mobile`)
- Navigasi: Bottom Tab (`StatefulShellRoute`, 5 branch)
- Create Report ditampilkan sebagai **full-screen overlay dengan fade transition**, bukan halaman penuh biasa
- Warna barrier overlay: `Colors.black` opacity `0.5`

### 4.2 Web (`speakup_web`)
- Navigasi: **Fixed Top Navbar** (bukan bottom tab), berisi Profile Dropdown (Pengaturan Akun, Logout)
- Ikon Notifikasi: pojok kanan atas AppBar, untuk role Kepsek, Admin, Ortu
- Dashboard: **Grid layout responsif**, menyesuaikan lebar layar desktop
- Create Report: ditampilkan sebagai **dialog/popup**, bukan halaman penuh (khusus web — tidak memengaruhi desain mobile)

---

## 5. Ikonografi
Menggunakan Material Icons standar Flutter, dikombinasikan dengan warna semantic di atas untuk komunikasi status (mis. ikon centang hijau = valid, ikon jam kuning = menunggu validasi, ikon silang merah = ditolak).

---

## 6. Prinsip Desain
1. **Konsisten lintas platform** — palet warna dan radius komponen sama antara mobile & web; yang berbeda hanya struktur navigasi (bottom tab vs top navbar) menyesuaikan konvensi platform.
2. **Jelas secara status** — setiap status laporan/mediasi punya representasi warna semantic yang konsisten agar mudah dipindai secara visual.
3. **Ramah non-teknis** — kontras warna tinggi, ukuran tap target minimum `50px` tinggi pada tombol, sesuai kebutuhan pengguna sekolah dengan literasi digital beragam.

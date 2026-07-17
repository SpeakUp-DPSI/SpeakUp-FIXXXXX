# Design System
## SpeakUp — Sistem Pelaporan dan Penanganan Kasus Perundungan
**Versi:** 1.0  
**Tanggal:** Juni 2025  
**Program Studi:** Sistem Informasi — Universitas Ahmad Dahlan Yogyakarta

---

## 1. Filosofi Desain

SpeakUp dirancang dengan prinsip **"Aman, Jelas, dan Tepercaya"**. Setiap keputusan visual bertujuan untuk:

- **Memberikan rasa aman** — siswa harus merasa terlindungi saat mengakses dan menggunakan aplikasi
- **Kejelasan navigasi** — setiap peran pengguna menemukan fitur yang relevan tanpa kebingungan
- **Kepercayaan institusional** — tampilan profesional yang mencerminkan sistem resmi sekolah
- **Aksesibilitas** — dapat digunakan oleh semua kalangan termasuk siswa SMP/SMA

---

## 2. Brand Identity

### 2.1 Nama Aplikasi
**SpeakUp**

### 2.2 Tagline
*"Berani Bicara, Bersama Kita Selesaikan"*

### 2.3 Logo Guidelines
- Logo terdiri dari wordmark **SpeakUp** dengan ikon gelembung bicara (speech bubble) yang terintegrasi
- Ikon melambangkan keberanian untuk bersuara dan melapor
- Minimum ukuran logo: 120px lebar (digital), 3 cm (cetak)
- Jangan memutar, mendistorsi, atau mengubah warna logo di luar ketentuan

---

## 3. Color System

### 3.1 Primary Colors

| Token | Nama | Hex | Penggunaan |
|---|---|---|---|
| `--color-primary-600` | Teal Deep | `#0D7D6C` | CTA utama, tombol primer, highlight aktif |
| `--color-primary-500` | Teal Main | `#12937F` | Hover state tombol primer |
| `--color-primary-100` | Teal Light | `#D1F5EF` | Background badge, highlight ringan |
| `--color-primary-50` | Teal Pale | `#EDFAF7` | Background section, card subtle |

### 3.2 Secondary Colors

| Token | Nama | Hex | Penggunaan |
|---|---|---|---|
| `--color-secondary-600` | Blue Deep | `#1A56DB` | Link, ikon informasi |
| `--color-secondary-100` | Blue Light | `#DBEAFE` | Background info alert |

### 3.3 Neutral Colors

| Token | Nama | Hex | Penggunaan |
|---|---|---|---|
| `--color-neutral-900` | Gray 900 | `#111827` | Body text utama |
| `--color-neutral-700` | Gray 700 | `#374151` | Subtext, label |
| `--color-neutral-500` | Gray 500 | `#6B7280` | Placeholder, helper text |
| `--color-neutral-300` | Gray 300 | `#D1D5DB` | Border, divider |
| `--color-neutral-100` | Gray 100 | `#F3F4F6` | Background page, tabel stripe |
| `--color-neutral-50` | Gray 50 | `#F9FAFB` | Background card |
| `--color-white` | White | `#FFFFFF` | Surface utama |

### 3.4 Semantic / Status Colors

| Token | Nama | Hex | Penggunaan |
|---|---|---|---|
| `--color-success-600` | Green | `#059669` | Status selesai, valid, berhasil |
| `--color-success-100` | Green Light | `#D1FAE5` | Background badge sukses |
| `--color-warning-600` | Amber | `#D97706` | Status diproses, menunggu |
| `--color-warning-100` | Amber Light | `#FEF3C7` | Background badge peringatan |
| `--color-danger-600` | Red | `#DC2626` | Status ditolak, error, hapus |
| `--color-danger-100` | Red Light | `#FEE2E2` | Background badge bahaya |
| `--color-info-600` | Blue | `#2563EB` | Status mediasi, informasi |
| `--color-info-100` | Blue Light | `#DBEAFE` | Background badge info |

### 3.5 Status Badge Color Mapping

| Status Laporan | Background | Text | Border |
|---|---|---|---|
| Baru / Laporan Masuk | `--color-neutral-100` | `--color-neutral-700` | `--color-neutral-300` |
| Menunggu Validasi | `--color-warning-100` | `--color-warning-600` | — |
| Valid | `--color-success-100` | `--color-success-600` | — |
| Diproses | `--color-info-100` | `--color-info-600` | — |
| Mediasi | `#EDE9FE` (purple-100) | `#7C3AED` (purple-600) | — |
| Tindak Lanjut | `--color-warning-100` | `--color-warning-600` | — |
| Selesai | `--color-success-100` | `--color-success-600` | — |
| Ditolak | `--color-danger-100` | `--color-danger-600` | — |

---

## 4. Typography

### 4.1 Font Family

```css
--font-primary: 'Inter', 'Segoe UI', sans-serif;   /* UI, body, label */
--font-heading: 'Inter', sans-serif;                /* Heading semua level */
--font-mono: 'JetBrains Mono', 'Courier New', monospace; /* Kode laporan */
```

### 4.2 Type Scale

| Token | Size | Weight | Line Height | Penggunaan |
|---|---|---|---|---|
| `--text-xs` | 12px | 400 | 1.5 | Helper text, caption |
| `--text-sm` | 14px | 400 | 1.5 | Label form, tabel body |
| `--text-base` | 16px | 400 | 1.6 | Body text utama |
| `--text-lg` | 18px | 500 | 1.5 | Subheading, kartu judul |
| `--text-xl` | 20px | 600 | 1.4 | Section title |
| `--text-2xl` | 24px | 700 | 1.3 | Page title, dashboard heading |
| `--text-3xl` | 30px | 700 | 1.2 | Hero title |
| `--text-4xl` | 36px | 800 | 1.1 | Landing page headline |

### 4.3 Font Weight

```css
--font-regular:   400;
--font-medium:    500;
--font-semibold:  600;
--font-bold:      700;
--font-extrabold: 800;
```

### 4.4 Kode Laporan (Monospace)
Kode laporan seperti `SPK-2025-00142` menggunakan `--font-mono` ukuran 14px dengan letter-spacing 0.1em dan background `--color-neutral-100`.

---

## 5. Spacing System

Berbasis kelipatan 4px:

| Token | Value | Penggunaan |
|---|---|---|
| `--space-1` | 4px | Gap antar ikon dan label |
| `--space-2` | 8px | Padding kecil, gap komponen kecil |
| `--space-3` | 12px | Padding badge, gap form field |
| `--space-4` | 16px | Padding card, gap section kecil |
| `--space-5` | 20px | Margin antar elemen |
| `--space-6` | 24px | Padding section, gap kartu |
| `--space-8` | 32px | Padding container, gap besar |
| `--space-10` | 40px | Section padding vertikal |
| `--space-12` | 48px | Section padding besar |
| `--space-16` | 64px | Hero padding |

---

## 6. Border & Shadow

### 6.1 Border Radius

| Token | Value | Penggunaan |
|---|---|---|
| `--radius-sm` | 4px | Input, badge kecil |
| `--radius-md` | 8px | Card, tombol, dropdown |
| `--radius-lg` | 12px | Modal, panel besar |
| `--radius-xl` | 16px | Card hero, dialog |
| `--radius-full` | 9999px | Pill badge, avatar |

### 6.2 Shadow

| Token | Value | Penggunaan |
|---|---|---|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Input, badge |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.07)` | Card default |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Dropdown, modal |
| `--shadow-xl` | `0 20px 25px rgba(0,0,0,0.1)` | Dialog, drawer |

### 6.3 Border

```css
--border-default: 1px solid var(--color-neutral-300);
--border-focus:   2px solid var(--color-primary-500);
--border-error:   1px solid var(--color-danger-600);
```

---

## 7. Component Library

### 7.1 Button

**Ukuran:**
- `btn-sm`: padding 6px 12px, font-size 14px
- `btn-md` (default): padding 10px 20px, font-size 16px
- `btn-lg`: padding 14px 28px, font-size 18px

**Varian:**

| Varian | Background | Text | Border | Hover |
|---|---|---|---|---|
| Primary | `--color-primary-600` | white | — | `--color-primary-500` |
| Secondary | white | `--color-primary-600` | `--color-primary-600` | `--color-primary-50` |
| Danger | `--color-danger-600` | white | — | darker red |
| Ghost | transparent | `--color-neutral-700` | — | `--color-neutral-100` |
| Disabled | `--color-neutral-300` | `--color-neutral-500` | — | no change |

Semua tombol menggunakan `--radius-md`, transisi 150ms ease.

---

### 7.2 Form Elements

**Input Text / Textarea**
```
Height (input):  44px
Border:          --border-default
Border Radius:   --radius-sm
Padding:         12px 16px
Font Size:       16px (--text-base)
Focus Ring:      --border-focus + box-shadow 0 0 0 3px rgba(13,125,108,0.15)
Error State:     --border-error + error message --color-danger-600 --text-sm
```

**Select / Dropdown**
- Sama dengan input, tambahkan ikon chevron kanan
- Gunakan komponen select native atau custom dengan aksesibilitas penuh

**Checkbox & Radio**
- Ukuran: 18px × 18px
- Checked color: `--color-primary-600`
- Label: `--text-base`, `--color-neutral-900`

**File Upload**
- Dashed border `--color-neutral-300`, `--radius-md`
- Background `--color-neutral-50`
- Hover: background `--color-primary-50`, border `--color-primary-500`
- Teks instruksi: `--color-neutral-500 --text-sm`
- Ikon upload: `--color-primary-600`

**Label Form**
- Font: `--text-sm`, `--font-medium`, `--color-neutral-700`
- Required indicator: tanda `*` warna `--color-danger-600`

---

### 7.3 Card

```
Background:    --color-white
Border:        --border-default
Border Radius: --radius-md
Padding:       --space-6 (24px)
Shadow:        --shadow-md
```

**Card Statistik (Dashboard)**
- Header card: label `--text-sm --color-neutral-500`
- Value besar: `--text-2xl --font-bold --color-neutral-900`
- Ikon aksen: warna sesuai konteks (success/warning/danger/info)

---

### 7.4 Badge / Status Chip

```
Padding:       4px 10px
Border Radius: --radius-full
Font Size:     --text-xs
Font Weight:   --font-semibold
```

Gunakan token warna dari **Status Badge Color Mapping** (Bagian 3.5).

---

### 7.5 Table

```
Header background:  --color-neutral-100
Header text:        --text-sm --font-semibold --color-neutral-700
Body text:          --text-sm --color-neutral-900
Row border:         1px solid --color-neutral-200
Row hover:          background --color-neutral-50
Padding per cell:   12px 16px
```

---

### 7.6 Alert / Notification Banner

| Tipe | Background | Border-left | Icon | Text |
|---|---|---|---|---|
| Info | `--color-info-100` | `--color-info-600` | ℹ️ | `--color-info-600` |
| Success | `--color-success-100` | `--color-success-600` | ✅ | `--color-success-600` |
| Warning | `--color-warning-100` | `--color-warning-600` | ⚠️ | `--color-warning-600` |
| Danger | `--color-danger-100` | `--color-danger-600` | ❌ | `--color-danger-600` |

Border-left width: 4px. Padding: 16px. Border-radius: `--radius-md`.

---

### 7.7 Modal / Dialog

```
Overlay:         rgba(0, 0, 0, 0.5)
Container:       background white, --radius-xl, --shadow-xl
Max Width:       560px (form), 800px (detail laporan), 480px (konfirmasi)
Padding:         --space-8 (32px)
Header:          --text-xl --font-bold
Close button:    top-right, ikon × ghost
```

---

### 7.8 Sidebar Navigation

```
Width:           260px (expanded), 64px (collapsed)
Background:      --color-neutral-900
Text default:    --color-neutral-300
Text active:     white
Active item bg:  --color-primary-600
Hover item bg:   --color-neutral-700
Icon size:       20px
Logo area:       height 64px, border-bottom 1px solid --color-neutral-700
```

---

### 7.9 Kode Laporan Display

```
Font:            --font-mono
Font Size:       --text-sm (14px)
Letter Spacing:  0.08em
Background:      --color-neutral-100
Padding:         6px 12px
Border Radius:   --radius-sm
Color:           --color-neutral-900
```

Contoh tampilan: `SPK-2025-00142`

---

## 8. Layout System

### 8.1 Breakpoints

| Nama | Min Width | Penggunaan |
|---|---|---|
| `xs` | 0px | Mobile kecil |
| `sm` | 480px | Mobile standar |
| `md` | 768px | Tablet |
| `lg` | 1024px | Desktop kecil / sidebar collapsed |
| `xl` | 1280px | Desktop standar |
| `2xl` | 1536px | Desktop lebar |

### 8.2 Grid System
- Gunakan 12-column grid
- Gutter: 24px (desktop), 16px (mobile)
- Container max-width: 1200px, centered

### 8.3 Struktur Layout Dashboard

```
┌──────────────────────────────────────────────┐
│  TOPBAR  (height: 64px)                      │
├───────────┬──────────────────────────────────┤
│           │                                  │
│  SIDEBAR  │       MAIN CONTENT               │
│  (260px)  │       (flex-1, padding 32px)     │
│           │                                  │
│           │                                  │
└───────────┴──────────────────────────────────┘
```

### 8.4 Struktur Layout Halaman Publik

```
┌──────────────────────────────────────────────┐
│  HEADER / NAVBAR  (sticky, height: 64px)     │
├──────────────────────────────────────────────┤
│  HERO SECTION                                │
├──────────────────────────────────────────────┤
│  CONTENT SECTIONS (max-width: 1200px)        │
├──────────────────────────────────────────────┤
│  FOOTER                                      │
└──────────────────────────────────────────────┘
```

---

## 9. Iconography

- Library ikon: **Lucide Icons** atau **Heroicons** (outline style)
- Ukuran standar: 20px (inline/tabel), 24px (navigasi sidebar), 32px (kartu statistik), 48px (empty state)
- Warna ikon mengikuti konteks teks atau token warna semantik
- Jangan gunakan ikon filled dan outline secara bersamaan dalam satu tampilan

### Mapping Ikon Fitur Utama

| Fitur | Ikon |
|---|---|
| Buat Laporan | `file-plus` |
| Status Laporan | `clock` / `check-circle` |
| Validasi | `shield-check` |
| Mediasi | `users` |
| Tindak Lanjut | `clipboard-check` |
| Statistik | `bar-chart-2` |
| Notifikasi | `bell` |
| Upload Bukti | `upload-cloud` |
| Riwayat | `history` |
| Profil | `user-circle` |
| Pengaturan | `settings` |
| Logout | `log-out` |
| Anonim | `eye-off` |
| Kode Laporan | `hash` |

---

## 10. Accessibility

- Kontras warna minimum **4.5:1** untuk teks normal, **3:1** untuk teks besar (WCAG AA)
- Semua elemen interaktif memiliki `:focus-visible` outline yang jelas
- Label form selalu terhubung ke input menggunakan atribut `for`/`id` atau `aria-label`
- Error message dihubungkan ke input dengan `aria-describedby`
- Gambar dekoratif menggunakan `alt=""`; gambar bermakna menggunakan alt deskriptif
- Ikon yang berdiri sendiri memiliki `aria-label` atau `title`
- Keyboard navigation: semua fitur dapat dioperasikan tanpa mouse
- Tab order mengikuti urutan visual yang logis

---

## 11. Motion & Animation

```css
--transition-fast:    100ms ease;
--transition-default: 150ms ease;
--transition-slow:    300ms ease;
```

- Gunakan transisi hanya untuk feedback interaksi: hover, focus, open/close
- Hindari animasi yang berlebihan; prioritaskan kejelasan di atas estetika
- Modal/drawer: fade + slide 200ms
- Toast notification: slide-in dari kanan 150ms, slide-out 100ms
- Grafik/chart: animasi masuk sekali saat load, durasi 400ms

---

## 12. Dark Mode (Opsional — Pengembangan Lanjutan)

Jika dark mode diimplementasikan, gunakan token semantik:

```css
/* Light (default) */
--bg-surface:   #FFFFFF;
--bg-page:      #F3F4F6;
--text-primary: #111827;

/* Dark */
--bg-surface:   #1F2937;
--bg-page:      #111827;
--text-primary: #F9FAFB;
```

---

## 13. Tone of Voice (Konten UI)

Konten teks dalam antarmuka SpeakUp menggunakan tone:

- **Ramah dan empatik** — siswa harus merasa didukung, bukan diadili
- **Jelas dan ringkas** — hindari jargon teknis atau hukum yang membingungkan
- **Mendorong keberanian** — gunakan kalimat aktif dan positif
- **Formal namun hangat** — cocok untuk konteks sekolah

**Contoh penulisan:**

| ❌ Hindari | ✅ Gunakan |
|---|---|
| "Input data tidak valid" | "Mohon lengkapi data kejadian terlebih dahulu" |
| "Error 404" | "Halaman tidak ditemukan. Kembali ke Beranda?" |
| "Submit" | "Kirim Laporan" |
| "Username" | "Nama Akun / Email" |
| "Terminate session" | "Keluar dari SpeakUp" |

---

*Dokumen ini disusun sebagai bagian dari tugas mata kuliah Desain dan Pengembangan Sistem Informasi, Program Studi Sistem Informasi, Fakultas Sains dan Teknologi Terapan, Universitas Ahmad Dahlan Yogyakarta, Tahun Ajaran 2025/2026.*

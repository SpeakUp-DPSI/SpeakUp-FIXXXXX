# Database Design
## SpeakUp — Supabase (PostgreSQL)

> Dokumen ini merefleksikan skema **final** setelah seluruh patch diterapkan
> (termasuk perbaikan kolom `evidence`, fix RLS `mediations`, dan default
> `mediator_id`). Lihat riwayat migrasi di bagian akhir dokumen.

---

## 1. Entity Relationship Diagram (ERD — tekstual)

```
auth.users (Supabase Auth)
    │ 1:1
    v
profiles ──────────────────────────┐
 (id, name, email, phone,          │ child_id (self-reference, ortu → siswa)
  avatar_url, role, child_id)      │
    │ 1:N                          │
    │                              │
    v                              │
reports ◄───────────────────────────┘ (reporter_id)
 (id, report_code, reporter_id,
  title, category, description,
  status, is_anonymous,
  incident_location, incident_date)
    │
    ├─ 1:N ─> evidence (report_id, file_url, file_name, file_type)
    ├─ 1:N ─> validations (report_id, validator_id, status, notes)
    ├─ 1:N ─> mediations (report_id, mediator_id, schedule_date, location, status, result)
    │            │
    │            └─ 1:N ─> mediation_participants (mediation_id, user_id, status)
    ├─ 1:N ─> follow_ups (report_id, executor_id, action_taken, follow_up_date)
    ├─ 1:N ─> report_participants (report_id, role, user_id, name, class_name)
    └─ 1:N ─> report_status_histories (report_id, user_id, status, notes)

profiles ── 1:N ─> notifications (user_id, title, body, type, reference_id, is_read)
profiles ── 1:N ─> audit_logs (user_id, action, model_type, model_id, changes)
```

---

## 2. Kamus Tabel

### 2.1 `profiles`
Extends `auth.users`. Menggantikan tabel `users` Laravel + sistem role Spatie.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid (PK) | = `auth.users.id` |
| name | text | Wajib |
| email | text | Unik |
| phone | text | Opsional |
| avatar_url | text | Opsional |
| fcm_token | text | Untuk push notification |
| role | enum `app_role` | admin / siswa / guru_bk / kepsek / ortu |
| child_id | uuid (FK → profiles.id) | Diisi khusus akun `ortu`, menunjuk ke profil anak (siswa) |
| created_at / updated_at | timestamptz | Auto |

### 2.2 `reports`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK, identity) | |
| report_code | text (unik) | Auto-generate via trigger `generate_report_code()` |
| reporter_id | uuid (FK → profiles) | Pembuat laporan |
| title | text | |
| category | text | |
| description | text | |
| status | enum `report_status` | draft/submitted/waiting_validation/valid/processing/mediation/follow_up/completed/rejected |
| is_anonymous | boolean | Default false |
| incident_location | text | Opsional |
| incident_date | date | Opsional |
| deleted_at | timestamptz | Soft delete |
| created_at / updated_at | timestamptz | Auto |

### 2.3 `evidence`
*(kolom sudah disesuaikan agar cocok dengan kode aplikasi — lihat riwayat patch)*

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| file_url | text | Path/URL file di Storage bucket `evidence` |
| file_name | text | Nama file asli |
| file_type | text (nullable) | image/video/pdf/document — auto-diisi via trigger `guess_evidence_file_type()` jika kosong |
| created_at / updated_at | timestamptz | Auto |

### 2.4 `validations`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| validator_id | uuid (FK → profiles) | Harus role guru_bk/admin |
| status | enum `validation_status` | valid / rejected |
| notes | text | |
| created_at / updated_at | timestamptz | |

### 2.5 `mediations`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| mediator_id | uuid (FK → profiles) | Auto-diisi dari user login via trigger `set_mediator_id_default()` jika tidak dikirim aplikasi |
| schedule_date | timestamptz | |
| location | text | |
| status | enum `mediation_status` | scheduled/ongoing/completed/cancelled |
| result | text | Diisi saat mediasi selesai |
| created_at / updated_at | timestamptz | |

### 2.6 `mediation_participants`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| mediation_id | bigint (FK → mediations) | |
| user_id | uuid (FK → profiles) | |
| status | enum `mediation_participant_status` | pending/confirmed/rejected/attended |
| created_at / updated_at | timestamptz | |

### 2.7 `follow_ups`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| executor_id | uuid (FK → profiles) | guru_bk yang mengeksekusi |
| action_taken | text | |
| follow_up_date | timestamptz | |
| created_at / updated_at | timestamptz | |

### 2.8 `report_participants`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| role | text | korban / terlapor / saksi |
| user_id | uuid (FK → profiles, nullable) | Jika pihak terkait punya akun terdaftar |
| name | text | Nama bebas (jika tidak terdaftar sebagai user) |
| class_name | text | |
| notes | text | |

### 2.9 `report_status_histories`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| report_id | bigint (FK → reports) | |
| user_id | uuid (FK → profiles, nullable) | Siapa yang mengubah status |
| status | text | |
| notes | text | |
| created_at | timestamptz | Diisi otomatis via trigger `track_report_status_history()` / `track_report_status_initial()` |

### 2.10 `notifications`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| user_id | uuid (FK → profiles) | Penerima |
| title | text | |
| body | text | |
| type | text | report_status / mediation_schedule / info |
| reference_id | bigint | Id entitas terkait (laporan/mediasi) |
| is_read | boolean | Default false |

### 2.11 `audit_logs`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint (PK) | |
| user_id | uuid (FK → profiles, nullable) | |
| action | text | create/update/delete/login |
| model_type | text | |
| model_id | bigint | |
| changes | jsonb | |
| ip_address | text | |

---

## 3. Enum Types

| Enum | Nilai |
|---|---|
| `app_role` | admin, siswa, guru_bk, kepsek, ortu |
| `report_status` | draft, submitted, waiting_validation, valid, processing, mediation, follow_up, completed, rejected |
| `validation_status` | valid, rejected |
| `mediation_status` | scheduled, ongoing, completed, cancelled |
| `mediation_participant_status` | pending, confirmed, rejected, attended |

---

## 4. Storage Buckets

| Bucket | Visibilitas | Path Convention |
|---|---|---|
| `evidence` | **Publik** (diubah dari privat semula) | `{report_id}/{nama_file}` |
| `avatars` | Publik | `{user_id}/{nama_file}` |

---

## 5. Row Level Security (RLS)

Seluruh tabel mengaktifkan RLS. Ringkasan aturan ada di dokumen **System Logic**, bagian 2. Detail lengkap SQL policy tersedia di file `speakup_supabase_schema.sql` dan patch-patch berikutnya.

---

## 6. Riwayat Migrasi & Patch

| # | Perubahan | Alasan |
|---|---|---|
| 1 | Skema awal: 11 tabel + enum + RLS + storage bucket | Migrasi dari Laravel/MySQL ke Supabase/Postgres |
| 2 | Postgres functions: `dashboard_statistics`, `get_my_mediations`, `generate_report_code` + trigger, `track_report_status_history` + trigger, `contact_participant` | Menyalin logika bisnis backend Laravel ke Postgres function/trigger |
| 3 | Fix: kolom enum `'resolved'` tidak valid → dihapus; kolom `created_by`→`user_id`; parameter `contact_participant` uuid→bigint; guard `is_staff()` pada `dashboard_statistics`; pin `search_path` di semua `SECURITY DEFINER` function | Bug ditemukan sebelum dijalankan (code review) |
| 4 | Rename `evidence.file_path`→`file_url`, `evidence.original_name`→`file_name`; `file_type` dibuat nullable; tambah trigger `guess_evidence_file_type()` | Kode aplikasi mengirim nama kolom berbeda dari skema awal (`PGRST204`) |
| 5 | Bucket `evidence` diubah dari privat menjadi publik | `getPublicUrl()` di kode aplikasi tidak berfungsi untuk bucket privat; disepakati publik demi kesederhanaan |
| 6 | Tambah fungsi `is_mediation_participant()`, `is_mediation_mediator()`; ganti policy `mediations_select` & `mediation_participants_select` | Fix *infinite recursion* (error 42P17) akibat kedua policy saling mereferensi |
| 7 | Tambah trigger `set_mediator_id_default()` pada `mediations` | Kode aplikasi tidak mengirim `mediator_id` saat membuat jadwal mediasi, menyebabkan NOT NULL violation |

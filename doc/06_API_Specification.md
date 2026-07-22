# API Specification
## SpeakUp — Supabase Data API

> Sejak migrasi ke Supabase, SpeakUp **tidak lagi menggunakan REST API kustom**
> (Laravel). Seluruh operasi data dilakukan lewat **Supabase Client SDK**
> (`supabase_flutter`), yang secara otomatis memetakan ke:
> - **PostgREST** untuk operasi CRUD tabel (`supabase.from('table')...`)
> - **RPC** untuk memanggil Postgres function (`supabase.rpc('function_name', params)`)
> - **GoTrue** untuk autentikasi (`supabase.auth...`)
> - **Storage API** untuk file (`supabase.storage.from('bucket')...`)
>
> Dokumen ini mendaftar seluruh endpoint yang dipakai, disusun dalam gaya
> spesifikasi API agar mudah dijadikan acuan lintas tim.

**Base URL:** `https://dnznelktfptccxudbeib.supabase.co`
**Autentikasi:** Bearer token (`access_token` dari `supabase.auth.currentSession`), otomatis disisipkan oleh SDK di setiap request.

---

## 1. Authentication

### 1.1 Register
`supabase.auth.signUp()`
```dart
await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'name': name, 'phone': phone, 'role': 'siswa'},
);
```
Trigger `handle_new_user()` otomatis membuat baris `profiles`.

### 1.2 Login
`supabase.auth.signInWithPassword()`
```dart
await supabase.auth.signInWithPassword(email: email, password: password);
```

### 1.3 Logout
`supabase.auth.signOut()`

### 1.4 Reset Password
`supabase.auth.resetPasswordForEmail(email)`

### 1.5 Get Current User Profile
```dart
await supabase.from('profiles').select().eq('id', supabase.auth.currentUser!.id).single();
```

---

## 2. Reports

| Aksi | Method (SDK) | Tabel/Fungsi | Catatan |
|---|---|---|---|
| Buat laporan | `.from('reports').insert({...})` | `reports` | `report_code` auto-generate; `reporter_id` wajib diisi = user login |
| Lihat daftar laporan | `.from('reports').select()` | `reports` | RLS otomatis filter sesuai role (siswa: milik sendiri, ortu: milik anak, staff: semua) |
| Lihat detail laporan | `.from('reports').select().eq('id', id).single()` | `reports` | |
| Update status laporan | `.from('reports').update({'status': ...}).eq('id', id)` | `reports` | Hanya staff atau reporter (jika masih draft); histori status tercatat otomatis |
| Hapus laporan | `.from('reports').delete().eq('id', id)` | `reports` | Hanya staff |

**Contoh payload insert:**
```json
{
  "reporter_id": "uuid-user-login",
  "title": "Diejek terus di grup kelas",
  "category": "Perundungan Verbal",
  "description": "...",
  "is_anonymous": false,
  "incident_location": "Kelas",
  "incident_date": "2026-07-15"
}
```

---

## 3. Evidence

| Aksi | Method (SDK) |
|---|---|
| Upload file | `supabase.storage.from('evidence').uploadBinary('{report_id}/{filename}', bytes)` |
| Ambil URL publik | `supabase.storage.from('evidence').getPublicUrl(path)` |
| Simpan metadata | `.from('evidence').insert({'report_id': id, 'file_url': url, 'file_name': name})` |
| Lihat bukti laporan | `.from('evidence').select().eq('report_id', id)` |

> `file_type` opsional — akan diisi otomatis oleh trigger database berdasarkan ekstensi `file_name` jika tidak dikirim.

---

## 4. Validations

| Aksi | Method (SDK) | Wewenang |
|---|---|---|
| Validasi laporan | `.from('validations').insert({'report_id': id, 'validator_id': uid, 'status': 'valid'/'rejected', 'notes': '...'})` | guru_bk / admin |
| Lihat riwayat validasi | `.from('validations').select().eq('report_id', id)` | Pemilik laporan / staff |

---

## 5. Mediations

| Aksi | Method (SDK) | Wewenang |
|---|---|---|
| Jadwalkan mediasi | `.from('mediations').insert({'report_id': id, 'schedule_date': ..., 'location': ...})` | guru_bk / admin. `mediator_id` otomatis = user login jika tidak dikirim |
| Lihat mediasi saya | `supabase.rpc('get_my_mediations')` | Mediator atau peserta |
| Update / selesaikan mediasi | `.from('mediations').update({'status': 'completed', 'result': '...'}).eq('id', id)` | Staff atau mediator |
| Hubungi peserta | `supabase.rpc('contact_participant', {'mediation_id': id})` | Mediator laporan tsb / staff |
| Tambah peserta | `.from('mediation_participants').insert({'mediation_id': id, 'user_id': uid})` | guru_bk / admin |
| Konfirmasi kehadiran | `.from('mediation_participants').update({'status': 'confirmed'}).eq('id', id)` | Peserta sendiri / staff |

---

## 6. Follow-ups

| Aksi | Method (SDK) | Wewenang |
|---|---|---|
| Buat tindak lanjut | `.from('follow_ups').insert({'report_id': id, 'action_taken': '...', 'follow_up_date': ...})` | guru_bk / admin |
| Lihat tindak lanjut | `.from('follow_ups').select().eq('report_id', id)` | Pemilik laporan / staff |

---

## 7. Report Participants

| Aksi | Method (SDK) |
|---|---|
| Tambah pihak terkait | `.from('report_participants').insert({'report_id': id, 'role': 'terlapor', 'name': '...', 'class_name': '...'})` |
| Lihat pihak terkait | `.from('report_participants').select().eq('report_id', id)` |

---

## 8. Notifications

| Aksi | Method (SDK) |
|---|---|
| Lihat notifikasi saya | `.from('notifications').select().eq('user_id', uid).order('created_at', ascending: false)` |
| Tandai dibaca | `.from('notifications').update({'is_read': true}).eq('id', id)` |
| Realtime subscribe | `supabase.channel('notifications').on(...).subscribe()` |

---

## 9. Dashboard & Statistics

| Aksi | Method (SDK) | Wewenang |
|---|---|---|
| Statistik agregat | `supabase.rpc('dashboard_statistics')` | Staff (admin/guru_bk/kepsek) saja |

**Contoh response:**
```json
{
  "total": 42,
  "today": 2,
  "this_month": 15,
  "valid": 20,
  "processing": 5,
  "mediation": 3,
  "completed": 12
}
```

---

## 10. User Management (Admin)

| Aksi | Method (SDK) |
|---|---|
| Daftar pengguna | `.from('profiles').select()` |
| Tambah pengguna | Admin API `supabase.auth.admin.createUser()` (butuh service role, dijalankan lewat Edge Function/backend admin, bukan dari client langsung) |
| Edit profil pengguna | `.from('profiles').update({...}).eq('id', id)` |
| Hapus pengguna | Admin API `supabase.auth.admin.deleteUser(id)` |
| Ubah role | `.from('profiles').update({'role': newRole}).eq('id', id)` |

---

## 11. Audit Log

| Aksi | Method (SDK) | Wewenang |
|---|---|---|
| Lihat audit log | `.from('audit_logs').select().order('created_at', ascending: false)` | Admin saja |

---

## 12. RPC (Postgres Functions) — Ringkasan

| Fungsi | Parameter | Return | Wewenang |
|---|---|---|---|
| `dashboard_statistics()` | – | json | Staff |
| `get_my_mediations()` | – | json[] | User login |
| `contact_participant(mediation_id)` | bigint | void | Mediator / staff |

---

## 13. Error Handling

Semua error dari Supabase muncul sebagai:
- `PostgrestException` — error query/RLS/constraint database (contoh: `PGRST204` kolom tidak ditemukan, `23502` NOT NULL violation, `42P17` infinite recursion RLS).
- `AuthException` — error autentikasi (email sudah terdaftar, password salah, dll).
- `StorageException` — error upload/akses file.

Aplikasi menampilkan `message` dari exception ke pengguna dalam bentuk snackbar/banner error.

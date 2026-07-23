# PROJECT DOCUMENTATION
# SpeakUp - Mobile Application
## Sistem Pelaporan dan Penanganan Kasus Perundungan

---

# 1. Project Overview

## Deskripsi

SpeakUp merupakan aplikasi mobile yang dirancang untuk membantu proses pelaporan, validasi, penanganan, monitoring, dan dokumentasi kasus perundungan (bullying) di lingkungan sekolah.

Aplikasi dikembangkan berdasarkan hasil observasi dan wawancara di SMK Muhammadiyah 4 Yogyakarta yang menunjukkan bahwa proses pelaporan masih dilakukan secara manual sehingga menyebabkan keterlambatan penanganan, kurangnya dokumentasi, dan rendahnya keberanian siswa untuk melapor.

---

# 2. Tujuan Sistem

Sistem dikembangkan untuk:

- menyediakan pelaporan anonim
- mempermudah unggah bukti
- membantu Guru BK melakukan validasi
- mengelola proses mediasi
- mencatat tindak lanjut
- memberikan notifikasi kepada wali
- menyediakan dashboard monitoring
- menghasilkan rekapitulasi otomatis

---

# 3. Stakeholder

| Role | Deskripsi |
|-------|-----------|
| Siswa | Membuat laporan dan melihat status |
| Guru BK | Mengelola seluruh proses penanganan |
| Kepala Sekolah | Monitoring dan evaluasi |
| Orang Tua/Wali | Menerima informasi dan konfirmasi mediasi |
| Admin | Mengelola pengguna dan hak akses |

---

# 4. Fitur Utama

## Authentication

- Login
- Logout
- Forgot Password
- Role Based Access
- Session Management

---

## Dashboard

### Siswa

- Ringkasan laporan
- Status laporan
- Edukasi
- Riwayat laporan

### Guru BK

- Dashboard kasus
- Manajemen laporan
- Validasi
- Mediasi
- Tindak lanjut
- Rekapitulasi

### Kepala Sekolah

- Statistik
- Monitoring
- Grafik
- Rekapitulasi

### Orang Tua

- Informasi anak
- Jadwal mediasi
- Notifikasi
- Hasil tindak lanjut

---

# 5. Functional Requirements

## Siswa

- Membuat laporan
- Pelaporan anonim
- Upload bukti
- Melihat status
- Edit profil

## Guru BK

- Validasi laporan
- Mengubah status
- Mengelola mediasi
- Membuat tindak lanjut
- Melihat riwayat perilaku
- Rekapitulasi

## Kepala Sekolah

- Monitoring kasus
- Statistik
- Rekapitulasi

## Orang Tua

- Melihat informasi anak
- Konfirmasi jadwal
- Melihat hasil mediasi

## Admin

- CRUD User
- Role Management
- Permission Management

---

# 6. Non Functional Requirements

- Flutter
- Android
- iOS
- Responsive
- Material 3
- Clean Architecture
- REST API
- HTTPS
- Firebase Notification
- Secure Storage
- Fast Loading
- Pagination
- Offline Cache

---

# 7. Information Architecture

Splash

↓

Onboarding

↓

Login

↓

Dashboard

↓

Report

↓

Validation

↓

Mediation

↓

Follow Up

↓

Completed

---

# 8. User Flow

## Siswa

Login

↓

Dashboard

↓

Buat Laporan

↓

Upload Bukti

↓

Submit

↓

Lihat Status

---

## Guru BK

Login

↓

Dashboard

↓

Laporan Masuk

↓

Validasi

↓

Update Status

↓

Mediasi

↓

Tindak Lanjut

↓

Selesai

---

## Kepala Sekolah

Login

↓

Dashboard

↓

Monitoring

↓

Statistik

↓

Rekapitulasi

---

## Orang Tua

Login

↓

Notifikasi

↓

Informasi Anak

↓

Konfirmasi Jadwal

↓

Hasil Mediasi

---

# 9. Class Diagram Summary

## User

- Siswa
- Guru BK
- Kepala Sekolah
- Orang Tua

Semua merupakan turunan dari class Pengguna.

Entity utama

- Laporan
- Bukti
- Validasi
- Mediasi
- Tindak Lanjut
- Notifikasi
- Rekapitulasi
- Riwayat Perilaku

---

# 10. Database Entity

User

Student

Teacher

Parent

Report

Evidence

Validation

Mediation

FollowUp

Notification

BehaviorHistory

Recapitulation

Role

Permission

---

# 11. Role Permission

| Menu | Siswa | Guru BK | Kepala | Wali | Admin |
|------|------|---------|---------|------|-------|
| Dashboard | ✓ | ✓ | ✓ | ✓ | ✓ |
| Laporan | ✓ | ✓ | ✓ | ✕ | ✓ |
| Validasi | ✕ | ✓ | ✕ | ✕ | ✓ |
| Mediasi | ✕ | ✓ | ✕ | ✓ | ✓ |
| Rekap | ✕ | ✓ | ✓ | ✕ | ✓ |
| User Management | ✕ | ✕ | ✕ | ✕ | ✓ |

---

# 12. Status Laporan

Draft

↓

Dikirim

↓

Menunggu Validasi

↓

Valid

↓

Diproses

↓

Mediasi

↓

Tindak Lanjut

↓

Selesai

atau

↓

Ditolak

---

# 13. Notification Flow

Laporan dibuat

↓

Guru BK menerima notifikasi

↓

Validasi selesai

↓

Siswa menerima status

↓

Orang tua menerima informasi

↓

Kepala sekolah menerima statistik

---

# 14. Frontend Architecture

Framework

Flutter

State Management

Riverpod

Architecture

Clean Architecture

Navigation

Go Router

Networking

Dio

Storage

Secure Storage

Notification

Firebase Cloud Messaging

Pattern

Repository Pattern

Dependency Injection

SOLID

Feature First

---

# 15. Backend Architecture

Framework

Laravel 12

Database

MySQL

Authentication

Laravel Sanctum

Storage

Laravel Storage

Queue

Laravel Queue

Notification

Laravel Notification

Authorization

Spatie Permission

---

# 16. API Module

Authentication

User

Report

Evidence

Validation

Mediation

Follow Up

Notification

Recapitulation

Statistics

Profile

Settings

---

# 17. Design System

Material 3

Typography

Color Token

Spacing

Elevation

Radius

Button

Input

Card

Dialog

Bottom Sheet

Snackbar

Status Color

Accessibility

Dark Mode Ready

---

# 18. Security

HTTPS

Authentication

Authorization

RBAC

Secure Storage

Password Hash

Input Validation

Rate Limiter

Audit Log

Session Timeout

---

# 19. Development Roadmap

Phase 1

Authentication

Phase 2

Dashboard

Phase 3

Report

Phase 4

Validation

Phase 5

Mediation

Phase 6

Notification

Phase 7

Statistics

Phase 8

Testing

Phase 9

Deployment

---

# 20. Tech Stack

## Mobile

Flutter

Dart

Riverpod

Go Router

Dio

Material 3

Firebase Messaging

Secure Storage

## Backend

Laravel 12

PHP 8

MySQL

Sanctum

Spatie Permission

REST API

## Deployment

Docker

Nginx

GitHub

Firebase

Google Play Store

Apple App Store

---

# 21. Kesimpulan

SpeakUp merupakan aplikasi mobile berbasis Flutter yang dibangun menggunakan Clean Architecture dan REST API Laravel untuk mendukung proses pelaporan serta penanganan kasus perundungan secara digital.

Dokumen ini menjadi acuan utama pengembangan frontend, backend, database, API, UI/UX, serta deployment sehingga seluruh tim pengembang memiliki referensi yang sama selama proses implementasi.
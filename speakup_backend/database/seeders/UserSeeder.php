<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin
        $admin = User::firstOrCreate([
            'email' => 'admin@speakup.com',
        ], [
            'name' => 'Super Admin',
            'password' => Hash::make('password123'),
        ]);
        $admin->assignRole('admin');

        // Guru BK
        $guruBk = User::firstOrCreate([
            'email' => 'gurubk@speakup.com',
        ], [
            'name' => 'Ibu Rina, S.Pd',
            'password' => Hash::make('password123'),
        ]);
        $guruBk->assignRole('guru_bk');

        // Siswa
        $siswa = User::firstOrCreate([
            'email' => 'siswa@speakup.com',
        ], [
            'name' => 'Budi Santoso',
            'password' => Hash::make('password123'),
        ]);
        $siswa->assignRole('siswa');
        
        // Kepsek
        $kepsek = User::firstOrCreate([
            'email' => 'kepsek@speakup.com',
        ], [
            'name' => 'Bpk. Kepala Sekolah',
            'password' => Hash::make('password123'),
        ]);
        $kepsek->assignRole('kepsek');

        // Ortu
        $ortu = User::firstOrCreate([
            'email' => 'ortu@speakup.com',
        ], [
            'name' => 'Bpk. Ahmad Santoso',
            'password' => Hash::make('password123'),
        ]);
        $ortu->assignRole('ortu');
    }
}

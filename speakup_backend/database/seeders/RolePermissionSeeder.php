<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Define roles
        $roles = [
            'admin',
            'siswa',
            'guru_bk',
            'kepsek',
            'ortu',
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate(['name' => $role]);
        }

        // Define permissions
        $permissions = [
            'manage_users',
            'manage_roles',
            'create_reports',
            'view_reports',
            'validate_reports',
            'manage_mediations',
            'view_statistics',
            'view_children_reports',
            'manage_settings',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Assign permissions to roles
        $admin = Role::findByName('admin');
        $admin->givePermissionTo(Permission::all());

        $siswa = Role::findByName('siswa');
        $siswa->givePermissionTo(['create_reports', 'view_reports']);

        $guruBk = Role::findByName('guru_bk');
        $guruBk->givePermissionTo(['view_reports', 'validate_reports', 'manage_mediations', 'view_statistics']);

        $kepsek = Role::findByName('kepsek');
        $kepsek->givePermissionTo(['view_reports', 'view_statistics']);

        $ortu = Role::findByName('ortu');
        $ortu->givePermissionTo(['view_reports', 'view_children_reports']);
    }
}

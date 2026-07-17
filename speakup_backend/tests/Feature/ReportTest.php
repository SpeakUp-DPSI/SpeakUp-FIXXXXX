<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use Spatie\Permission\Models\Role;

class ReportTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Siapkan Role untuk testing
        Role::create(['name' => 'siswa']);
    }

    public function test_unauthenticated_user_cannot_create_report()
    {
        $response = $this->postJson('/api/reports', [
            'title' => 'Test Report',
            'description' => 'Ini adalah deskripsi test laporan.'
        ]);

        $response->assertStatus(401);
    }

    public function test_authenticated_siswa_can_create_report()
    {
        $user = User::factory()->create();
        $user->assignRole('siswa');

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'title' => 'Test Laporan Bullying',
            'description' => 'Saya melihat kejadian di kantin siang ini.',
            'is_anonymous' => true,
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('data.title', 'Test Laporan Bullying')
                 ->assertJsonPath('data.reporter_id', $user->id)
                 ->assertJsonPath('data.status', 'submitted');
                 
        $this->assertDatabaseHas('reports', [
            'title' => 'Test Laporan Bullying',
            'reporter_id' => $user->id,
            'is_anonymous' => 1,
        ]);
    }
}

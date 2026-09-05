# PPK Room Reservation

Aplikasi web untuk mengelola penggunaan fasilitas kampus (ruang kelas, aula, laboratorium, alat, dan lapangan). Pengguna dapat mengecek ketersediaan dan mengajukan reservasi, serta melaporkan kerusakan atau masalah pada fasilitas. Petugas dan admin memproses kedua alur (reservasi dan laporan) secara terpusat dalam satu sistem.

## Tech Stack

| Layer | Teknologi |
|---|---|
| Backend | Laravel 13, PHP 8.4 |
| Frontend | Blade, Tailwind CSS 4, Vite 8 |
| Database | MySQL 8.0 |
| Containerization | Docker, Docker Compose |
| DB Admin | phpMyAdmin |

## Prasyarat

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
- Git

> **Catatan:** PHP dan Composer **tidak** perlu diinstal di mesin host. Semua dependensi sudah tersedia di dalam container Docker.

## Quick Start

### Otomatis (Recommended)

```bash
# Linux / macOS
chmod +x scripts/setup.sh
./scripts/setup.sh
```

```powershell
# Windows PowerShell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\setup.ps1
```

### Manual

```bash
# 1. Clone repository
git clone https://github.com/Shriv-ert/PPK-Room-Reservation.git
cd PPK-Room-Reservation

# 2. Salin file environment
cp .env.example .env

# 3. Build dan jalankan container
docker compose build
docker compose up -d

# 4. Install dependensi PHP (pertama kali saja)
docker compose exec app composer install

# 5. Generate application key (pertama kali saja)
docker compose exec app php artisan key:generate

# 6. Jalankan migrasi database
docker compose exec app php artisan migrate

# 7. (Opsional) Jalankan seeder
docker compose exec app php artisan db:seed
```

Aplikasi siap diakses setelah langkah di atas selesai.

## Akses Layanan

| Layanan | URL | Keterangan |
|---|---|---|
| Aplikasi | [http://localhost:8000](http://localhost:8000) | Laravel application |
| phpMyAdmin | [http://localhost:8080](http://localhost:8080) | Database admin UI |
| MySQL | `localhost:3306` | Direct DB connection |

## Docker Services

| Service | Container | Image | Port |
|---|---|---|---|
| `app` | `ppk_app` | Custom (PHP 8.4-cli + Composer) | 8000 |
| `db` | `ppk_db` | mysql:8.0 | 3306 |
| `phpmyadmin` | `ppk_phpmyadmin` | phpmyadmin/phpmyadmin:latest | 8080 |

## Perintah Umum

```bash
# Menjalankan semua container
docker compose up -d

# Menghentikan semua container
docker compose down

# Melihat log container
docker compose logs -f

# Masuk ke shell container app
docker compose exec app bash

# Menjalankan artisan command
docker compose exec app php artisan <command>

# Menjalankan migrasi
docker compose exec app php artisan migrate

# Rollback migrasi
docker compose exec app php artisan migrate:rollback

# Menjalankan test
docker compose exec app php artisan test

# Install dependensi Composer
docker compose exec app composer install

# Rebuild container setelah mengubah Dockerfile
docker compose build app
docker compose up -d app
```

## Struktur Proyek

```
├── app/                    # Kode aplikasi Laravel (Models, Controllers, dll.)
├── bootstrap/              # Laravel bootstrap files
├── config/                 # Konfigurasi aplikasi
├── database/
│   ├── factories/          # Model factories
│   ├── migrations/         # Database migrations
│   └── seeders/            # Database seeders
├── docker/
│   └── php/
│       └── custom.ini      # Konfigurasi PHP custom
├── public/                 # Entry point & public assets
├── resources/              # Views, CSS, JS
├── routes/                 # Route definitions
├── storage/                # Logs, cache, uploads
├── tests/                  # Unit & feature tests
├── .env.example            # Template environment variables
├── docker-compose.yml      # Docker Compose configuration
├── Dockerfile              # PHP application container
├── CASE.md                 # Spesifikasi & user stories proyek
└── meet-1.md               # Notulen meeting pertama
```

## Konfigurasi Database

Kredensial default (dapat diubah di `.env`):

| Key | Default |
|---|---|
| `DB_DATABASE` | `ppk_room_reservation` |
| `DB_USERNAME` | `laravel_user` |
| `DB_PASSWORD` | `laravel_password` |
| `DB_ROOT_PASSWORD` | `root_password` |

## Aktor Sistem

| Aktor | Deskripsi |
|---|---|
| **Pengunjung** | Melihat daftar fasilitas dan ketersediaan jadwal tanpa login |
| **Pengguna** | Mahasiswa/Dosen/Staf yang dapat mengajukan reservasi dan melaporkan kerusakan |
| **Petugas** | Memproses antrian reservasi & laporan kerusakan |
| **Admin** | Mengelola data master fasilitas, akun, dan rekap |

## Tim

Proyek tugas mata kuliah Pengembangan Platform Khusus 2026.

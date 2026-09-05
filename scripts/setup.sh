#!/usr/bin/env bash
# =============================================================================
# PPK Room Reservation — Setup Script (Linux/macOS)
# =============================================================================
# Menjalankan seluruh langkah setup awal proyek menggunakan Docker.
# Pastikan Docker dan Docker Compose sudah terinstal dan berjalan.
#
# Penggunaan:
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh
# =============================================================================

set -euo pipefail

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${CYAN}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pindah ke root proyek (parent dari scripts/)
cd "$(dirname "$0")/.."

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  PPK Room Reservation — Setup${NC}"
echo -e "${CYAN}========================================${NC}"

# --- 1. Cek Docker ---
print_step "Memeriksa Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker tidak ditemukan. Silakan instal Docker terlebih dahulu."
    echo "  → https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker daemon tidak berjalan. Silakan jalankan Docker terlebih dahulu."
    exit 1
fi
print_success "Docker ditemukan dan berjalan."

# --- 2. Cek Docker Compose ---
print_step "Memeriksa Docker Compose..."
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose tidak ditemukan."
    echo "  → https://docs.docker.com/compose/install/"
    exit 1
fi
print_success "Docker Compose ditemukan."

# --- 3. Salin .env ---
print_step "Menyiapkan file .env..."
if [ -f .env ]; then
    print_warning ".env sudah ada, dilewati."
else
    cp .env.example .env
    print_success ".env berhasil dibuat dari .env.example."
fi

# --- 4. Build container ---
print_step "Build container Docker..."
docker compose build
print_success "Build selesai."

# --- 5. Jalankan database terlebih dahulu ---
print_step "Menjalankan database..."
docker compose up -d db
print_success "Database container berjalan."

# --- 6. Tunggu database siap ---
print_step "Menunggu database siap..."
RETRIES=30
until docker compose exec -T db mysqladmin ping -p"${DB_ROOT_PASSWORD:-root_password}" --silent &> /dev/null; do
    RETRIES=$((RETRIES - 1))
    if [ $RETRIES -le 0 ]; then
        print_error "Database tidak merespons setelah timeout."
        exit 1
    fi
    sleep 2
done
print_success "Database siap."

# --- 7. Install dependensi Composer (sebelum app container hidup) ---
print_step "Menginstal dependensi Composer..."
docker compose run --rm --no-deps app composer install
print_success "Dependensi Composer terinstal."

# --- 8. Generate application key ---
print_step "Generate application key..."
docker compose run --rm --no-deps app php artisan key:generate
print_success "Application key berhasil di-generate."

# --- 9. Jalankan migrasi ---
print_step "Menjalankan migrasi database..."
docker compose run --rm app php artisan migrate --force
print_success "Migrasi selesai."

# --- 10. Install dependensi NPM (opsional) ---
print_step "Memeriksa Node.js di container..."
if docker compose run --rm --no-deps app which node &> /dev/null; then
    print_step "Menginstal dependensi NPM..."
    docker compose run --rm --no-deps app npm install
    print_success "Dependensi NPM terinstal."
else
    print_warning "Node.js tidak tersedia di container, lewati install NPM."
fi

# --- 11. Jalankan semua container ---
print_step "Menjalankan semua container..."
docker compose up -d
print_success "Semua container berjalan."

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup selesai!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  Aplikasi   : ${CYAN}http://localhost:8000${NC}"
echo -e "  phpMyAdmin  : ${CYAN}http://localhost:8080${NC}"
echo -e "  MySQL       : ${CYAN}localhost:3306${NC}"
echo ""

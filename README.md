# LTrack :>

Sistem manajemen inventaris laboratorium komputer: spesifikasi PC, barang
pendukung, dan log perbaikan teknisi dengan database lokal (Hive Community
Edition / Hive CE).

Dibangun dengan Flutter.
Diperuntukan sebagai aplikasi Mobile, tapi web juga bisa harusnya.

## Menjalankan

```bash
flutter pub get
flutter run
```

## Struktur

- `lib/models/` — model data (PC, barang pendukung, log perbaikan)
- `lib/services/` — `HiveDatabaseService` (3 box: `pc_box`, `support_box`, `log_box`)
- `lib/pages/` — halaman Beranda, PC Lab, Pendukung, Log Servis
- `lib/widgets/` — komponen UI bersama

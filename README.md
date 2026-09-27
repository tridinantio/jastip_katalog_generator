# Jastip Katalog

Panduan pemakaian aplikasi: [PANDUAN_PENGGUNA.md](PANDUAN_PENGGUNA.md).

Aplikasi Flutter offline-first untuk mencatat produk jastip, menghitung harga
dengan kurs online, dan membuat gambar katalog siap simpan atau bagikan.

## Fitur MVP

- Kurs otomatis ke IDR dari Frankfurter, dengan fallback cache lokal.
- Multi-trip dengan satu trip aktif dan pengaturan unik per trip.
- Pengaturan mata uang, markup, biaya tetap, dan pembulatan harga per trip.
- Perubahan pengaturan menghitung ulang seluruh harga produk pada trip terkait.
- Ambil foto dari kamera atau galeri dan simpan resolusi asli sebagai blob.
- Simpan, cari, lihat, edit, dan hapus produk beserta seluruh aset turunannya.
- Hapus trip beserta seluruh produk dan foto melalui konfirmasi.
- Generate gambar katalog 1080 x 1920 dengan palet warna terkontrol.
- Simpan hasil ke galeri atau buka share sheet.
- Tidak memerlukan akun atau login.

## Menjalankan

```powershell
flutter pub get
dart run build_runner build
flutter run
```

Untuk memasang APK debug pada Android:

```powershell
flutter build apk --debug
flutter install
```

## Struktur

Kode disusun feature-first dengan batas clean architecture:

```text
lib/
  app/                       # dependency composition dan root app
  core/                      # database, theme, formatter, shared errors
  features/
    trip/
      domain/                # entity dan repository contract
      data/                  # Drift + Frankfurter implementation
      presentation/cubit/    # state trip dan kurs
    product/
      domain/                # entity, contract, kalkulasi harga
      data/                  # database dan platform services
      presentation/          # Cubit, form, dan preview katalog
    home/presentation/       # shell dan tampilan utama
```

Database lokal menggunakan Drift/SQLite. File `app_database.g.dart` dibuat oleh
`build_runner` dan ikut disimpan agar aplikasi dapat langsung dibangun.

## Sumber kurs

Kurs berasal dari `https://api.frankfurter.dev/v2`. Kurs adalah kurs referensi
harian dan dapat berbeda dari kurs kartu, bank, atau money changer. Aplikasi
menampilkan tanggal kurs dan menyimpan hasil terakhir untuk kondisi offline.

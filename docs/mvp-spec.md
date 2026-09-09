# Jastip Katalog Generator — MVP v1

## Tujuan

Membantu pemilik jastip mencatat produk saat berada di toko, menghitung harga
jual secara konsisten, lalu membuat gambar katalog siap simpan atau bagikan.
Aplikasi bekerja sepenuhnya offline dan **tidak memiliki autentikasi** pada
versi pertama.

## Ruang lingkup MVP

### Termasuk

1. Membuat beberapa trip dan memilih satu **trip aktif**.
2. Memilih mata uang; aplikasi mengambil kurs ke rupiah secara online, lalu
   menyimpan kurs terakhir untuk penggunaan offline. Markup persen, biaya tetap,
   dan aturan pembulatan tetap dapat diatur per trip.
3. Menambah produk dari kamera atau galeri, lalu menyimpan salinan foto di
   database lokal.
4. Mengisi nama produk dan harga asli; harga katalog diperbarui langsung saat
   input berubah.
5. Melihat, mencari, mengubah, dan menghapus produk pada trip aktif.
6. Membuat satu gambar katalog produk berukuran 1080 x 1920 px dengan palet
   latar pastel yang dipilih secara acak namun tetap terkontrol.
7. Menyimpan hasil gambar ke galeri dan membuka share sheet perangkat.

### Ditunda ke fase berikutnya

- Pesanan pelanggan dan status fulfillment.
- Rekap omzet/profit dan ekspor laporan.
- Katalog online atau sinkronisasi cloud.
- Akun, login, dan multi-pengguna.

Penundaan ini disengaja: MVP tetap fokus pada alur yang paling sering dilakukan
di toko—foto, input harga, lalu membuat materi katalog.

## Alur utama

```text
Trip aktif
  -> Tambah produk
  -> Pilih/ambil foto
  -> Isi nama dan harga asli
  -> Harga katalog dihitung otomatis
  -> Simpan produk
  -> Generate kartu katalog
  -> Simpan ke galeri / Bagikan
```

## Aturan harga

Setiap trip memiliki konfigurasi harga sendiri agar kurs dan markup pada trip
lama tidak berubah ketika pengaturan trip baru diperbarui.

```text
modal_rupiah = harga_asli × kurs_rupiah_per_satuan_mata_uang
fee_persen   = modal_rupiah × markup_persen
subtotal     = modal_rupiah + fee_persen + biaya_tetap
harga_jual   = pembulatan_ke_atas(subtotal, satuan_pembulatan)
```

Default awal:

- markup: 15%
- biaya tetap: Rp0
- pembulatan: Rp1.000 ke atas
- kurs: diambil otomatis dari Frankfurter ketika mata uang dipilih

Harga uang dan hasil perhitungan disimpan sebagai bilangan presisi, bukan
`double`, agar nominal katalog tidak berubah karena galat pembulatan.

Contoh: harga ¥3.000, kurs Rp110, markup 15%, biaya tetap Rp0, pembulatan
Rp1.000 menghasilkan harga katalog Rp380.000.

## Model data lokal

| Entitas | Data inti |
| --- | --- |
| `trip` | nama, negara, tanggal, mata uang, kurs, markup, biaya tetap, pembulatan, status aktif |
| `product` | trip, nama, harga asli, harga jual tersimpan, catatan, kategori, status katalog |
| `product_image` | produk, bytes foto, MIME type, lebar, tinggi, urutan, area crop opsional |
| `product_variant` | produk, nama varian, nilai (mis. ukuran atau warna), stok opsional |
| `generated_asset` | produk, bytes PNG hasil, warna latar, waktu dibuat |
| `app_setting` | palet warna, template aktif, preferensi tampilan |

Foto asli dan PNG hasil disimpan sebagai **blob** di database. Foto asli
disimpan pada resolusi yang dipilih pengguna tanpa kompresi atau pengecilan
tambahan. PNG katalog tetap dibuat pada 1080 x 1920 px.

Daftar produk hanya membaca thumbnail yang diperlukan secara lazy agar UI tetap
responsif meskipun database berisi foto beresolusi tinggi.

## Penyimpanan

Gunakan **Drift + SQLite** sebagai sumber data utama. Pilihan ini sesuai untuk
hubungan trip–produk–gambar–varian, blob foto, transaksi saat menyimpan produk,
pencarian, dan perubahan skema di masa depan. `drift_flutter` digunakan untuk
membuka database dengan konfigurasi Flutter lintas platform.

Gunakan `shared_preferences` hanya untuk preferensi ringan yang tidak kritis,
misalnya pilihan tema atau apakah panduan onboarding sudah dilihat. Jangan
gunakan sebagai database produk.

Kurs harian diambil dari API open-source Frankfurter tanpa API key. Setiap hasil
disimpan bersama tanggal kurs dan waktu pengambilan. Ketika internet tidak
tersedia, aplikasi menggunakan kurs terakhir untuk mata uang tersebut dan
menandainya sebagai data cache. Saat kurs, mata uang, markup, biaya tetap, atau
pembulatan sebuah trip berubah, semua harga jual produk pada trip tersebut
dihitung ulang dalam transaksi database yang sama. Produk pada trip lain tidak
terpengaruh.

## Penghapusan produk

Pengguna dapat menghapus produk dari menu tiga titik pada kartu produk atau
dari halaman detail produk. Sebelum penghapusan final, aplikasi menampilkan
dialog konfirmasi yang menyebutkan bahwa data tidak dapat dipulihkan.

Satu aksi hapus dijalankan dalam satu transaksi database dan menghapus:

- data produk;
- seluruh blob foto produk;
- varian produk; dan
- seluruh PNG katalog yang pernah dibuat dari produk tersebut.

`ProductListCubit` mengunci aksi hapus selama transaksi berlangsung, lalu
memuat ulang daftar dari repository setelah transaksi berhasil. Jika transaksi
gagal, produk tetap tampil dan Cubit mengirim state error yang dapat dicoba
ulang.

## Pengelolaan trip

Setiap trip menyimpan pengaturan kurs dan harga sendiri serta memiliki daftar
produk yang terisolasi. Membuat trip baru sekaligus menjadikannya trip aktif.
Mengganti trip aktif akan memperbarui Beranda, daftar Produk, dan Pengaturan.

Trip dapat dihapus setelah pengguna menyetujui dialog konfirmasi. Penghapusan
trip menghapus seluruh produk, blob foto, dan PNG katalog turunannya melalui
foreign-key cascade. Trip terakhir tidak dapat dihapus agar aplikasi selalu
memiliki satu trip aktif yang valid. Semua penyimpanan hasil edit produk dan
pengaturan trip juga meminta konfirmasi terlebih dahulu.

## Arah UI

Gaya visual: ringan, editorial, dan tenang—terinspirasi dari keterbacaan form
ChatGPT, tetapi tetap memakai komponen Material 3 yang familiar di Android dan
iOS.

### Token awal

- Latar: putih hangat / abu sangat muda.
- Warna aksi utama: charcoal hampir hitam.
- Warna status atau CTA pendukung: satu aksen hijau kebiruan lembut.
- Kartu: putih, garis batas tipis, radius 16 px, tanpa bayangan berat.
- Spasi: kelipatan 8 px; layar memiliki padding 20–24 px.
- Tipografi: judul tegas dan ringkas, teks penjelas kecil berwarna abu.
- Ikon: sederhana, satu gaya Material Symbols.

### Layar Home / Trip aktif

```text
Jastip                       [Trip aktif v]
Japan Trip · 12–18 Okt
12 produk · Estimasi 3 gambar hari ini

[ + Tambah produk ]

Produk terbaru                              Lihat semua
[foto]  Lip Balm                         Rp78.000
        ¥500 · Siap dikatalogkan              [⋯]
[foto]  Tote Bag                        Rp240.000
        ¥1.400 · 2 varian                   [⋯]

             Beranda       Produk       Pengaturan
```

Tombol **Tambah produk** adalah satu aksi dominan. Statistik bersifat kecil dan
tidak mengalahkan daftar produk.

### Layar Tambah produk

Form dibagi dalam blok pendek seperti percakapan, bukan satu halaman padat:

```text
Tambah produk                                      [Simpan]

Foto produk
[ Ambil foto ]  [ Dari galeri ]

Apa nama produknya?
[ Contoh: Lip Balm Strawberry                         ]

Berapa harga aslinya?
[ ¥                         500                         ]
Kurs trip: ¥1 = Rp110                             [Ubah]

Harga untuk katalog
Rp78.000
Modal Rp55.000 · Fee 15% · Dibulatkan Rp1.000

Tambahkan detail (opsional)                         [v]
```

Nilai harga katalog selalu terlihat setelah harga asli terisi. Field lanjutan
(kategori, catatan, varian) tersembunyi secara default agar input di toko cepat.

### Layar Preview katalog

- Preview vertikal dengan foto sebagai fokus utama.
- Nama produk maksimum dua baris; harga jual paling menonjol.
- Tombol `Acak warna` memilih salah satu warna dari palet, bukan membuat warna
  acak tanpa batas.
- Aksi utama: `Simpan ke galeri`; aksi sekunder: `Bagikan`.

Palet awal: cream, peach muda, lilac muda, baby blue, mint, dan butter yellow.

## Batas arsitektur yang akan digunakan

```text
UI (screens/widgets)
  -> Cubits dan immutable states
  -> Repositories
  -> Drift database / image-processing service / gallery service
```

Setiap alur memiliki Cubit sendiri agar state eksplisit, mudah diuji, dan tidak
menjadi satu state global: `ActiveTripCubit`, `ProductListCubit`,
`ProductFormCubit`, dan `CatalogPreviewCubit`. Repository menjadi satu-satunya
jalan untuk membaca atau mengubah data database.

Kalkulasi harga dan pembuatan data kartu katalog ditempatkan di kelas domain
terpisah agar dapat diuji tanpa widget ataupun database. Integrasi kamera,
kompresi foto, galeri, dan penyimpanan gambar dibungkus service milik aplikasi
agar mudah diganti atau diuji.

## Kriteria selesai untuk MVP

1. Produk tetap ada setelah aplikasi ditutup dan dibuka kembali.
2. Harga katalog selalu mengikuti rumus serta pembulatan trip aktif.
3. Foto produk dan PNG katalog tersedia kembali dari blob database lokal.
4. Satu produk dapat menghasilkan PNG 1080 x 1920 px dan hasilnya dapat
   disimpan ke galeri.
5. Semua fungsi inti dapat dipakai tanpa internet dan tanpa login.

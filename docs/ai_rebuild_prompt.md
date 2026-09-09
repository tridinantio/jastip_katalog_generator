# Prompt Lengkap: Bangun Ulang Aplikasi Jastip Katalog

Anda adalah Flutter engineer senior. Buat aplikasi mobile Flutter/Dart yang **siap dijalankan** bernama **Jastip Katalog**. Aplikasi ini dipakai pemilik jasa titip untuk mencatat barang belanja dari berbagai trip, menghitung harga jual dalam Rupiah, membuat katalog produk, mengelola pembeli dan checklist belanja, serta menjaga data lokal melalui backup/restore.

Saya menyerahkan desain UI sepenuhnya kepada Anda. Buat tampilan yang modern, bersih, hangat, mudah dipindai ketika dipakai di toko, dan tetap nyaman untuk data yang banyak. Gunakan Material 3 sebagai fondasi, tetapi jangan menyalin UI aplikasi lain secara mentah. Gunakan bahasa Indonesia untuk seluruh teks antarmuka.

## Batasan utama

- Tidak ada autentikasi, akun, backend, sinkronisasi cloud, atau subscription.
- Aplikasi bersifat **offline-first**. Seluruh data utama disimpan lokal di perangkat.
- Gunakan **Flutter**, null safety, dan arsitektur modular/clean berbasis fitur.
- Gunakan **Cubit / flutter_bloc** untuk state yang memiliki aturan bisnis atau lifecycle data. Gunakan state lokal hanya untuk state UI sementara seperti controller form, tab aktif, atau query sementara.
- Gunakan database SQLite lokal dengan **Drift**. Foto harus disimpan di database sebagai BLOB, bukan hanya path file.
- Struktur minimal yang diharapkan:

```text
lib/
  app/                         # app, theme, dependency composition
  core/                        # database, formatter, error, common widgets
  features/
    trip/
      domain/
      data/
      presentation/
    product/
      domain/
      data/
      presentation/
    shopping/                  # buyer dan checklist
      domain/
      data/
      presentation/
    backup/
      domain/
      data/
      presentation/
    home/
      presentation/
```

- Pisahkan entity/domain contract dari implementasi database, HTTP, file picker, kamera, lokasi, share, dan export. Plugin harus berada di balik service/repository milik aplikasi agar mudah diuji.
- Semua aksi penghapusan dan perubahan yang berdampak besar harus memiliki dialog konfirmasi.
- Jangan membuat APK. Fokus pada source code yang bisa langsung dijalankan dengan `flutter pub get` dan `flutter run`.

## Konsep dan model data

### 1. Trip

Trip adalah unit utama. Semua pengaturan harga dan seluruh produk terisolasi per trip. Satu trip selalu aktif pada satu waktu.

Field trip minimal:

- `id`, `name`, `country`.
- `currencyCode`, `currencyName`, `currencySymbol`.
- `rateMicros` atau representasi kurs presisi lain; jangan gunakan `double` sebagai sumber nilai uang tersimpan.
- `rateDate`, `rateFetchedAt`.
- `markupBasisPoints` (contoh: 1500 = 15%).
- `fixedFeeIdr`.
- `roundingUnitIdr`.
- `isActive`, `createdAt`, `updatedAt`.

Saat database masih kosong, boleh dibuat satu trip awal seperti `Japan Trip` dengan JPY agar aplikasi langsung dapat dipakai. Pastikan hanya ada satu trip aktif.

### 2. Produk

Produk harus terkait dengan tepat satu trip.

Field produk minimal:

- `id`, `tripId`, `name`.
- `originalPriceMinor`: harga asli dalam minor unit mata uang trip agar akurat. Untuk mata uang tanpa pecahan seperti JPY, UI tetap harus mudah dipakai.
- `sellingPriceIdr`: harga jual hasil kalkulasi yang disimpan.
- `markupBasisPointsOverride` nullable dan `fixedFeeIdrOverride` nullable untuk override harga per produk.
- `weightGrams` nullable.
- `category` nullable/kosong jika tidak diisi.
- `note` nullable/kosong jika tidak diisi.
- `imageBytes`, `thumbnailBytes`, `imageMimeType` sebagai BLOB.
- `latitude`, `longitude`, `locationLabel`, `locationCapturedAt`, semuanya opsional.
- `createdAt`, `updatedAt`.

### 3. Buyer / shopping request

Satu produk dapat dititip oleh banyak pembeli. Buyer bukan sekadar string di produk: buat tabel/entitas request agar satu pembeli dapat memiliki jumlah dan status pembelian sendiri.

Field request minimal:

- `id`, `tripId`, `productId`.
- `buyerName`.
- `quantity` minimal 1.
- `note` opsional, misalnya warna atau ukuran.
- `isPurchased`, `purchasedAt`.
- `createdAt`, `updatedAt`.

### 4. Aset katalog dan cache kurs

- Simpan aset gambar katalog yang dihasilkan dengan `productId`, PNG bytes, warna latar, dan tanggal dibuat.
- Simpan cache kurs per pasangan mata uang (base currency ke IDR), nilai kurs, tanggal kurs, dan waktu fetch agar aplikasi masih dapat memakai kurs terakhir saat offline.

## Aturan harga yang wajib

Kurs berarti `1 unit mata uang trip = X Rupiah`.

Gunakan integer untuk nilai uang dan pembulatan. Rumus yang harus diikuti:

```text
modalIdr = pembulatan terdekat(hargaAsli * kurs)
markupProduk = ceil(modalIdr * marginPersen)
subtotal = modalIdr + markupProduk + biayaTetapProduk
hargaJual = ceil(subtotal ke kelipatan unitPembulatanTrip)
```

Catatan implementasi:

- Margin dan biaya tetap produk memakai override produk jika override diisi; jika tidak, gunakan pengaturan trip.
- Produk dengan override **tidak boleh terpengaruh** ketika markup/biaya tetap utama trip diubah.
- Jika mata uang, kurs, markup utama, biaya tetap utama, atau pembulatan trip berubah, hitung ulang seluruh harga jual produk dalam trip itu dalam satu transaksi database.
- Harga asli dalam mata uang asing berguna untuk pemilik, tetapi **jangan tampilkan harga asli/JPY/foreign price pada gambar katalog yang dibagikan ke buyer**. Buyer cukup melihat harga jual Rupiah dan informasi produk yang relevan.
- Tampilkan breakdown harga di form/detail untuk pemilik: modal, margin, biaya, pembulatan, dan harga jual.

## Kurs mata uang

- Ambil kurs terkini online dari API terbuka yang tidak memerlukan API key, misalnya Frankfurter API, untuk pasangan `BASE -> IDR`.
- Sediakan daftar mata uang dari sumber online bila tersedia; sediakan fallback currency populer bila jaringan gagal.
- Cache kurs lokal. Bila permintaan online gagal dan cache tersedia, pakai cache serta tampilkan indikator bahwa data dari cache. Bila tidak ada cache, tampilkan error yang jelas dan jangan menyimpan perubahan kurs setengah jadi.
- Refresh kurs manual harus tersedia.
- Saat membuat trip maupun mengubah mata uang trip, gunakan komponen pemilih mata uang reusable berupa **modal bottom sheet**, bukan dropdown inline yang difilter.
- Bottom sheet harus mempunyai search berdasarkan kode, nama, dan simbol; pilihan aktif diberi indikator check; query pencarian tidak boleh mengosongkan nilai yang sebelumnya dipilih.
- Saat user baru memilih mata uang di form pengaturan tetapi belum menyimpan, tampilkan status pending yang jelas. Jangan menampilkan kurs lama seolah-olah itu kurs mata uang baru.

## Navigasi utama

Gunakan bottom navigation dengan urutan tepat berikut:

1. **Trip**
2. **Pembeli**
3. **Produk**
4. **Pengaturan**

Gunakan `IndexedStack` atau pendekatan setara agar state tab nyaman dipertahankan. Pada Android, back pertama menampilkan pesan singkat seperti “Tekan sekali lagi untuk keluar”, back kedua dalam rentang waktu tertentu baru menutup aplikasi. Jika platform mendukung swipe/back gesture, jangan merusak perilaku native.

## Detail fitur per halaman

### A. Tab Trip / Beranda

Tujuan: menjadi dashboard trip aktif dan pintu masuk cepat menambah produk.

Tampilkan:

- Nama trip aktif dan pemilih trip jika ada lebih dari satu trip.
- Mata uang dan kurs aktif dalam format misalnya `1 JPY = Rp...`, termasuk tanggal kurs atau status cache bila relevan.
- Tombol utama “Tambah produk”.
- Daftar produk terbaru dengan gambar thumbnail, nama, harga jual Rupiah, dan indikator checklist buyer.
- Ringkasan belanja per trip:
  - jumlah request/checklist;
  - total quantity;
  - quantity sudah terbeli vs belum;
  - estimasi total modal;
  - modal aktual dari item yang sudah dicentang terbeli;
  - estimasi keuntungan;
  - total nilai belanja/penjualan yang relevan.

Ringkasan harus dihitung dari produk, request buyer, harga saat ini, dan status checklist. Jika pengaturan trip atau kurs berubah, ringkasan harus ikut berubah otomatis.

### B. Tambah dan edit produk

Form produk harus mendukung create dan edit tanpa membuat record duplikat.

Alur dan input:

1. Foto produk wajib. User dapat memilih **kamera atau galeri** baik saat tambah maupun ganti foto pada edit.
2. Nama produk wajib.
3. Harga asli wajib; label/simbol mengikuti mata uang trip.
4. Preview kurs dan harga jual hasil perhitungan secara langsung.
5. Opsi “gunakan harga khusus produk”. Saat aktif, user bisa mengisi margin persen dan biaya tetap khusus. Jelaskan bahwa produk ini tidak akan mengikuti markup utama trip.
6. Kategori opsional.
7. Berat barang dalam gram opsional.
8. Catatan opsional.
9. Lokasi opsional:
   - tombol ambil lokasi saat ini dengan permission yang benar;
   - simpan latitude, longitude, timestamp;
   - input `nama lokasi` sebagai label manusiawi, misalnya “Don Quijote Shinjuku”;
   - nama lokasi boleh diketik bebas atau dipilih dari daftar label lokasi yang sudah pernah dipakai pada trip tersebut.

Validasi harus jelas: nama tidak boleh kosong, harga tidak boleh negatif, berat bila ada harus positif, margin dan biaya tidak boleh negatif, dan foto wajib tersedia saat membuat produk.

### C. Detail produk

Halaman detail produk menggantikan istilah “preview katalog”.

Tampilkan foto, informasi produk, harga jual, kategori/catatan/berat jika ada, breakdown harga untuk pemilik, pengaturan harga khusus jika berlaku, dan lokasi bila ada.

Aksi utama:

- Edit produk.
- Hapus produk dengan konfirmasi. Penghapusan harus menghapus produk, foto BLOB, seluruh request buyer terkait, dan aset katalog yang terkait dalam transaksi.
- Buat/tampilkan gambar katalog produk.
- Aksi simpan gambar ke galeri dan share diletakkan sebagai icon action di app bar/header, bukan tombol besar di body.
- Jika ada lokasi, aksi “Buka peta” membuka Google Maps/Apple Maps/browser eksternal melalui URL maps; jangan membuat peta internal.
- Tambah buyer/request dari halaman ini. Input nama buyer dapat diketik atau dipilih dari daftar buyer yang pernah dipakai pada trip aktif. User juga mengisi jumlah dan catatan opsional.
- Tampilkan daftar request buyer dan checkbox untuk menandai sudah dibeli/belum. Update status harus langsung tercermin di tab Pembeli, daftar Produk, dan dashboard.

### D. Gambar katalog

Buat gambar katalog vertikal yang layak dibagikan, misalnya 1080 x 1920 PNG, dengan foto produk dan informasi utama.

Katalog harus menampilkan:

- Foto produk.
- Nama produk.
- Harga jual Rupiah yang jelas.
- Category/notes yang memang aman dibagikan bila ada.

Katalog **tidak boleh** menampilkan harga asli luar negeri, nilai kurs internal, margin, biaya internal, atau informasi buyer.

Simpan hasil gambar di database sebagai generated asset. Sediakan share melalui aplikasi eksternal dan simpan ke gallery menggunakan plugin yang sesuai, termasuk handling permission/error.

### E. Tab Pembeli

Tab ini menggantikan modul trend. Tidak perlu fitur trend produk, crawler, atau link referensi.

Tampilkan daftar buyer untuk trip aktif. Setiap buyer dapat di-expand/collapse. Ketika expanded, tampilkan semua barang yang dititipkan buyer tersebut, termasuk jumlah, catatan, dan status terbeli/belum.

Di tiap buyer, tampilkan indikator ringkas jumlah item/request yang sudah terbeli dan yang belum. Produk yang selesai dapat memakai check icon/warna sukses; yang belum dapat memakai outline/pending state yang tetap mudah dibaca.

### F. Tab Produk

Tampilkan semua produk pada trip aktif dengan:

- Search nama produk.
- Thumbnail, nama, harga jual Rupiah, harga asli untuk internal pemilik bila diinginkan, dan indikator progress checklist buyer seperti `1/3 terbeli`.
- Menu edit dan hapus.
- Tombol filter dengan badge jumlah filter aktif.

Filter produk harus bisa digabung dengan search, dan dibuat sebagai bottom sheet atau permukaan yang jelas. Sediakan:

- Kategori: semua atau kategori tertentu.
- Status checklist: semua, belum ada buyer, belum semua terbeli, sudah terbeli semua.
- Lokasi: semua, ada lokasi, tanpa lokasi.
- Reset filter.

Ketika filter aktif, tunjukkan jumlah produk hasil filter dan empty state khusus bila tidak ada hasil yang cocok. Reset filter saat trip aktif berubah agar tidak membawa filter kategori dari trip lama.

### G. Pengaturan dan manajemen trip

Halaman Pengaturan memiliki beberapa kartu/section yang jelas:

1. **Manajemen trip**
   - lihat/pilih trip aktif;
   - tambah trip dengan nama dan mata uang melalui currency picker bottom sheet;
   - edit nama trip dan pengaturan harga;
   - hapus trip aktif dengan konfirmasi.
   - trip terakhir tidak boleh dihapus.
   - menghapus trip juga menghapus seluruh produk, foto, request buyer, dan aset katalog terkait via cascade/transaksi.

2. **Pengaturan harga trip**
   - nama trip;
   - mata uang belanja;
   - kartu kurs dengan refresh manual;
   - markup default;
   - biaya tetap default per produk;
   - pembulatan harga ke atas, misalnya Rp100/Rp500/Rp1.000/Rp5.000.
   - saat menyimpan, tampilkan dialog yang menjelaskan bahwa harga produk akan dihitung ulang. Jika mata uang berubah, jelaskan bahwa kurs baru akan diambil sebelum kalkulasi ulang.

3. **Export trip ke Excel**
   - Export hanya untuk trip aktif.
   - Buat file `.xlsx` dan buka share sheet.
   - Tampilkan loading selama export.
   - Workbook minimal berisi tiga sheet:
     - `Ringkasan`: info trip, kurs, aturan harga, statistik belanja, estimasi modal, modal aktual, keuntungan.
     - `Produk`: nama, harga asli untuk pemilik, harga jual, berat, kategori, catatan, override harga, lokasi, dan ringkasan request buyer.
     - `Pembeli`: buyer, produk, jumlah, catatan, status terbeli, dan timestamp bila ada.

4. **Backup & restore**
   - Lihat detail pada bagian khusus di bawah.

## Backup dan restore penuh

Backup harus bersifat manual dan lokal, tanpa cloud. Format disarankan adalah file ZIP internal dengan ekstensi `.jastip`, misalnya `jastip_backup_YYYYMMDD_HHmm.jastip`.

Struktur internal yang disarankan:

```text
manifest.json
data.json
images/<product-id>.bin
thumbnails/<product-id>.bin
generated_assets/<asset-id>.png
```

`manifest.json` memuat format identifier, versi format backup, tanggal backup, serta jumlah trip/produk/request/aset. `data.json` memuat metadata dan relasi; binary foto/aset disimpan sebagai entry file ZIP, bukan base64 JSON agar ukuran lebih efisien.

Backup harus mencakup:

- seluruh trip dan pengaturannya;
- seluruh produk dan BLOB foto/thumbnail;
- seluruh generated catalog asset;
- seluruh buyer request dan status checklist;
- seluruh lokasi dan label lokasi;
- seluruh custom pricing/berat/kategori/catatan;
- cache kurs.

Alur backup:

1. User menekan Backup.
2. Tampilkan loading.
3. Bangun archive dan validasi bahwa bytes tidak kosong.
4. Buka native share sheet agar user dapat menyimpan ke file manager, Drive, WhatsApp, email, dan sebagainya.
5. Tampilkan notifikasi sukses/gagal.

Alur restore:

1. User menekan Restore dan memilih file `.jastip` atau `.zip` dari file picker native.
2. Validasi ZIP, manifest, versi format, daftar data, keberadaan binary files, dan bahwa backup memiliki tepat satu trip aktif.
3. Sebelum menulis database, tampilkan ringkasan isi backup: jumlah trip, produk, request buyer, dan aset katalog.
4. User wajib mengonfirmasi bahwa data lokal saat ini akan diganti seluruhnya.
5. Parse dan validasi seluruh data terlebih dahulu.
6. Hanya setelah validasi sukses, lakukan replace penuh dalam **satu transaksi database**: hapus data lama dengan urutan aman, insert trip, produk, request buyer, aset, dan cache kurs.
7. Bila parsing atau insert gagal, rollback wajib menjaga data lama agar tidak tersisa restore parsial.
8. Setelah sukses, seluruh UI harus memuat ulang berdasarkan trip aktif dari backup.

Untuk tahap ini, implementasikan mode **replace penuh saja**, tidak perlu merge. Beri warning yang tegas bahwa tindakan restore tidak dapat dibatalkan dari aplikasi.

## Integrasi platform yang diharapkan

- Kamera/galeri: `image_picker` atau solusi setara.
- Lokasi: `geolocator` atau solusi setara; permission handling wajib ada.
- Buka peta: `url_launcher` atau solusi setara ke aplikasi/browser eksternal.
- Share file/gambar: `share_plus` atau solusi setara.
- Simpan gambar ke galeri: plugin yang mendukung Android/iOS, dengan permission/error state.
- Excel: package yang dapat menghasilkan `.xlsx` secara lokal.
- Backup archive: ZIP/archive package dan native file picker.

## UX dan kualitas

- UI harus responsif untuk ukuran layar ponsel umum.
- Gunakan empty state, loading state, error state, dan disabled state yang jelas untuk seluruh proses async: kurs, export, backup, restore, kamera, galeri, lokasi, dan share.
- Hint text input harus lebih samar daripada primary text.
- Perhatikan aksesibilitas: label/tooltip untuk icon action, target tap cukup besar, kontras baik, dan teks tidak mudah terpotong.
- Jangan melakukan I/O, HTTP, atau query berat di `build()`.
- Gunakan stream database untuk data yang perlu otomatis berubah ketika produk, checklist, atau trip berubah.
- Hindari floating point untuk persisten harga/markup yang sensitif.
- Untuk request destructive: konfirmasi sebelum hapus produk, hapus trip, dan restore.
- Tanggal dan angka gunakan locale Indonesia bila relevan.

## Testing dan verifikasi

Sertakan test yang proporsional, setidaknya untuk:

- kalkulasi harga termasuk margin, biaya, pembulatan, dan override per produk;
- perubahan pengaturan trip yang menghitung ulang produk;
- perubahan mata uang yang mengambil dan menyimpan kurs baru ke state/data;
- hapus produk/trip beserta data turunannya;
- status checklist dan ringkasan belanja;
- filter produk kategori/checklist/lokasi;
- pencarian mata uang pada bottom sheet;
- export Excel menghasilkan file valid;
- backup menghasilkan ZIP dan restore mengganti database sekaligus mengembalikan foto, buyer request, dan data produk;
- double-back exit behavior.

Sebelum menyerahkan hasil, jalankan minimal:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Hasil yang saya harapkan dari Anda

1. Implementasi source code aplikasi lengkap, modular, dan dapat dijalankan.
2. UI modern, clean, dan nyaman menurut pertimbangan desain Anda sendiri.
3. Penjelasan singkat struktur folder dan keputusan teknis penting.
4. Daftar dependency dan alasan singkat penggunaannya.
5. Hasil analyzer/test yang dijalankan.
6. Jangan menambahkan auth, backend, cloud sync, fitur trend, atau biaya layanan yang tidak diminta.

Ambil keputusan desain yang masuk akal tanpa menunggu klarifikasi untuk detail visual. Namun jangan mengurangi aturan bisnis, integritas data, atau fitur yang disebutkan di atas.

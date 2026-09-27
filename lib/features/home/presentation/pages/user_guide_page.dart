import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atelier_widgets.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  static const _imagePath = 'docs/screenshots/panduan';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Panduan')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AtelierHeading(
                  eyebrow: 'JASTIP KATALOG',
                  title: 'Panduan Pengguna',
                  subtitle:
                      'Kelola trip, susun katalog, dan catat setiap titipan.',
                ),
                const SizedBox(height: 20),
                const _GuideNotice(
                  text: 'Screenshot menggunakan data contoh. Nama, produk, harga, dan tanggal kurs hanya ilustrasi. Data aplikasi disimpan lokal pada perangkat atau browser yang digunakan.',
                ),
                const SizedBox(height: 24),
                const _GuideSection(
                  title: 'Mulai cepat',
                  paragraphs: [
                    '1. Di Pengaturan, tekan Tambah trip. Isi nama trip dan pilih mata uang. Kurs ke rupiah akan diambil dan disimpan untuk trip.',
                    '2. Di tab Trip, tekan Tambah produk. Pilih foto, isi nama serta harga asli, lalu simpan.',
                    '3. Buka produk dan tambahkan pembeli melalui bagian Checklist pembeli. Isi nama, jumlah, dan catatan jika perlu.',
                    '4. Centang checklist saat barang sudah dibeli. Pantau ringkasan di Trip atau rincian per orang di Pembeli.',
                    '5. Buat Backup secara berkala untuk menyimpan salinan data yang dapat dipulihkan.',
                  ],
                ),
                _GuideSection(
                  title: 'Empat tab utama',
                  paragraphs: const [
                    'Trip menampilkan trip aktif, kurs, ringkasan belanja, serta akses untuk menambah produk dan mengelola checklist.',
                    'Pembeli mengelompokkan titipan menurut nama, jumlah, nilai, dan status belanja.',
                    'Produk menyediakan pencarian, kategori, filter, serta akses ke detail setiap produk.',
                    'Pengaturan mengelola trip, kurs, aturan harga, ekspor, backup, restore, dan changelog.',
                    'Di layar kecil, navigasi ada di bagian bawah. Di layar lebar, navigasi ada di sisi kiri.',
                  ],
                  screenshots: const [
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-trip.png',
                      caption: 'Trip aktif dan ringkasan belanja.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-buyers.png',
                      caption: 'Rekap titipan per pembeli.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-products.png',
                      caption: 'Koleksi produk per kategori.',
                    ),
                  ],
                ),
                _GuideSection(
                  title: 'Membuat trip dan mengatur kurs',
                  paragraphs: const [
                    'Di Pengaturan, tekan Tambah trip, isi nama, dan pilih mata uang. Setiap trip menyimpan produk, pembeli, kurs, dan aturan harga sendiri.',
                    'Kurs trip yang sudah tersedia tidak diperbarui otomatis. Untuk mengambil kurs terbaru, buka Pengaturan, tekan ikon Perbarui kurs, lalu setujui konfirmasi. Harga jual seluruh produk pada trip itu akan dihitung ulang.',
                    'Mengganti mata uang lalu menyimpan pengaturan juga mengambil kurs untuk mata uang baru dan menghitung ulang harga. Periksa harga sebelum membagikan ulang gambar katalog yang sudah dibuat.',
                    'Tanggal yang terlihat adalah tanggal data kurs dari Frankfurter. Kurs referensi dapat berbeda dari kurs bank, kartu, money changer, atau transaksi sebenarnya. Saat offline, aplikasi dapat menggunakan kurs cache yang tersimpan.',
                  ],
                  screenshots: [
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-settings.png',
                      caption: 'Akses untuk mengelola trip dan data.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-create-trip.png',
                      caption: 'Nama trip dan mata uang belanja.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-rate-settings.png',
                      caption: 'Kurs, markup, biaya tetap, dan pembulatan.',
                    ),
                  ],
                ),
                const _GuideSection(
                  title: 'Harga dan ringkasan',
                  paragraphs: [
                    'Markup, biaya tetap, dan pembulatan di Pengaturan berlaku untuk produk trip yang tidak memakai harga khusus. Menyimpan perubahan pengaturan akan menghitung ulang harga jual.',
                    'Harga khusus produk dapat menetapkan margin dan biaya tetap tersendiri.',
                    'Modal estimasi, Belanja aktual, dan Keuntungan merupakan ringkasan perhitungan dari harga produk, kurs, jumlah titipan, dan status checklist. Belanja aktual bukan pencatatan nilai struk atau pembayaran riil.',
                  ],
                ),
                _GuideSection(
                  title: 'Menambah dan mengelola produk',
                  paragraphs: const [
                    'Di tab Trip, tekan Tambah produk. Pilih foto dari kamera atau galeri, isi nama dan harga asli dalam mata uang trip. Masukkan angka tanpa pemisah ribuan; pratinjau harga katalog akan muncul.',
                    'Harga khusus produk bersifat opsional. Bagian detail dapat memuat kategori, berat, catatan, nama lokasi, dan titik lokasi. Tekan Simpan produk setelah selesai.',
                    'Di tab Produk, cari dengan nama atau gunakan filter kategori, status checklist, dan lokasi. Tekan produk untuk membuka detail. Menu Aksi produk menyediakan Edit, Duplikat, dan Hapus. Menghapus produk juga menghapus checklist serta gambar katalog terkait setelah konfirmasi.',
                  ],
                  screenshots: const [
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-form.png',
                      caption: 'Foto, nama, dan harga produk.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-form-details.png',
                      caption: 'Detail opsional dan lokasi produk.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-filter.png',
                      caption: 'Filter kategori, checklist, dan lokasi.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-catalog.png',
                      caption:
                          'Pratinjau katalog siap disimpan atau dibagikan.',
                    ),
                  ],
                ),
                _GuideSection(
                  title: 'Mencatat pembeli dan belanja',
                  paragraphs: const [
                    'Pada detail produk, tekan Tambah di Checklist pembeli. Isi nama, jumlah, dan catatan. Nama yang pernah digunakan dalam trip dapat dipilih kembali.',
                    'Gunakan kotak centang untuk menandai titipan yang sudah dibeli. Ikon edit mengubah nama, jumlah, dan catatan; ikon hapus menghapus permintaan setelah konfirmasi.',
                    'Tab Pembeli menggabungkan titipan berdasarkan nama. Untuk mengubah atau menghapus titipan, buka kembali detail produk yang bersangkutan.',
                  ],
                  screenshots: const [
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-checklist.png',
                      caption: 'Checklist pembeli di detail produk.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-add-buyer.png',
                      caption: 'Form untuk menambah titipan.',
                    ),
                    _GuideScreenshot(
                      asset: '$_imagePath/phone-edit-buyer.png',
                      caption: 'Form edit dengan data yang sudah terisi.',
                    ),
                  ],
                ),
                const _GuideSection(
                  title: 'Ekspor dan impor checklist Excel',
                  paragraphs: [
                    'Jika trip sudah memiliki titipan, gunakan Ekspor Excel di ringkasan Trip untuk membuat daftar belanja. Ubah status di workbook lalu pilih Impor checklist.',
                    'Impor checklist berlaku untuk seluruh permintaan pada produk yang sama. Untuk menandai hanya sebagian pembeli sudah dibelikan, ubah status tiap orang melalui detail produk.',
                  ],
                ),
                const _GuideSection(
                  title: 'Ekspor trip, backup, dan restore',
                  paragraphs: [
                    'Export trip di Pengaturan membuat file Excel (.xlsx) dengan sheet Ringkasan, Produk, dan Pembeli. File ini untuk laporan dan tidak dapat dipakai oleh Restore.',
                    'Backup membuat file .jastip yang mencakup trip, produk, foto, checklist pembeli, aset katalog, dan cache kurs. Simpan file tersebut di lokasi aman.',
                    'Untuk memulihkan, pilih Restore, pilih file backup, tinjau ringkasannya, dan konfirmasi. Restore mengganti data lokal saat ini dengan isi backup. Buat backup baru terlebih dahulu jika data saat ini masih diperlukan.',
                    'Data disimpan lokal dan tidak tersinkron otomatis ke perangkat atau browser lain. Gunakan file backup saat pindah perangkat atau browser.',
                  ],
                ),
                const _GuideSection(
                  title: 'Jika mengalami kendala',
                  paragraphs: [
                    'Kurs belum tersedia: periksa koneksi lalu coba Perbarui kurs di Pengaturan. Produk baru membutuhkan kurs yang tersedia.',
                    'Harga berubah: periksa apakah kurs, mata uang, markup, biaya tetap, atau pembulatan telah diubah. Perubahan itu dapat menghitung ulang harga produk.',
                    'Produk atau pembeli tidak terlihat: periksa trip aktif, kata pencarian, dan filter produk.',
                    'Data tidak ada setelah berpindah browser atau perangkat: cari file backup .jastip yang dibuat sebelumnya dan pulihkan dari Pengaturan.',
                  ],
                ),
                const SizedBox(height: 24),
                const _GuideNotice(
                  text: 'Buka ikon informasi di Pengaturan untuk membaca changelog aplikasi.',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.paragraphs,
    this.screenshots = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<_GuideScreenshot> screenshots;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...paragraphs.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  paragraph,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            for (final screenshot in screenshots) ...[
              const SizedBox(height: 10),
              screenshot,
            ],
          ],
        ),
      ),
    ),
  );
}

class _GuideScreenshot extends StatelessWidget {
  const _GuideScreenshot({required this.asset, required this.caption});

  final String asset;
  final String caption;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _GuideNotice extends StatelessWidget {
  const _GuideNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.sage,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

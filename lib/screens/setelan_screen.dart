import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'trash_screen.dart';
import '../models/vocabulary.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_utils.dart';

class SetelanScreen extends StatefulWidget {
  const SetelanScreen({Key? key}) : super(key: key);

  @override
  State<SetelanScreen> createState() => _SetelanScreenState();
}

class _SetelanScreenState extends State<SetelanScreen> {
  bool _isDarkMode = false;
  double _easeFactor = 2.5;

  // Import State
  bool _isImporting = false;
  int _totalImport = 0;
  int _currentImport = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
      backgroundColor: colors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: const Color(0xFFf0f4f8), // Match top nav background
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(99),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.menu, color: colors.outline),
                    ),
                  ),
                ),
                Text(
                  'ZEN SCHOLAR',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: colors.primary,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(99),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.account_circle, color: colors.outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Text(
              'Setelan',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sesuaikan pengalaman belajar manuskrip digital Anda.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            // Tampilan Section
            _buildSectionHeader(Icons.palette, 'Tampilan', colors),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildSettingsRow(
                    context: context,
                    title: 'Mode Gelap',
                    subtitle: 'Aktifkan untuk kenyamanan mata di malam hari',
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: colors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isDarkMode = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildSettingsRow(
                    context: context,
                    title: 'Bahasa UI',
                    subtitle: 'Gunakan Bahasa Indonesia atau English',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Indonesia',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 20, color: colors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // SRS Section (Asymmetric Matrix)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 2, child: _buildSrsInfo(colors)),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: _buildSrsControls(colors)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSrsInfo(colors),
                          const SizedBox(height: 16),
                          _buildSrsControls(colors),
                        ],
                      );
              },
            ),
            const SizedBox(height: 40),

            // Data & Privasi Section
            _buildSectionHeader(Icons.storage, 'Data & Privasi', colors),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final dataCards = [
                  // Ekspor
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: colors.secondary, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ekspor Koleksi',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Simpan cadangan data kartu Anda ke perangkat lokal.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.secondary,
                                foregroundColor: colors.onSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('JSON', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.surfaceContainerHigh,
                                foregroundColor: colors.onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isWide) const SizedBox(height: 16),
                  
                  // Impor
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: colors.primary, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impor Data',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan list kata baru dari file eksternal .kamus.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isImporting ? null : _startImport,
                            icon: const Icon(Icons.upload_file, size: 20),
                            label: const Text('Pilih File', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];

                return Column(
                  children: [
                    isWide
                        ? Row(
                            children: [
                              Expanded(child: dataCards[0]),
                              const SizedBox(width: 16),
                              Expanded(child: dataCards[1]),
                            ],
                          )
                        : Column(children: dataCards),
                    const SizedBox(height: 16),
                    
                    // Tempat Sampah Block
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TrashScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(left: BorderSide(color: Color(0xFF94A3B8), width: 4)), // border-slate-400
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9), // bg-slate-100
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete, color: Color(0xFF475569), size: 20), // text-slate-600
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tempat Sampah',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lihat dan pulihkan item yang baru saja dihapus.',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reset Block
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.error.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Semua Data',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tindakan ini permanen dan tidak dapat dibatalkan.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: colors.onError,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // Tentang Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(Icons.book, size: 40, color: colors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'myKamusPersonal',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi 1.0.0 (Zen Scholar Edition)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLinkRow('Lisensi', colors),
                  _buildLinkRow('Syarat & Ketentuan', colors),
                  const SizedBox(height: 40),
                  Text(
                    'HANDCRAFTED WITH FOCUS BY THE ZEN TEAM',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: colors.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    if (_isImporting) _buildImportOverlay(colors),
  ],
);
}

  Widget _buildSectionHeader(IconData icon, String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSrsInfo(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.analytics, 'SRS', colors),
        Text(
          'Atur algoritma Spaced Repetition System untuk optimasi hafalan Kanji Anda.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.6,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSrsControls(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ease Factor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EASE FACTOR',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: colors.onPrimaryContainer.withValues(alpha: 0.9),
                ),
              ),
              Text(
                _easeFactor.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _easeFactor,
            min: 1.3,
            max: 3.0,
            activeColor: colors.secondary,
            inactiveColor: colors.primary,
            onChanged: (val) {
              setState(() {
                _easeFactor = val;
              });
            },
          ),
          const SizedBox(height: 24),

          // Interval Maks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTERVAL MAKS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: colors.onPrimaryContainer.withValues(alpha: 0.9),
                ),
              ),
              Text(
                '30 hari',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildIntervalBtn('7 HARI', false, colors)),
              const SizedBox(width: 8),
              Expanded(child: _buildIntervalBtn('30 HARI', true, colors)),
              const SizedBox(width: 8),
              Expanded(child: _buildIntervalBtn('90 HARI', false, colors)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalBtn(String text, bool isSelected, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? colors.onPrimaryContainer : colors.primary,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? colors.primaryContainer : colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildLinkRow(String title, ColorScheme colors) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Icon(Icons.open_in_new, size: 20, color: colors.outline.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Future<void> _startImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
      );

      if (result != null) {
        final filePath = result.files.single.path;
        if (filePath == null) return;
        
        final file = File(filePath);
        final extension = result.files.single.extension?.toLowerCase();
        
        if (extension != 'json') {
          SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Alasan: Format file tidak didukung (.$extension). Gunakan file .json.');
          return;
        }

        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);

        setState(() {
          _isImporting = true;
          _totalImport = jsonList.length;
          _currentImport = 0;
        });

        int addedCount = 0;

        for (var item in jsonList) {
          // Delay sedikit untuk memberi waktu UI render & progress bar jalan perlahan
          await Future.delayed(const Duration(milliseconds: 30));

          final String kanji = item['kanji'] ?? '';
          final String reading = item['reading'] ?? '';
          final String romaji = item['romaji'] ?? '';
          final String meaningId = item['meaning_id'] ?? item['meaningId'] ?? '';
          final String meaningEn = item['meaning_en'] ?? item['meaningEn'] ?? '';
          final String category = item['category'] ?? '';
          final String subCategory = item['sub_category'] ?? item['subCategory'] ?? '';

          final vocab = Vocabulary(
            id: '',
            kanji: kanji,
            reading: reading,
            romaji: romaji,
            meaningId: meaningId,
            meaningEn: meaningEn,
            category: category,
            subCategory: subCategory,
            srsLevel: 0,
            nextReview: DateTime.now(),
            createdAt: DateTime.now(),
          );

          await _firestoreService.addVocabulary(vocab);
          
          addedCount++;
          setState(() {
            _currentImport = addedCount;
          });
        }

        setState(() {
          _isImporting = false;
        });

        SnackbarUtils.showCustomAlert(context, isSuccess: true, message: '$addedCount kata baru telah ditambahkan ke Pustaka Anda.');
      }
    } catch (e) {
      setState(() => _isImporting = false);
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Alasan: Terjadi kesalahan (${e.toString()})');
    }
  }

  Widget _buildImportOverlay(ColorScheme colors) {
    double progress = _totalImport == 0 ? 0 : (_currentImport / _totalImport);
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          color: colors.onBackground.withOpacity(0.15), // Backdrop
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 48,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD2E4FF), // light blue background untuk icon
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded, color: Color(0xFF32445B), size: 32), // dark blue icon
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Mengimpor Data...',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar, kami sedang menyusun materi belajarmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.6,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: colors.primary,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colors.surfaceContainer,
                      color: colors.primary,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: colors.secondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '$_currentImport/$_totalImport kata terimpor',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'JANGAN TUTUP APLIKASI SAAT PROSES BERLANGSUNG',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

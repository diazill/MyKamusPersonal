import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../models/sentence.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_utils.dart';

class TambahScreen extends StatefulWidget {
  const TambahScreen({Key? key}) : super(key: key);

  @override
  State<TambahScreen> createState() => TambahScreenState();
}

class TambahScreenState extends State<TambahScreen> {
  bool _isWordTab = true; // true untuk Kata, false untuk Kalimat
  
  String _selectedCategory = 'Kata Kerja';
  String _selectedSubCategory = 'Dinamis';
  bool _isLoading = false;

  // Form Kata
  final _kanjiController = TextEditingController();
  final _furiganaController = TextEditingController();
  final _romajiController = TextEditingController();
  final _artiIdController = TextEditingController();
  final _artiEnController = TextEditingController();
  final _catatanController = TextEditingController();

  // Form Kalimat
  final _sentJpController = TextEditingController();
  final _sentReadingController = TextEditingController();
  final _sentRomajiController = TextEditingController();
  final _sentMeaningController = TextEditingController();
  final _sentNotesController = TextEditingController();
  final _sentTagsController = TextEditingController(); 
  final _sentVocabIdsController = TextEditingController();

  final _firestoreService = FirestoreService();

  void resetInputs() {
    _kanjiController.clear();
    _furiganaController.clear();
    _romajiController.clear();
    _artiIdController.clear();
    _artiEnController.clear();
    _catatanController.clear();

    _sentJpController.clear();
    _sentReadingController.clear();
    _sentRomajiController.clear();
    _sentMeaningController.clear();
    _sentNotesController.clear();
    _sentTagsController.clear();
    _sentVocabIdsController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _kanjiController.dispose();
    _furiganaController.dispose();
    _romajiController.dispose();
    _artiIdController.dispose();
    _artiEnController.dispose();
    _catatanController.dispose();

    _sentJpController.dispose();
    _sentReadingController.dispose();
    _sentRomajiController.dispose();
    _sentMeaningController.dispose();
    _sentNotesController.dispose();
    _sentTagsController.dispose();
    _sentVocabIdsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: const Color(0xFFf0f4f8), 
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Handle back navigation
                        },
                        borderRadius: BorderRadius.circular(99),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.close, color: colors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isWordTab ? 'Tambah Kata Baru' : 'Tambah Kalimat Baru',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(colors),
                    const SizedBox(height: 24),
                    _buildSegmentControl(colors),
                    const SizedBox(height: 32),
                    
                    if (_isWordTab) _buildKataForm(colors) else _buildKalimatForm(colors),
                    
                    const SizedBox(height: 48),
                    _buildActionButtons(colors),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      children: [
        Text(
          'KOLEKSI BARU',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isWordTab ? 'Perluas Kosakata Anda' : 'Tambah Kalimat Baru\n(Detailed)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: _isWordTab ? 36 : 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: colors.primary,
          ),
        ),
        if (!_isWordTab) ...[
          const SizedBox(height: 12),
          Text(
            'Isi detail di bawah untuk menambahkan entri baru ke dalam jurnal belajar digital Anda. Gunakan Kanji untuk kedalaman visual.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildSegmentControl(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWordTab = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isWordTab ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _isWordTab ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ] : null,
                ),
                child: Text(
                  'Kata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: _isWordTab ? FontWeight.w600 : FontWeight.w500,
                    color: _isWordTab ? colors.onPrimary : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWordTab = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isWordTab ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !_isWordTab ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ] : null,
                ),
                child: Text(
                  'Kalimat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: !_isWordTab ? FontWeight.w600 : FontWeight.w500,
                    color: !_isWordTab ? colors.onPrimary : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKataForm(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kategori Utama',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCategoryCard('Kata Kerja', Icons.bolt, colors)),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard('Kata Sifat', Icons.palette, colors)),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard('Kata Benda', Icons.inventory_2, colors)),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _selectedCategory == 'Kata Benda'
              ? const SizedBox.shrink()
              : _buildSubCategorySection(colors),
        ),
        const SizedBox(height: 40),
        
        _buildCenteredLabel('Kanji (Opsional)'),
        _buildCenteredInputField(
          context: context,
          hint: '例: 食べる',
          fontFamily: 'Noto Sans JP',
          fontSize: 24,
          textColor: colors.primary,
          isBold: false,
          controller: _kanjiController,
        ),
        const SizedBox(height: 32),
        
        _buildCenteredLabel('Furigana / Reading', isRequired: true),
        _buildCenteredInputField(
          context: context,
          hint: 'たべる',
          fontFamily: 'Noto Sans JP',
          fontSize: 14,
          controller: _furiganaController,
        ),
        const SizedBox(height: 32),
        
        _buildCenteredLabel('Romaji', isRequired: true),
        _buildCenteredInputField(
          context: context,
          hint: 'taberu',
          fontFamily: 'Inter',
          fontSize: 14,
          isItalic: true,
          controller: _romajiController,
        ),
        const SizedBox(height: 32),
        
        _buildCenteredLabel('Arti Indonesia', isRequired: true),
        _buildCenteredInputField(
          context: context,
          hint: 'Makan',
          fontFamily: 'Inter',
          fontSize: 14,
          isBold: true,
          controller: _artiIdController,
        ),
        const SizedBox(height: 32),
        
        _buildCenteredLabel('Arti Inggris'),
        _buildCenteredInputField(
          context: context,
          hint: 'To eat',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _artiEnController,
        ),
        const SizedBox(height: 32),
        
        _buildCenteredLabel('Catatan (Opsional)'),
        _buildCenteredInputField(
          context: context,
          hint: 'Contoh: Kata baku, informal, dll.',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _catatanController,
        ),
      ],
    );
  }

  Widget _buildKalimatForm(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAlignedLabel('TEKS JEPANG (KANJI/KANA)', isRequired: true),
        _buildTextAreaField(
          context: context,
          hint: '例: 毎日りんごを食べます。',
          fontFamily: 'Noto Sans JP',
          fontSize: 14,
          controller: _sentJpController,
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('CARA BACA (FURIGANA/HIRAGANA)', isRequired: true),
        _buildTextAreaField(
          context: context,
          hint: 'まいにちりんごをたべます。',
          fontFamily: 'Noto Sans JP',
          fontSize: 14,
          controller: _sentReadingController,
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('ROMAJI', isRequired: true),
        _buildCenteredInputField(
          context: context,
          hint: 'mainichi ringo o tabemasu',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _sentRomajiController,
          alignLeft: true,
          isRounded: true,
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('ARTI INDONESIA', isRequired: true),
        _buildTextAreaField(
          context: context,
          hint: 'Saya makan apel setiap hari.',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _sentMeaningController,
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('CATATAN TATA BAHASA'),
        _buildTextAreaField(
          context: context,
          hint: 'Tambahkan catatan tata bahasa di sini...',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _sentNotesController,
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('TAGS'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTagChip('Formal'),
              _buildTagChip('Anime'),
              // You can build logic to add more tags later
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildAlignedLabel('HUBUNGKAN KATA'),
        _buildCenteredInputField(
          context: context,
          hint: 'Pilih Kata...',
          fontFamily: 'Inter',
          fontSize: 14,
          controller: _sentVocabIdsController,
          alignLeft: true,
          isRounded: true,
        ),
      ],
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () async {
            if (_isWordTab) {
              await _saveWord();
            } else {
              await _saveSentence();
            }
          },
          icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
          label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Entri'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            elevation: 10,
            shadowColor: colors.primary.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // TODO: Batal implementation
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            'Batal',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveWord() async {
    if (_furiganaController.text.isEmpty || _romajiController.text.isEmpty || _artiIdController.text.isEmpty) {
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Harap isi field yang wajib!');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final vocab = Vocabulary(
        id: '',
        kanji: _kanjiController.text,
        reading: _furiganaController.text,
        romaji: _romajiController.text,
        meaningId: _artiIdController.text,
        meaningEn: _artiEnController.text,
        category: _selectedCategory,
        subCategory: _selectedCategory == 'Kata Kerja' ? _selectedSubCategory : '',
        catatan: _catatanController.text,
        srsLevel: 0,
        nextReview: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final isDuplicate = await _firestoreService.isDuplicateMeaningId(vocab.meaningId);
      if (isDuplicate && mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Kata sudah ada di koleksi');
        setState(() => _isLoading = false);
        return;
      }

      await _firestoreService.addVocabulary(vocab);
      
      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Entri kata berhasil disimpan');
        resetInputs();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Gagal: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSentence() async {
    if (_sentJpController.text.isEmpty || _sentReadingController.text.isEmpty || _sentRomajiController.text.isEmpty || _sentMeaningController.text.isEmpty) {
      SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Harap isi field yang wajib!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sentence = Sentence(
        id: '',
        jpText: _sentJpController.text,
        reading: _sentReadingController.text,
        romaji: _sentRomajiController.text,
        meaning: _sentMeaningController.text,
        notes: _sentNotesController.text,
        tags: [], // Add actual tags later
        vocabIds: [], // Add actual linked vocab logic later
        srsLevel: 0,
        nextReview: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addSentence(sentence);

      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Entri kalimat berhasil disimpan');
        resetInputs();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Gagal: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI Helpers ---

  Widget _buildCategoryCard(String title, IconData icon, ColorScheme colors) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategory != title) {
            _selectedCategory = title;
            if (title == 'Kata Kerja') {
              _selectedSubCategory = 'Dinamis';
            } else if (title == 'Kata Sifat') {
              _selectedSubCategory = 'Kata Sifat I (い)';
            } else {
              _selectedSubCategory = '';
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer.withValues(alpha: 0.15) : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategorySection(ColorScheme colors) {
    bool isKerja = _selectedCategory == 'Kata Kerja';
    return Column(
      key: ValueKey(_selectedCategory),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isKerja ? 'Sub-Kategori (Kata Kerja)' : 'Sub-Kategori (Kata Sifat)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: isKerja
              ? [
                  Expanded(child: _buildSubCategoryBtn('Dinamis', colors)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSubCategoryBtn('Menuju', colors)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSubCategoryBtn('Statis', colors)),
                ]
              : [
                  Expanded(child: _buildSubCategoryBtn('Kata Sifat I (い)', colors)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSubCategoryBtn('Kata Sifat NA (な)', colors)),
                ],
        ),
      ],
    );
  }

  Widget _buildSubCategoryBtn(String title, ColorScheme colors) {
    final isSelected = _selectedSubCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubCategory = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.secondaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? colors.secondaryContainer : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredLabel(String text, {bool isRequired = false}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: text.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 2.0,
          ),
          children: [
            if (isRequired) TextSpan(text: ' *', style: TextStyle(color: colors.tertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignedLabel(String text, {bool isRequired = false}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          text: text.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.5,
          ),
          children: [
            if (isRequired) TextSpan(text: ' *', style: TextStyle(color: colors.tertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredInputField({
    required BuildContext context,
    required String hint,
    required String fontFamily,
    required double fontSize,
    Color? textColor,
    bool isBold = false,
    bool isItalic = false,
    TextEditingController? controller,
    bool alignLeft = false,
    bool isRounded = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor ?? colors.onSurface,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
          ),
          filled: true,
          fillColor: colors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isRounded ? 999 : 16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isRounded ? 999 : 16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isRounded ? 999 : 16),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTextAreaField({
    required BuildContext context,
    required String hint,
    required String fontFamily,
    required double fontSize,
    TextEditingController? controller,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: colors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: colors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

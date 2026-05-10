import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/vocabulary.dart';
import '../utils/snackbar_utils.dart';
import 'detail_screen.dart';

class PustakaScreen extends StatefulWidget {
  const PustakaScreen({Key? key}) : super(key: key);

  @override
  State<PustakaScreen> createState() => PustakaScreenState();
}

class PustakaScreenState extends State<PustakaScreen> {
  final _firestoreService = FirestoreService();
  String _selectedCategory = 'Semua';
  String _selectedSubCategory = 'Semua';
  String _sortBy = 'Terbaru';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  void resetSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  final List<String> _categories = [
    'Semua',
    'Kata Kerja',
    'Kata Sifat',
    'Kata Benda',
    'Frasa',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true, // swallows auto-focus coming from navigator pops
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F9FC), // background surface
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              color: const Color(0xFFF8F9FA), // TopAppBar Shell bg
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'ZEN SCHOLAR',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0, // tracking-widest
                                color: Color(0xFF32445b), // text-[#32445b]
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort, color: Color(0xFF32445b)),
                          tooltip: 'Urutkan berdasarkan',
                          onSelected: (String result) {
                            setState(() {
                              _sortBy = result;
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Terbaru',
                                  child: Text('Terbaru'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'A-Z (Arti)',
                                  child: Text('A-Z (Arti)'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Z-A (Arti)',
                                  child: Text('Z-A (Arti)'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'A-Z (Romaji)',
                                  child: Text('A-Z (Romaji)'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                children: [
              // Search & Discovery Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Container(
                  height: 56, // h-14
                  decoration: BoxDecoration(
                    color: Colors.white, // bg-surface-container-lowest
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(
                        0xFFC5C5D4,
                      ).withOpacity(0.2), // ring-outline-variant/20
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 12),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFF32445b), // text-primary
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: false, // Don't auto-read
                          decoration: InputDecoration(
                            hintText: 'Cari kanji, arti, atau romaji...',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              color: const Color(
                                0xFFC5C5D4,
                              ), // placeholder text-outline-variant
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Color(0xFFC5C5D4),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF191C1E), // text-on-surface
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Primary Category Tabs
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _categories[index] == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = _categories[index];
                            _selectedSubCategory = 'Semua';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF32445b)
                                : const Color(
                                    0xFFE6E8EB,
                                  ), // bg-primary / bg-surface-container-high
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(
                                        0xFF454652,
                                      ), // text-on-surface-variant
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Sub-Navigation Layer
              if (_selectedCategory == 'Kata Kerja' ||
                  _selectedCategory == 'Kata Sifat')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _selectedCategory == 'Kata Kerja'
                              ? [
                                  _buildSubNavTab(
                                    'Semua',
                                    'Semua',
                                    _selectedSubCategory == 'Semua',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildSubNavTab(
                                    'Dinamis',
                                    'Kata Kerja Bergerak Dinamis',
                                    _selectedSubCategory ==
                                        'Kata Kerja Bergerak Dinamis',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildSubNavTab(
                                    'Menuju',
                                    'Kata Kerja Menuju',
                                    _selectedSubCategory == 'Kata Kerja Menuju',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildSubNavTab(
                                    'Statis',
                                    'Kata Kerja Bergerak Statis',
                                    _selectedSubCategory ==
                                        'Kata Kerja Bergerak Statis',
                                  ),
                                ]
                              : [
                                  _buildSubNavTab(
                                    'Semua',
                                    'Semua',
                                    _selectedSubCategory == 'Semua',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildSubNavTab(
                                    'Kata Sifat I (い)',
                                    'Kata Sifat I',
                                    _selectedSubCategory == 'Kata Sifat I',
                                  ),
                                  const SizedBox(width: 24),
                                  _buildSubNavTab(
                                    'Kata Sifat NA (な)',
                                    'Kata Sifat Na',
                                    _selectedSubCategory == 'Kata Sifat Na',
                                  ),
                                ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Color(0xFFC5C5D4),
                        height: 1,
                        thickness: 0.5,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Interaction Hint
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '← swipe untuk hapus →',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0, // tracking-[0.2em]
                    color: Color(0xFFC5C5D4), // text-outline-variant
                  ),
                ),
              ),

              // Unified Vocabulary Cards List
              Expanded(
                child: StreamBuilder<List<Vocabulary>>(
                  stream: _firestoreService.getVocabulariesStream(),
                  builder: (streamContext, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Koleksi pustaka kosong.',
                          style: TextStyle(color: Color(0xFF757684)),
                        ),
                      );
                    }

                    // Apply filter logic
                    List<Vocabulary> vocabularies = snapshot.data!;

                    if (_selectedCategory != 'Semua') {
                      vocabularies = vocabularies.where((v) {
                        final catLower = v.category.toLowerCase();
                        if (_selectedCategory == 'Kata Kerja') {
                          return catLower.contains('kerja') ||
                              catLower.contains('verba');
                        } else if (_selectedCategory == 'Kata Sifat') {
                          return catLower.contains('sifat');
                        } else if (_selectedCategory == 'Kata Benda') {
                          return catLower.contains('benda');
                        } else {
                          return catLower.contains(
                            _selectedCategory.toLowerCase(),
                          );
                        }
                      }).toList();
                    }

                    if ((_selectedCategory == 'Kata Kerja' ||
                            _selectedCategory == 'Kata Sifat') &&
                        _selectedSubCategory != 'Semua') {
                      vocabularies = vocabularies
                          .where((v) => v.subCategory == _selectedSubCategory)
                          .toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      vocabularies = vocabularies.where((v) {
                        return v.kanji.toLowerCase().contains(_searchQuery) ||
                            v.reading.toLowerCase().contains(_searchQuery) ||
                            v.romaji.toLowerCase().contains(_searchQuery) ||
                            v.meaningId.toLowerCase().contains(_searchQuery) ||
                            v.meaningEn.toLowerCase().contains(_searchQuery) ||
                            v.catatan.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    if (_sortBy == 'Terbaru') {
                      vocabularies.sort(
                        (a, b) => b.createdAt.compareTo(a.createdAt),
                      );
                    } else if (_sortBy == 'A-Z (Arti)') {
                      vocabularies.sort(
                        (a, b) => a.meaningId.compareTo(b.meaningId),
                      );
                    } else if (_sortBy == 'Z-A (Arti)') {
                      vocabularies.sort(
                        (a, b) => b.meaningId.compareTo(a.meaningId),
                      );
                    } else if (_sortBy == 'A-Z (Romaji)') {
                      vocabularies.sort((a, b) => a.romaji.compareTo(b.romaji));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 800;

                        if (isDesktop) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350,
                              mainAxisExtent: 320, // Approximate height of the card
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: vocabularies.length,
                            itemBuilder: (itemContext, index) {
                              final vocab = vocabularies[index];
                              return Dismissible(
                                key: Key(vocab.id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBA1A1A), // text-error
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  // Same dismiss logic...
                                  return await _showDeleteConfirmDialog(itemContext, vocab);
                                },
                                child: _buildVocabularyCard(vocab),
                              );
                            },
                          );
                        }

                        // Mobile View
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          itemCount: vocabularies.length,
                          itemBuilder: (itemContext, index) {
                            final vocab = vocabularies[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Dismissible(
                                key: Key(vocab.id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBA1A1A), // text-error
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmDialog(itemContext, vocab);
                                },
                                child: _buildVocabularyCard(vocab),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: const Color(0xFF32445b), // primary
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
          // Keeps it floating reasonably high to avoid bottom nav overlaps usually found in MainScreen
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, Vocabulary vocab) async {
    final colors = Theme.of(context).colorScheme;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: colors.onErrorContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hapus Kata?',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apakah Anda yakin ingin menghapus kata ini dari pustaka Anda? Kata akan dipindah ke Tempat Sampah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurface,
                            side: BorderSide(color: colors.outlineVariant),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Batal', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: colors.onError,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Hapus', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestoreService.softDeleteVocabulary(vocab.id);
        if (mounted) {
          SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Kata dipindah ke Tempat Sampah');
        }
        return true;
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showCustomAlert(context, isSuccess: false, message: 'Gagal menghapus: $e');
        }
        return false;
      }
    }
    return false;
  }

  Widget _buildSubNavTab(String title, String filterValue, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSubCategory = filterValue);
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? const Color(0xFF32445b)
                  : Colors.transparent, // primary
              width: 2,
            ),
          ),
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 2.0, // tracking-widest
            color: isActive
                ? const Color(0xFF32445b)
                : const Color(0xFF757684), // text-primary or text-outline
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(Vocabulary vocab) {
    // Generate badge colors similar to HTML
    Color badgeColor = const Color(
      0xFF0A6F66,
    ); // text-on-secondary-container default
    Color badgeBg = const Color(0xFF9CEFE4); // bg-secondary-container default

    String displayCategory = vocab.category.toUpperCase();
    final catLower = vocab.category.toLowerCase();
    if (catLower.contains('kerja') || catLower.contains('verba')) {
      badgeColor = const Color(0xFF138973); // Dark teal
      badgeBg = const Color(0xFF90F4D0); // Light mint
      displayCategory = 'KATA KERJA';
    } else if (catLower.contains('sifat')) {
      badgeColor = const Color(0xFFA14930); // Dark red/brown
      badgeBg = const Color(0xFFF7D6C8); // Peach
      displayCategory = 'KATA SIFAT';
    } else if (catLower.contains('benda')) {
      badgeColor = const Color(0xFF4C658D); // Dark slate blue
      badgeBg = const Color(0xFFD3EEFC); // Light blue
      displayCategory = 'KATA BENDA';
    }

    final displayReading = vocab.reading.isNotEmpty ? vocab.reading : '?';
    final displayMain = vocab.kanji.isNotEmpty ? vocab.kanji : vocab.reading;
    final displayRomaji = vocab.romaji.isNotEmpty ? vocab.romaji : '?';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(vocab: vocab)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // bg-surface-container-lowest
          borderRadius: BorderRadius.circular(16), // rounded-xl
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24), // p-6
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Area Kana dan Kanji (tengah)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        displayReading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500, // font-medium
                          color: Color(0xFF757684), // text-outline
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayMain,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Noto Sans JP',
                          fontSize: 48, // text-5xl
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0, // tracking-tighter
                          color: Color(0xFF32445b), // text-primary
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // gap-6
                  // Area Romaji, Label, dan Arti
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Romaji & Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayRomaji,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 18, // text-lg
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF32445b), // text-primary
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(
                                4,
                              ), // rounded-sm
                            ),
                            child: Text(
                              displayCategory,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10, // text-[10px]
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5, // tracking-wider
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // space-y-3
                      // ID Translation
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ID',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5, // tracking-tighter
                              color: Color(0xFFC5C5D4), // text-outline-variant
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vocab.meaningId,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18, // text-lg
                              fontWeight: FontWeight.w600, // font-semibold
                              color: Color(0xFF191C1E), // text-on-surface
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // gap-4 from grid on mobile
                      // EN Translation
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EN',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Color(0xFFC5C5D4), // text-outline-variant
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vocab.meaningEn.isNotEmpty ? vocab.meaningEn : '-',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18, // text-lg
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500, // font-medium
                              color: const Color(
                                0xFF191C1E,
                              ).withOpacity(0.7), // text-on-surface/70
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bookmark Icon
            const Positioned(
              top: 16, // top-4 equivalent loosely
              right: 16,
              child: Icon(
                Icons.bookmark_border,
                color: Color(0xFFC5C5D4), // text-outline-variant
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/recently_added_card.dart';
import '../services/firestore_service.dart';
import '../models/vocabulary.dart';
import 'detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({Key? key}) : super(key: key);

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _firestoreService = FirestoreService();
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'おはようございます！';
    } else if (hour < 18) {
      return 'こんにちは！';
    } else {
      return 'こんばんは！';
    }
  }

  String _getIndonesianDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: const Color(
            0xFFf0f4f8,
          ), // From the background styling (slate-50 dark:bg-[#191c1e])
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'My Kamus Personal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        Icon(Icons.notifications, color: colors.primary),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Focus(
        autofocus: true, // Swallows any route-return autofocus so TextField doesn't get it
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          120,
        ), // Bottom padding for FAB and Nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: colors.primary,
                fontSize: 32,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getIndonesianDate(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                focusNode: _searchFocusNode,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Cari kata...',
                  hintStyle: TextStyle(
                    color: colors.outline.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12, left: 8),
                    child: Icon(Icons.search, color: colors.outline),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Statistik',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'DETAIL →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: colors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal scrollable stats
            StreamBuilder<List<Vocabulary>>(
              stream: _firestoreService.getVocabulariesStream(),
              builder: (context, snapshot) {
                int total = 0;
                int verbaCount = 0;
                int bendaCount = 0;
                int sifatCount = 0;
                int todayAddedCount = 0;

                if (snapshot.hasData) {
                  final vocabularies = snapshot.data!;
                  total = vocabularies.length;
                  verbaCount = vocabularies.where((v) => v.category.toLowerCase().contains('kerja') || v.category.toLowerCase().contains('verba')).length;
                  bendaCount = vocabularies.where((v) => v.category.toLowerCase().contains('benda')).length;
                  sifatCount = vocabularies.where((v) => v.category.toLowerCase().contains('sifat')).length;
                  
                  final today = DateTime.now();
                  todayAddedCount = vocabularies.where((v) => 
                      v.createdAt.year == today.year && 
                      v.createdAt.month == today.month && 
                      v.createdAt.day == today.day
                  ).length;
                }

                return Column(
                  children: [
                    _buildTotalVocabCard(total.toString(), colors),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSmallStatCard(verbaCount.toString(), 'Verba', Icons.directions_run_rounded, const Color(0xFF2C3E50), colors),
                        const SizedBox(width: 12),
                        _buildSmallStatCard(bendaCount.toString(), 'Benda', Icons.category_rounded, const Color(0xFF2C3E50), colors),
                        const SizedBox(width: 12),
                        _buildSmallStatCard(sifatCount.toString(), 'Sifat', Icons.palette_rounded, const Color(0xFF16A085), colors),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTargetHarianCard(todayAddedCount, colors),
                    const SizedBox(height: 16),
                    _buildProgresKeseluruhanCard(total, colors),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Review Card (Featured)
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    bottom: -40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.menu_book,
                        size: 160,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC2410C), // Dark orange/rust
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DUE NOW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sesi Belajar',
                              style: TextStyle(
                                fontSize: 16, // Larger size
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE8D0C0), // Peach/tan
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '🔥 12 kartu menunggu',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 28, // Much larger font
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Waktunya memperkuat ingatan\njangka panjang kamu hari ini.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15, // Larger size
                            height: 1.5,
                            color: Color(0xFFABB5BE), // Light grayish blue
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.onPrimary,
                            foregroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20), // Taller button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mulai Review',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: colors.primary,
                                      fontSize: 16, // Larger text
                                      fontWeight: FontWeight.w800, // Bolder
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Text('🚀', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recently Added List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terakhir Ditambahkan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Vocabulary>>(
              stream: _firestoreService.getVocabulariesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final vocabularies = snapshot.data ?? [];
                if (vocabularies.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Belum ada kata yang ditambahkan.',
                        style: TextStyle(color: colors.outline),
                      ),
                    ),
                  );
                }

                return Column(
                  children: vocabularies.take(5).map((vocab) {
                    
                    Color catColor = colors.primary;
                    Color catBg = colors.primaryContainer;
                    String displayCat = vocab.category.toUpperCase();
                    
                    final catLower = vocab.category.toLowerCase();
                    if (catLower.contains('kerja') || catLower.contains('verba')) {
                      catColor = const Color(0xFF138973); // Dark teal
                      catBg = const Color(0xFF90F4D0);    // Light mint
                      displayCat = 'KATA KERJA';
                    } else if (catLower.contains('sifat')) {
                      catColor = const Color(0xFFA14930); // Dark red/brown
                      catBg = const Color(0xFFF7D6C8);    // Peach
                      displayCat = 'KATA SIFAT';
                    } else if (catLower.contains('benda')) {
                      catColor = const Color(0xFF4C658D); // Dark slate blue
                      catBg = const Color(0xFFD3EEFC);    // Light blue
                      displayCat = 'KATA BENDA';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RecentlyAddedCard(
                        kanjiChar: vocab.kanji.isNotEmpty ? vocab.kanji[0] : (vocab.reading.isNotEmpty ? vocab.reading[0] : '?'),
                        word: vocab.kanji.isNotEmpty ? vocab.kanji : vocab.reading,
                        furigana: vocab.kanji.isNotEmpty ? vocab.reading : vocab.romaji,
                        meaning: vocab.meaningId,
                        category: displayCat,
                        categoryColor: catColor,
                        categoryBgColor: catBg,
                        onTap: () {
                          FocusScope.of(context).unfocus(); // Unfocus text field
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(vocab: vocab),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildTotalVocabCard(String total, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50), // Dark slate blue
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL KOSAKATA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colors.outline,
                  ),
                ),
                Text(
                  total,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2C41), // Deep contrasting text color
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'MASTERED',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: colors.primary, // Or use a darker color if needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String value, String label, IconData icon, Color iconColor, ColorScheme colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF2F7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2C41),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetHarianCard(int current, ColorScheme colors) {
    int target = 3;
    double progress = current / target;
    if (progress > 1.0) progress = 1.0;
    
    String messageText = current >= target ? '“Target tercapai, luar biasa!”' : '“Satu kata lagi untuk hari ini!”';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGET HARIAN',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colors.outline,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: '$current / $target ',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                  children: [
                    TextSpan(
                      text: 'KATA',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            messageText,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresKeseluruhanCard(int currentTotal, ColorScheme colors) {
    final startDate = DateTime(2023, 9, 23);
    final today = DateTime.now();
    final days = today.difference(startDate).inDays;
    final targetTotal = (days > 0 ? days : 1) * 3;

    double progress = currentTotal / targetTotal;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRES KESELURUHAN',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colors.outline,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: '${_formatNumber(currentTotal)} / ${_formatNumber(targetTotal)} ',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                  children: [
                    TextSpan(
                      text: 'KATA',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '“Perjalanan panjang dimulai dari langkah kecil.”',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    String str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ',' + result;
      }
      result = str[i] + result;
      count++;
    }
    return result;
  }
}

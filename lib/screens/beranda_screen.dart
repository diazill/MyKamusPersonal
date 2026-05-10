import 'package:flutter/material.dart';
import '../widgets/recently_added_card.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import '../models/vocabulary.dart';
import '../models/sentence.dart';
import '../models/notification_item.dart';
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
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
                        StreamBuilder<List<NotificationItem>>(
                          stream: _firestoreService.getNotificationsStream(),
                          builder: (context, snapshot) {
                            int unreadCount = 0;
                            if (snapshot.hasData) {
                              unreadCount = snapshot.data!.where((n) => !n.isRead).length;
                            }
                            return InkWell(
                              onTap: () => _showNotificationsDialog(context, colors),
                              borderRadius: BorderRadius.circular(99),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(Icons.notifications, color: colors.primary),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colors.tertiary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFFf0f4f8), width: 1.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              // Desktop / Wide Tablet Layout (2 Columns)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopHeader(colors),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Stats & Review (flex: 5)
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStatsSection(colors),
                            const SizedBox(height: 32),
                            _buildReviewSection(colors),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      // Right Column: Recently Added (flex: 7)
                      Expanded(
                        flex: 7,
                        child: _buildRecentlyAddedSection(colors),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // Mobile Layout (Single Column)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopHeader(colors),
                  const SizedBox(height: 32),
                  _buildStatsSection(colors),
                  const SizedBox(height: 32),
                  _buildReviewSection(colors),
                  const SizedBox(height: 32),
                  _buildRecentlyAddedSection(colors),
                ],
              );
            }
          },
        ),
      ),
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildTopHeader(ColorScheme colors) {
    return Column(
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
      ],
    );
  }

  Widget _buildStatsSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

            return StreamBuilder<List<Sentence>>(
              stream: _firestoreService.getSentencesStream(),
              builder: (context, sentenceSnapshot) {
                int totalSentences = 0;
                if (sentenceSnapshot.hasData) {
                  totalSentences = sentenceSnapshot.data!.length;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTotalCard(
                            'KOSAKATA', 
                            total.toString(), 
                            Icons.bar_chart, 
                            const Color(0xFF2C3E50), 
                            colors
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTotalCard(
                            'KALIMAT', 
                            totalSentences.toString(), 
                            Icons.format_quote_rounded, 
                            const Color(0xFFC2410C),
                            colors
                          ),
                        ),
                      ],
                    ),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewSection(ColorScheme colors) {
    return Container(
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
    );
  }

  Widget _buildRecentlyAddedSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
    );
  }

  Widget _buildTotalCard(String label, String total, IconData icon, Color iconBg, ColorScheme colors) {
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
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  void _showNotificationsDialog(BuildContext context, ColorScheme colors) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.05),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StreamBuilder<List<NotificationItem>>(
          stream: _firestoreService.getNotificationsStream(),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final unreadCount = notifications.where((n) => !n.isRead).length;

            return SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, right: 24),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            color: colors.surfaceContainerLow.withOpacity(0.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Notifikasi',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors.primaryContainer.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$unreadCount Baru',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // List
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: notifications.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        'Belum ada notifikasi',
                                        style: TextStyle(color: colors.outline),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: notifications.map((notif) {
                                        IconData iconData = Icons.notifications;
                                        Color iconBg = colors.surfaceContainerHighest;
                                        Color iconColor = colors.onSurfaceVariant;
                                        Color borderColor = Colors.transparent;

                                        if (notif.type == 'target') {
                                          iconData = Icons.emoji_events;
                                          iconBg = colors.secondaryContainer;
                                          iconColor = colors.onSecondaryContainer;
                                          borderColor = colors.secondary;
                                        } else if (notif.type == 'update') {
                                          iconData = Icons.system_update;
                                          iconBg = colors.primaryContainer.withOpacity(0.2);
                                          iconColor = colors.onPrimaryContainer;
                                        } else if (notif.type == 'reminder') {
                                          iconData = Icons.history_edu;
                                          iconBg = colors.tertiaryContainer;
                                          iconColor = colors.onTertiaryContainer;
                                          borderColor = colors.tertiary;
                                        }

                                        return _buildNotificationItem(
                                          icon: iconData,
                                          iconColor: iconColor,
                                          iconBg: iconBg,
                                          title: notif.title,
                                          body: notif.description,
                                          time: _formatDate(notif.createdAt),
                                          borderColor: borderColor,
                                          isUnread: !notif.isRead,
                                          colors: colors,
                                          onTap: () async {
                                            if (!notif.isRead) {
                                              await _firestoreService.markNotificationAsRead(notif.id);
                                            }
                                            Navigator.of(context).pop(); // close dropdown
                                            
                                            _showNotificationDetailOverlay(
                                              context,
                                              colors,
                                              icon: iconData,
                                              iconColor: iconColor,
                                              iconBg: iconBg,
                                              title: notif.title,
                                              body: notif.description,
                                              time: _formatDate(notif.createdAt),
                                              buttonText: notif.type == 'update' ? 'Update Sekarang' : 'Tutup',
                                              onButtonPressed: notif.type == 'update' ? () {} : null,
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                          // Footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: colors.surfaceContainerLowest,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(99),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  void _showNotificationDetailOverlay(
    BuildContext context, 
    ColorScheme colors, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
    required String time,
    required String buttonText,
    VoidCallback? onButtonPressed,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: colors.onSurface.withOpacity(0.2), // bg-on-background/20
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24), // rounded-xl
                      border: Border.all(color: colors.outlineVariant.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 48,
                          offset: const Offset(0, 24),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 36),
                        ),
                        // Content
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          time.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: colors.outline,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onButtonPressed != null) {
                                onButtonPressed();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
    required String time,
    required Color borderColor,
    required bool isUnread,
    required ColorScheme colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUnread ? colors.surfaceContainerLowest : colors.surfaceContainerLowest.withOpacity(0.4),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      color: isUnread ? colors.onSurface : colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isUnread ? colors.onSurfaceVariant : colors.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return difference.inMinutes <= 1 ? 'Baru saja' : '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }
}


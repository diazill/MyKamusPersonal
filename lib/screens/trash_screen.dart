import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_utils.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _firestoreService = FirestoreService();
  final Set<String> _selectedIds = {};

  bool _isAllSelected(List<Vocabulary> list) => list.isNotEmpty && _selectedIds.length == list.length;
  bool get _hasSelection => _selectedIds.isNotEmpty;

  void _toggleSelectAll(bool? value, List<Vocabulary> list) {
    if (value == null) return;
    setState(() {
      if (value) {
        _selectedIds.addAll(list.map((e) => e.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(String id, bool? value) {
    if (value == null) return;
    setState(() {
      if (value) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _processRestore() async {
    final ids = _selectedIds.toList();
    for (String id in ids) {
      await _firestoreService.restoreVocabulary(id);
    }
    setState(() {
      _selectedIds.clear();
    });
    if (mounted) {
      SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Item berhasil dipulihkan');
    }
  }

  Future<void> _processDeleteForever() async {
    final ids = _selectedIds.toList();
    for (String id in ids) {
      await _firestoreService.deleteVocabulary(id);
    }
    setState(() {
      _selectedIds.clear();
    });
    if (mounted) {
      SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Item dihapus permanen');
    }
  }

  Future<void> _emptyTrash(List<Vocabulary> list) async {
    for (var vocab in list) {
      await _firestoreService.deleteVocabulary(vocab.id);
    }
    setState(() {
      _selectedIds.clear();
    });
    if (mounted) {
      SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Tempat sampah berhasil dikosongkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // surface / background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: const Color(0xFFF8F9FA), // TopAppBar Shell bg
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF32445b)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRLjUzUSYeM5mbPJ8EE4B_LZm2llScg90EwpOAf9KMz6kPbNnQHUtzgoISkVX90-zUktrzzVwQr1FKplAQ6AnWA5csAmp6ymaP7d9W8HlMMpz8hUMFOvrIYcbQvhmbNBhxvP6eTwgU7IjDt4In-WYRWuZ6GFmUJyJdWRWD354Gw434z8dlEgnArYxpfvRCH6k-iRzxymKHcL6sow6Vs4mq7erpBYakg7IQQGR5aQuMtKnFLpK7UW5z4xJLMtWXKObyYTSO7iPyWE5k'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Vocabulary>>(
        stream: _firestoreService.getDeletedVocabulariesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vocabularies = snapshot.data ?? [];

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120), // Bottom padding untuk action bar
                children: [
                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ARCHIVE STORAGE',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                    color: Color(0xFF7c2500), // text-tertiary
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tempat Sampah',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF32445b), // text-primary
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: vocabularies.isEmpty ? null : () => _emptyTrash(vocabularies),
                            icon: const Icon(Icons.delete_sweep, size: 20),
                            label: const Text('Kosongkan', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFba1a1a), // text-error
                              side: BorderSide(color: const Color(0xFFc5c5d4).withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Selection Controls
                  if (vocabularies.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf2f4f7), // bg-surface-container-low
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isAllSelected(vocabularies),
                                onChanged: (val) => _toggleSelectAll(val, vocabularies),
                                activeColor: const Color(0xFF32445b), // primary
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: Color(0xFFc5c5d4)), // outline-variant
                              ),
                              Text(
                                'Pilih Semua (${vocabularies.length} item)',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF454652), // text-on-surface-variant
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Diurutkan Tanggal Dihapus',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFF757684), // text-outline
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vocabularies.isNotEmpty) const SizedBox(height: 16),

                  // Trash List
                  if (vocabularies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFe0e3e6), Color(0xFFeceef1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_delete_outlined, size: 40, color: Color(0xFF757684)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Fokus pada progres Anda.\nMasa lalu sekadar bahan belajar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF757684),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...vocabularies.map((vocab) {
                      bool isWord = vocab.category.toLowerCase().contains('kata');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, // bg-surface-container-lowest
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _selectedIds.contains(vocab.id),
                                onChanged: (value) => _toggleItem(vocab.id, value),
                                activeColor: const Color(0xFF32445b), // primary
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: Color(0xFFc5c5d4)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vocab.kanji,
                                                style: const TextStyle(
                                                  fontFamily: 'Noto Sans JP',
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF32445b), // primary
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                vocab.romaji,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  color: Color(0xFF454652), // on-surface-variant
                                                ),
                                              ),
                                              Text(
                                                vocab.meaningId,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF191c1e), // on-surface
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            // Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isWord ? const Color(0xFFe6e8eb) : const Color(0xFF9cefe4),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isWord ? 'WORD' : 'PHRASE',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                  color: isWord ? const Color(0xFF454652) : const Color(0xFF0a6f66),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'DIHAPUS PADA',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF757684),
                                              ),
                                            ),
                                            Text(
                                              _formatDate(vocab.deletedAt ?? vocab.createdAt),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF454652),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),

              // Contextual Action Bar (Fixed Bottom)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                bottom: _hasSelection ? 32 : -100, // Slide up/down
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hasSelection ? _processRestore : null,
                          icon: const Icon(Icons.restore, size: 20),
                          label: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF32445b), // primary
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hasSelection ? _processDeleteForever : null,
                          icon: const Icon(Icons.delete_forever, size: 20),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFba1a1a), // error
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

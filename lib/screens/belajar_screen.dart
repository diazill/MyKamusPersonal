import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';

class BelajarScreen extends StatefulWidget {
  const BelajarScreen({Key? key}) : super(key: key);

  @override
  State<BelajarScreen> createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> {
  // Mock State
  final List<String> _categories = ['Semua', 'Verba', 'Sifat', 'Benda', 'Kalimat'];
  String _selectedCategory = 'Semua';
  String _selectedMode = 'srs'; // 'srs' or 'random'
  int _selectedCount = 20;

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
              children: [
                const Text('🃏', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'Mode Belajar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pilih Kategori
            Text(
              'Pilih Kategori:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? colors.primary : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      isSelected ? '✓ $category' : category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Mode
            Text(
              'Mode:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildModeOption(
              context,
              id: 'srs',
              title: 'SRS Review',
              subtitle: '12 kartu menunggu direview hari ini',
              icon: Icons.access_time_filled,
              iconColor: colors.tertiary,
            ),
            const SizedBox(height: 12),
            _buildModeOption(
              context,
              id: 'random',
              title: 'Random Practice',
              subtitle: 'Belajar kartu secara acak untuk latihan ekstra',
              icon: Icons.shuffle,
              iconColor: colors.secondary,
            ),
            const SizedBox(height: 32),

            // Jumlah Kartu
            Text(
              'Jumlah Kartu:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10')),
                ButtonSegment(value: 20, label: Text('20')),
                ButtonSegment(value: 50, label: Text('50')),
                ButtonSegment(value: 999, label: Text('Semua')),
              ],
              selected: {_selectedCount},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedCount = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: colors.onPrimary,
                selectedBackgroundColor: colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 48),

            // Start Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to Flashcard Session Screen (TODO)
                    SnackbarUtils.showCustomAlert(context, isSuccess: true, message: 'Memulai sesi flashcard...');
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Belajar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colors.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('🚀', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedMode == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer.withOpacity(0.3) : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.surfaceContainerHighest,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryContainer : colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMode = value;
                  });
                }
              },
              activeColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

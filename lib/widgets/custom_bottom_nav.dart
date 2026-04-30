import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'home', 'Beranda', colors),
                _buildNavItem(1, 'library_books', 'Pustaka', colors),
                _buildAddNavItem(2, colors),
                _buildNavItem(3, 'school', 'Belajar', colors),
                _buildNavItem(4, 'settings', 'Setelan', colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String iconName,
    String label,
    ColorScheme colors,
  ) {
    final isSelected = currentIndex == index;

    // Mapping string icon names to Material Icons
    IconData iconData;
    switch (iconName) {
      case 'home':
        iconData = Icons.home_outlined;
        break;
      case 'library_books':
        iconData = Icons.my_library_books_outlined;
        break;
      case 'school':
        iconData = Icons.school_outlined;
        break;
      case 'settings':
        iconData = Icons.settings_outlined;
        break;
      default:
        iconData = Icons.circle;
    }

    if (isSelected) {
      if (iconName == 'home') iconData = Icons.home;
      if (iconName == 'library_books') iconData = Icons.my_library_books;
      if (iconName == 'school') iconData = Icons.school;
      if (iconName == 'settings') iconData = Icons.settings;
    }

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected ? colors.onPrimary : colors.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: isSelected ? colors.onPrimary : colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNavItem(int index, ColorScheme colors) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: colors.outline, size: 28),
            const SizedBox(height: 2),
            Text(
              'Tambah',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

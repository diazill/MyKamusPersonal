import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'pustaka_screen.dart';
import 'beranda_screen.dart';
import 'tambah_screen.dart';
import 'belajar_screen.dart';
import 'setelan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController(initialPage: 0);
  final _notchBottomBarController = NotchBottomBarController(index: 0);

  bool _isBottomNavTapped =
      false; // Mencegah bug onPageChanged ketika nabrak beberapa tab

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _notchBottomBarController.dispose();
    super.dispose();
  }

  final GlobalKey<PustakaScreenState> _pustakaKey = GlobalKey<PustakaScreenState>();
  final GlobalKey<TambahScreenState> _tambahKey = GlobalKey<TambahScreenState>();

  late final List<Widget> _screens = [
    BerandaScreen(),
    PustakaScreen(key: _pustakaKey),
    TambahScreen(key: _tambahKey),
    const BelajarScreen(),
    const SetelanScreen(),
  ];

  void _handleTabChange(int newIndex) {
    FocusScope.of(context).unfocus();
    if (newIndex != 1) {
      _pustakaKey.currentState?.resetSearch();
    }
    if (newIndex != 2) {
      _tambahKey.currentState?.resetInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: false,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Mengizinkan swipe/geser
        onPageChanged: (index) {
          if (!_isBottomNavTapped && _notchBottomBarController.index != index) {
            _notchBottomBarController.jumpTo(index);
          }
          _handleTabChange(index);
        },
        children: List.generate(
          _screens.length,
          (index) => KeepAliveWrapper(child: _screens[index]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _notchBottomBarController,
          color: colors.surfaceContainerLowest.withOpacity(0.9),
          showLabel: true,
          shadowElevation: 10,
          kBottomRadius: 28.0,
          itemLabelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colors.outline,
          ),
          notchColor: colors.primary,
          removeMargins: false,
          bottomBarWidth: 500,
          showShadow: true,
          durationInMilliSeconds: 300,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: Icon(Icons.home_outlined, color: colors.outline),
              activeItem: Icon(Icons.home, color: colors.onPrimary),
              itemLabel: 'Beranda',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.my_library_books_outlined,
                color: colors.outline,
              ),
              activeItem: Icon(Icons.my_library_books, color: colors.onPrimary),
              itemLabel: 'Pustaka',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.add_circle_outline,
                color: colors.outline,
              ),
              activeItem: Icon(Icons.add_circle, color: colors.onPrimary),
              itemLabel: 'Tambah',
            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.school_outlined, color: colors.outline),
              activeItem: Icon(Icons.school, color: colors.onPrimary),
              itemLabel: 'Belajar',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.settings_outlined,
                color: colors.outline,
              ),
              activeItem: Icon(Icons.settings, color: colors.onPrimary),
              itemLabel: 'Setelan',
            ),
          ],
          onTap: (index) {
            setState(() {
              _isBottomNavTapped = true;
            });
            
            _handleTabChange(index);
            
            // Trik optimasi: jika melompat jauh (>1 halaman), kita langsung lewati
            // halaman tengahnya secara instan agar tidak membebani rendering Blur
            int currentPage = _pageController.page?.round() ?? _pageController.initialPage;
            if ((index - currentPage).abs() > 1) {
              _pageController.jumpToPage(index > currentPage ? index - 1 : index + 1);
            }

            _pageController
                .animateToPage(
                  index,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                )
                .then((_) {
                  if (mounted) {
                    setState(() {
                      _isBottomNavTapped = false;
                    });
                  }
                });
          },
          kIconSize: 24.0,
        ),
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

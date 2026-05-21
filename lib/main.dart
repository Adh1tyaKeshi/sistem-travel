import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screens.dart';
import 'screens/saved_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';
import 'package:sistem_travel/screens/login_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LuminaTravelApp());
}

class LuminaTravelApp extends StatelessWidget {
  const LuminaTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina Travel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SavedScreen(),
    BookingScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
    (icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Saved'),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Bookings',
    ),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final selected = _currentIndex == i;
                final color = selected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.45);
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? _items[i].activeIcon : _items[i].icon,
                        color: color,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

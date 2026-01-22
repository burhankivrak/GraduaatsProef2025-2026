import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/rated_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});

  @override
  State<TabNavigator> createState() => _TabNavigator();
}

class _TabNavigator extends State<TabNavigator> {
  int _activeTab = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WatchlistScreen(),
    const FavoritesScreen(),
    const RatedScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      body: IndexedStack(
        index: _activeTab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        activeTab: _activeTab,
        onTabChanged: (index) => setState(() => _activeTab = index),
      ),
    );
  }
}

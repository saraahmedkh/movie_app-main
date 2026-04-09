import 'package:flutter/material.dart';
import 'package:movie_app/tabs/browse_tab.dart';
import 'package:movie_app/tabs/home_tab.dart';
import 'package:movie_app/tabs/profile_tab.dart';
import 'package:movie_app/tabs/search_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> tabs = [
    HomeTab(),
    SearchTab(),
    BrowseTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: _buildBottomnavBar(),
    );
  }

  Widget _buildBottomnavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItems(Icons.home, 0),
          _buildNavItems(Icons.search, 1),
          _buildNavItems(Icons.grid_view, 2),
          _buildNavItems(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItems(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected
              ? const Color(0xFFFFB800)
              : Colors.white.withOpacity(0.5),
          size: 28,
        ),
      ),
    );
  }
}

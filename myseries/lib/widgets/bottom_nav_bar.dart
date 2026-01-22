import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int activeTab;
  final Function(int) onTabChanged;

  const BottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF313743),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(
            icon: Icons.home,
            index: 0,
          ),
          _buildNavButton(
            icon: Icons.bookmark,
            index: 1,
          ),
          _buildNavButton(
            icon: Icons.favorite,
            index: 2,
          ),
          _buildNavButton(
            icon: Icons.star,
            index: 3,
          ),
          _buildNavButton(
            icon: Icons.person,
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activeTab == index
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

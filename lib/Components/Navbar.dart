import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const Navbar({Key? key, this.currentIndex = 0, required this.onTap})
    : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final List<_NavItem> items = [
    _NavItem(icon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.build, label: 'Parts'),
    _NavItem(icon: Icons.motorcycle, label: 'Motos'),
    _NavItem(icon: Icons.handyman, label: 'Repaird'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      selectedFontSize: 14,
      unselectedFontSize: 0,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: items.asMap().entries.map((entry) {
        int idx = entry.key;
        _NavItem item = entry.value;
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: widget.currentIndex == idx ? item.label : '',
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

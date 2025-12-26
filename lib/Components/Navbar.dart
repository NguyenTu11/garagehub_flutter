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
    Color selectedColor = Colors.blue.shade600;
    Color unselectedColor = Colors.blue.shade200;
    Color bgColor = Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50.withOpacity(0.18),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        selectedFontSize: 13,
        unselectedFontSize: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: items.asMap().entries.map((entry) {
          int idx = entry.key;
          _NavItem item = entry.value;
          bool selected = widget.currentIndex == idx;
          return BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 10 : 0,
                vertical: selected ? 4 : 0,
              ),
              decoration: selected
                  ? BoxDecoration(
                      color: selectedColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                item.icon,
                color: selected ? selectedColor : unselectedColor,
                size: selected ? 28 : 22,
              ),
            ),
            label: selected ? item.label : '',
          );
        }).toList(),
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

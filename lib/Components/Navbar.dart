import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils.dart';

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
    _NavItem(icon: Icons.home, label: 'Trang chủ'),
    _NavItem(icon: Icons.business, label: 'Thương hiệu'),
    _NavItem(icon: Icons.build, label: 'Phụ tùng'),
    _NavItem(icon: Icons.history, label: 'Lịch sử'),
    _NavItem(icon: Icons.calendar_today, label: 'Đặt lịch'),
    _NavItem(icon: Icons.person, label: 'Tài khoản'),
  ];

  void _showAccountPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  Utils.userName.isNotEmpty
                      ? Utils.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào! ${Utils.userName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    if (Utils.userEmail.isNotEmpty)
                      Text(
                        Utils.userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Utils.userName = '';
                    Utils.userEmail = '';
                    Utils.userId = '';
                    Utils.token = '';
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
        onTap: (index) {
          if (index == items.length - 1) {
            _showAccountPopup(context);
          } else {
            widget.onTap(index);
          }
        },
        selectedFontSize: 13,
        unselectedFontSize: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: items.asMap().entries.map((entry) {
          int idx = entry.key;
          _NavItem item = entry.value;
          bool selected = widget.currentIndex == idx;
          String label = item.label;
          if (idx == items.length - 1 && Utils.userName.isNotEmpty) {
            label = 'Chào! ${Utils.userName.split(' ').first}';
          }

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
            label: selected ? label : '',
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

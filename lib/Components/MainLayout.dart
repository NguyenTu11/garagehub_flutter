import 'package:flutter/material.dart';
import 'Header.dart';
import 'Navbar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTab;
  const MainLayout({
    Key? key,
    required this.child,
    this.currentIndex = 0,
    required this.onTab,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _handleNavigation(int index) {
    widget.onTab(index);

    final routes = [
      '/home',
      '/brands',
      '/parts',
      '/order-history',
      '/book-appointment',
    ];
    if (index < routes.length && index != widget.currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Header(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: Navbar(
          currentIndex: widget.currentIndex,
          onTap: _handleNavigation,
        ),
      ),
    );
  }
}

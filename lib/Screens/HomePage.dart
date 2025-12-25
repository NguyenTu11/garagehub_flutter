import 'package:flutter/material.dart';
import '../Components/MainLayout.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      onTab: (int idx) {},
      child: SafeArea(
        child: Center(
          child: Text(
            'GarageHub Home',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

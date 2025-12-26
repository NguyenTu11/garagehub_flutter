import 'package:flutter/material.dart';
import '../../Components/MainLayout.dart';
import 'NavbarCarousel.dart';
import 'ServiceCards.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      onTab: (int idx) {},
      child: SafeArea(
        child: Column(
          children: [
            NavbarCarousel(),
            SizedBox(height: 6),
            ServiceCards(),
            SizedBox(height: 18),
            Text(
              'GarageHub Home',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

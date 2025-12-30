import 'package:flutter/material.dart';
import '../../Components/MainLayout.dart';
import 'NavbarCarousel.dart';
import 'ServiceCards.dart';
import 'Accessories.dart';
import 'FeaturedProducts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      onTab: (int idx) {},
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            NavbarCarousel(),
            const SizedBox(height: 12),
            ServiceCards(),
            const SizedBox(height: 20),
            const Accessories(),
            const SizedBox(height: 20),
            const FeaturedProducts(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

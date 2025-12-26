import 'package:flutter/material.dart';

class NavbarCarousel extends StatefulWidget {
  const NavbarCarousel({Key? key}) : super(key: key);

  @override
  State<NavbarCarousel> createState() => _NavbarCarouselState();
}

class _NavbarCarouselState extends State<NavbarCarousel> {
  final List<String> images = [
    'Assets/Images/image5.jpg',
    'Assets/Images/image6.jpg',
    'Assets/Images/image7.jpg',
    'Assets/Images/image8.jpg',
  ];

  final List<String> captions = [
    'GarageHub\nGiải pháp phụ tùng xe máy toàn diện',
    'Đa dạng sản phẩm, chính hãng\nGiá tốt, dịch vụ tận tâm',
    'Hỗ trợ kỹ thuật và bảo hành uy tín',
    'Đặt hàng nhanh chóng, giao hàng tận nơi',
  ];

  int current = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _autoScroll();
    });
  }

  void _autoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) break;
      setState(() {
        current = (current + 1) % images.length;
        _pageController.animateToPage(
          current,
          duration: Duration(milliseconds: 700),
          curve: Curves.ease,
        );
      });
    }
  }

  void _onDotTap(int idx) {
    setState(() {
      current = idx;
      _pageController.animateToPage(
        current,
        duration: Duration(milliseconds: 700),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => current = idx),
            itemBuilder: (context, idx) {
              double scale = idx == current ? 1.0 : 0.96;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Image.asset(images[idx], fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.38),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          captions[idx].replaceAll('\\n', '\n'),
                          key: ValueKey(idx),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (idx) {
                return GestureDetector(
                  onTap: () => _onDotTap(idx),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    width: current == idx ? 8 : 6,
                    height: current == idx ? 8 : 6,
                    decoration: BoxDecoration(
                      color: current == idx
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: current == idx
                          ? [BoxShadow(color: Colors.black26, blurRadius: 2)]
                          : [],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

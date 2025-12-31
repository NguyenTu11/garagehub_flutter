import 'package:flutter/material.dart';
import 'dart:async';
import '../../Models/PartModel.dart';
import '../../Models/BrandModel.dart';
import '../../Services/PartService.dart';
import '../../Services/BrandService.dart';
import '../../Services/CartService.dart';
import '../../Utils.dart';
import '../parts/PartDetailScreen.dart';
import '../parts/PartsScreen.dart';
import '../brands/BrandsScreen.dart';

class FeaturedProducts extends StatefulWidget {
  const FeaturedProducts({Key? key}) : super(key: key);

  @override
  State<FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
  final PartService _partService = PartService();
  final BrandService _brandService = BrandService();
  final CartService _cartService = CartService();

  List<PartModel> _parts = [];
  List<BrandModel> _brands = [];
  bool _isLoading = true;
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;

  static const int _productsPerPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchData();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final partsResponse = await _partService.getAllParts();
      final brandsResponse = await _brandService.getAllBrands();

      setState(() {
        _parts = partsResponse.data.take(10).toList();
        _brands = brandsResponse.data.take(6).toList();
        _isLoading = false;
      });

      _startAutoScroll();
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_parts.isEmpty) return;

      setState(() {
        _currentPage = (_currentPage + 1) % _parts.length;
      });

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> _addToCart(PartModel part) async {
    if (part.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản phẩm đã hết hàng!'),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await _cartService.addToCart(part);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm "${part.name}" vào giỏ hàng',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _buyNow(PartModel part) async {
    if (part.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản phẩm đã hết hàng!'),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await _cartService.addToCart(part);

    if (mounted) {
      Navigator.of(context).pushNamed('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        _buildFeaturedProductsSection(),
        const SizedBox(height: 20),
        _buildBrandsSection(),
        const SizedBox(height: 20),
        _buildAboutSection(),
      ],
    );
  }

  Widget _buildFeaturedProductsSection() {
    final Color mainBlue = Colors.blue.shade700;

    if (_parts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: mainBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _parts.length,
              itemBuilder: (context, index) {
                final part = _parts[index];
                return _FeaturedProductCard(
                  part: part,
                  formatPrice: _formatPrice,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PartDetailScreen(partId: part.id!),
                      ),
                    );
                  },
                  onAddToCart: () => _addToCart(part),
                  onBuyNow: () => _buyNow(part),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_parts.length, (index) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 8 : 6,
                  height: _currentPage == index ? 8 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? mainBlue
                        : mainBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSection() {
    final Color mainBlue = Colors.blue.shade700;

    if (_brands.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green.shade600, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Phụ tùng chính hãng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainBlue,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrandsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: mainBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _brands.length,
            itemBuilder: (context, index) {
              final brand = _brands[index];
              return _BrandCard(
                brand: brand,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PartsScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white, Colors.transparent],
                      radius: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giới thiệu GarageHub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AboutItem(
                    icon: Icons.build,
                    color: Colors.blue.shade300,
                    text:
                        'GarageHub là nền tảng cung cấp phụ tùng, phụ kiện xe máy chính hãng, chất lượng cao.',
                  ),
                  const SizedBox(height: 12),
                  _AboutItem(
                    icon: Icons.handshake,
                    color: Colors.green.shade300,
                    text:
                        'Hợp tác với nhiều thương hiệu uy tín, đảm bảo nguồn gốc xuất xứ rõ ràng.',
                  ),
                  const SizedBox(height: 12),
                  _AboutItem(
                    icon: Icons.verified_user,
                    color: Colors.purple.shade300,
                    text:
                        'Hỗ trợ tư vấn kỹ thuật tận tâm, chính sách bảo hành minh bạch.',
                  ),
                  const SizedBox(height: 12),
                  _AboutItem(
                    icon: Icons.local_shipping,
                    color: Colors.orange.shade300,
                    text:
                        'Giao hàng toàn quốc, đặt hàng nhanh chóng, giá cả cạnh tranh.',
                  ),
                  const SizedBox(height: 12),
                  _AboutItem(
                    icon: Icons.gps_fixed,
                    color: Colors.pink.shade300,
                    text:
                        'GarageHub cam kết đồng hành cùng khách hàng trên mọi hành trình.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final PartModel part;
  final String Function(double) formatPrice;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _FeaturedProductCard({
    required this.part,
    required this.formatPrice,
    required this.onTap,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: part.image.isNotEmpty
                      ? Image.network(
                          Utils.getBackendImgURL(part.image),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.build,
                              size: 60,
                              color: Colors.grey.shade400,
                            );
                          },
                        )
                      : Icon(
                          Icons.build,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              part.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${formatPrice(part.price)} VND',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Còn: ${part.quantity} ${part.unit}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            if (part.quantity > 0)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onBuyNow,
                      icon: const Icon(Icons.credit_card, size: 16),
                      label: const Text('Mua ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.shopping_cart, size: 16),
                      label: const Text('Giỏ hàng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Hết hàng',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final VoidCallback onTap;

  const _BrandCard({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 4,
                      right: 4,
                      bottom: 4,
                    ),
                    child: brand.image.isNotEmpty
                        ? Image.network(
                            Utils.getBackendImgURL(brand.image),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                size: 32,
                                color: Colors.grey.shade400,
                              );
                            },
                          )
                        : Icon(
                            Icons.business,
                            size: 32,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.green.shade500,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _AboutItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

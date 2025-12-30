import 'package:flutter/material.dart';
import '../../Models/PartModel.dart';
import '../../Services/PartService.dart';
import '../../Services/CartService.dart';
import '../../Utils.dart';

class PartDetailScreen extends StatefulWidget {
  final String partId;

  const PartDetailScreen({Key? key, required this.partId}) : super(key: key);

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  final PartService _partService = PartService();
  final CartService _cartService = CartService();

  PartModel? _part;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPart();
  }

  Future<void> _fetchPart() async {
    setState(() => _isLoading = true);
    try {
      final part = await _partService.getPartById(widget.partId);
      setState(() => _part = part);
    } catch (e) {
      debugPrint('Error fetching part details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> _addToCart() async {
    if (_part == null) return;

    if (_part!.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản phẩm đã hết hàng!'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    await _cartService.addToCart(_part!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "${_part!.name}" vào giỏ hàng'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Xem giỏ',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ),
      );
    }
  }

  Future<void> _buyNow() async {
    if (_part == null) return;

    if (_part!.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản phẩm đã hết hàng!'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    await _cartService.addToCart(_part!);

    if (mounted) {
      Navigator.of(context).pushNamed('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = Colors.blue.shade700;
    final Color lightBlue = Colors.blue.shade50;

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết phụ tùng',
          style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _part == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy phụ tùng',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _part!.image.isNotEmpty
                              ? Image.network(
                                  Utils.getBackendImgURL(_part!.image),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.build,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.build,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _part!.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: mainBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_formatPrice(_part!.price)} VND',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _DetailItem(
                          icon: Icons.inventory_2,
                          label: 'Số lượng tồn kho',
                          value: '${_part!.quantity} ${_part!.unit}',
                          valueColor: _part!.quantity > 0
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                        const SizedBox(height: 16),
                        _DetailItem(
                          icon: Icons.straighten,
                          label: 'Đơn vị',
                          value: _part!.unit,
                        ),
                        const SizedBox(height: 16),
                        _DetailItem(
                          icon: Icons.business,
                          label: 'Thương hiệu',
                          value: _part!.brand?.name ?? 'Không xác định',
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: _part!.quantity > 0
                                      ? _addToCart
                                      : null,
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Thêm giỏ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue.shade600,
                                    side: BorderSide(
                                      color: Colors.blue.shade600,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _part!.quantity > 0
                                      ? _buyNow
                                      : null,
                                  icon: const Icon(Icons.flash_on, size: 20),
                                  label: Text(
                                    _part!.quantity > 0
                                        ? 'Mua ngay'
                                        : 'Hết hàng',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _part!.quantity > 0
                                        ? Colors.green.shade600
                                        : Colors.grey.shade400,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

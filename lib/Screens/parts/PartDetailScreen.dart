import 'package:flutter/material.dart';
import '../../Components/ShimmerLoading.dart';
import '../../Models/PartModel.dart';
import '../../Models/ReviewModel.dart';
import '../../Services/PartService.dart';
import '../../Services/CartService.dart';
import '../../Utils.dart';

class PartDetailScreen extends StatefulWidget {
  final String partId;

  const PartDetailScreen({Key? key, required this.partId}) : super(key: key);

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen>
    with SingleTickerProviderStateMixin {
  final PartService _partService = PartService();
  final CartService _cartService = CartService();

  PartModel? _part;
  ReviewsResponse? _reviewsResponse;
  bool _isLoading = true;
  bool _isSubmittingReview = false;

  int _selectedRating = 5;
  final _commentController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _partService.getPartById(widget.partId),
        _partService.getPartReviews(widget.partId),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
      final part = results[0] as PartModel?;
      final reviews = results[1];
      setState(() {
        _part = part;
        _reviewsResponse = reviews;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
      _animationController.forward();
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập nội dung đánh giá', isError: true);
      return;
    }

    if (Utils.token.isEmpty) {
      _showSnackBar('Vui lòng đăng nhập để đánh giá', isError: true);
      return;
    }

    setState(() => _isSubmittingReview = true);

    final result = await _partService.createReview(
      widget.partId,
      _selectedRating,
      _commentController.text.trim(),
    );

    setState(() => _isSubmittingReview = false);

    if (result['success'] == true) {
      _commentController.clear();
      _selectedRating = 5;
      _showSnackBar('Đánh giá thành công!');
      final reviews = await _partService.getPartReviews(widget.partId);
      setState(() => _reviewsResponse = reviews);
    } else {
      _showSnackBar(result['message'] ?? 'Có lỗi xảy ra', isError: true);
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addToCart() async {
    if (_part == null) return;

    if (_part!.quantity <= 0) {
      _showSnackBar('Sản phẩm đã hết hàng!', isError: true);
      return;
    }

    await _cartService.addToCart(_part!);

    if (mounted) {
      _showSnackBar('Đã thêm "${_part!.name}" vào giỏ hàng', showAction: true);
    }
  }

  Future<void> _buyNow() async {
    if (_part == null) return;

    if (_part!.quantity <= 0) {
      _showSnackBar('Sản phẩm đã hết hàng!', isError: true);
      return;
    }

    await _cartService.addToCart(_part!);

    if (mounted) {
      Navigator.of(context).pushNamed('/cart');
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool showAction = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: _isLoading
            ? _buildLoadingState()
            : _part == null
            ? _buildEmptyState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const ShimmerDetailPage();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.build_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không tìm thấy phụ tùng',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.blue.shade800,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50.withOpacity(0.6),
                      Colors.white,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: _part!.image.isNotEmpty
                              ? Image.network(
                                  Utils.getBackendImgURL(_part!.image),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildProductPlaceholder();
                                  },
                                )
                              : _buildProductPlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _part!.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _buildRatingDisplay(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade500,
                            Colors.green.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade300.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_formatPrice(_part!.price)} VND',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _DetailItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'Số lượng tồn kho',
                      value: '${_part!.quantity} ${_part!.unit}',
                      valueColor: _part!.quantity > 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    const SizedBox(height: 14),
                    _DetailItem(
                      icon: Icons.straighten_rounded,
                      label: 'Đơn vị',
                      value: _part!.unit,
                    ),
                    const SizedBox(height: 14),
                    _DetailItem(
                      icon: Icons.storefront_rounded,
                      label: 'Thương hiệu',
                      value: _part!.brand?.name ?? 'Không xác định',
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Thêm giỏ',
                            icon: Icons.add_shopping_cart_rounded,
                            isOutlined: true,
                            onPressed: _part!.quantity > 0 ? _addToCart : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ActionButton(
                            label: _part!.quantity > 0
                                ? 'Mua ngay'
                                : 'Hết hàng',
                            icon: Icons.flash_on_rounded,
                            isOutlined: false,
                            isDisabled: _part!.quantity <= 0,
                            onPressed: _part!.quantity > 0 ? _buyNow : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildReviewsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDisplay() {
    final averageRating = _reviewsResponse?.averageRating ?? 0;
    final reviewCount = _reviewsResponse?.reviewCount ?? 0;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (index) {
              if (index < averageRating.floor()) {
                return Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade600,
                  size: 20,
                );
              } else if (index < averageRating) {
                return Icon(
                  Icons.star_half_rounded,
                  color: Colors.amber.shade600,
                  size: 20,
                );
              } else {
                return Icon(
                  Icons.star_outline_rounded,
                  color: Colors.amber.shade300,
                  size: 20,
                );
              }
            }),
            const SizedBox(width: 8),
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.amber.shade800,
              ),
            ),
            Text(
              ' ($reviewCount đánh giá)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rate_review_rounded,
              color: Colors.blue.shade600,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Đánh giá sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAddReviewForm(),
        const SizedBox(height: 24),
        if (_reviewsResponse != null && _reviewsResponse!.reviews.isNotEmpty)
          ..._reviewsResponse!.reviews.map(
            (review) => _ReviewCard(review: review, formatDate: _formatDate),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có đánh giá nào',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                  Text(
                    'Hãy là người đầu tiên đánh giá!',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddReviewForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Viết đánh giá của bạn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Đánh giá: ',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRating = index + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      index < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber.shade600,
                      size: 32,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
              decoration: InputDecoration(
                hintText: 'Nhập nội dung đánh giá...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isSubmittingReview ? null : _submitReview,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSubmittingReview
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Gửi đánh giá',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      child: Center(
        child: Icon(Icons.build_rounded, size: 60, color: Colors.blue.shade300),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String Function(DateTime?) formatDate;

  const _ReviewCard({required this.review, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber.shade600,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
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
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.blue.shade800,
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

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isOutlined;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isOutlined,
    this.isDisabled = false,
    this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        height: 54,
        decoration: BoxDecoration(
          gradient: widget.isOutlined || isDisabled
              ? null
              : LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade700],
                ),
          color: isDisabled
              ? Colors.grey.shade300
              : (widget.isOutlined ? Colors.white : null),
          borderRadius: BorderRadius.circular(16),
          border: widget.isOutlined && !isDisabled
              ? Border.all(color: Colors.blue.shade600, width: 2)
              : null,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: widget.isOutlined
                        ? Colors.blue.shade100.withOpacity(0.4)
                        : Colors.green.shade300.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: isDisabled
                  ? Colors.grey.shade500
                  : (widget.isOutlined ? Colors.blue.shade600 : Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? Colors.grey.shade500
                    : (widget.isOutlined ? Colors.blue.shade600 : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

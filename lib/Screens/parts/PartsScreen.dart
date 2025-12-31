import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/MainLayout.dart';
import '../../Models/PartModel.dart';
import '../../Models/BrandModel.dart';
import '../../Services/PartService.dart';
import '../../Services/BrandService.dart';
import '../../Utils.dart';
import 'PartDetailScreen.dart';

class PartsScreen extends StatefulWidget {
  final String? initialSearchTerm;

  const PartsScreen({Key? key, this.initialSearchTerm}) : super(key: key);

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final PartService _partService = PartService();
  final BrandService _brandService = BrandService();
  final TextEditingController _searchController = TextEditingController();

  List<PartModel> _parts = [];
  List<PartModel> _filteredParts = [];
  List<BrandModel> _brands = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchTerm = '';
  String? _selectedBrandId;
  String _sortOrder = '';

  static const String _viewPreferenceKey = 'parts_view_preference';

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _fetchData();

    // Apply initial search term if provided
    if (widget.initialSearchTerm != null &&
        widget.initialSearchTerm!.isNotEmpty) {
      _searchController.text = widget.initialSearchTerm!;
      _searchTerm = widget.initialSearchTerm!;
    }
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool(_viewPreferenceKey) ?? true;
    setState(() {
      _isGridView = isGrid;
    });
  }

  Future<void> _saveViewPreference(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewPreferenceKey, isGrid);
  }

  void _toggleView(bool isGrid) {
    setState(() {
      _isGridView = isGrid;
    });
    _saveViewPreference(isGrid);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final partsResponse = await _partService.getAllParts();
      final brandsResponse = await _brandService.getAllBrands();

      if (partsResponse.status) {
        setState(() {
          _parts = partsResponse.data;
          _filteredParts = partsResponse.data;
        });
      }
      if (brandsResponse.status) {
        setState(() {
          _brands = brandsResponse.data;
        });
      }

      if (_searchTerm.isNotEmpty) {
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<PartModel> filtered = List.from(_parts);
    if (_searchTerm.isNotEmpty) {
      filtered = filtered
          .where(
            (part) =>
                part.name.toLowerCase().contains(_searchTerm.toLowerCase()),
          )
          .toList();
    }

    if (_selectedBrandId != null && _selectedBrandId!.isNotEmpty) {
      filtered = filtered
          .where(
            (part) =>
                part.brandId == _selectedBrandId ||
                part.brand?.id == _selectedBrandId,
          )
          .toList();
    }

    switch (_sortOrder) {
      case 'asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'priceAsc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    setState(() {
      _filteredParts = filtered;
    });
  }

  void _onSearch(String query) {
    _searchTerm = query;
    _applyFilters();
  }

  void _onBrandFilter(String? brandId) {
    _selectedBrandId = brandId;
    _applyFilters();
  }

  void _onSortChange(String? sortOrder) {
    if (sortOrder != null) {
      _sortOrder = sortOrder;
      _applyFilters();
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      onTab: (int idx) {},
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50.withOpacity(0.6),
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredParts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: Colors.blue.shade600,
                      child: _isGridView ? _buildGridView() : _buildListView(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phụ tùng',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_filteredParts.length} sản phẩm',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: TextStyle(fontSize: 15, color: Colors.blue.shade800),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phụ tùng...',
                hintStyle: TextStyle(
                  color: Colors.blueGrey.shade300,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.blue.shade400,
                  size: 22,
                ),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.blue.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildBrandDropdown()),
              const SizedBox(width: 10),
              Expanded(child: _buildSortDropdown()),
              const SizedBox(width: 10),
              _buildViewToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBrandId,
          hint: Text(
            'Tất cả hãng',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.blue.shade400,
          ),
          items: [
            DropdownMenuItem<String>(
              value: '',
              child: Text(
                'Tất cả hãng',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
            ..._brands.map(
              (brand) => DropdownMenuItem<String>(
                value: brand.id,
                child: Text(
                  brand.name,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
          onChanged: (value) {
            _onBrandFilter(value == '' ? null : value);
          },
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortOrder.isEmpty ? null : _sortOrder,
          hint: Text(
            'Sắp xếp',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.blue.shade400,
          ),
          items: [
            DropdownMenuItem(
              value: 'asc',
              child: Text(
                'A → Z',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
            DropdownMenuItem(
              value: 'desc',
              child: Text(
                'Z → A',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
            DropdownMenuItem(
              value: 'priceAsc',
              child: Text(
                'Giá ↑',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
            DropdownMenuItem(
              value: 'priceDesc',
              child: Text(
                'Giá ↓',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
          onChanged: _onSortChange,
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () => _toggleView(true),
          ),
          _ViewToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: !_isGridView,
            onTap: () => _toggleView(false),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
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
              Icons.search_off_rounded,
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
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _filteredParts.length,
      itemBuilder: (context, index) {
        final part = _filteredParts[index];
        return _PartGridCard(
          part: part,
          index: index,
          formatPrice: _formatPrice,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartDetailScreen(partId: part.id!),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredParts.length,
      itemBuilder: (context, index) {
        final part = _filteredParts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PartListCard(
            part: part,
            index: index,
            formatPrice: _formatPrice,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartDetailScreen(partId: part.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}

class _PartGridCard extends StatefulWidget {
  final PartModel part;
  final int index;
  final String Function(double) formatPrice;
  final VoidCallback onTap;

  const _PartGridCard({
    required this.part,
    required this.index,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  State<_PartGridCard> createState() => _PartGridCardState();
}

class _PartGridCardState extends State<_PartGridCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _scaleAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Colors.blue.shade200.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isPressed ? 20 : 16,
                offset: Offset(0, _isPressed ? 8 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: widget.part.image.isNotEmpty
                        ? Image.network(
                            Utils.getBackendImgURL(widget.part.image),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.part.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.formatPrice(widget.part.price)} VND',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.part.brand?.name ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.part.quantity > 0
                                        ? Colors.blue.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${widget.part.quantity}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: widget.part.quantity > 0
                                          ? Colors.blue.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      child: Center(
        child: Icon(Icons.build_rounded, size: 40, color: Colors.blue.shade300),
      ),
    );
  }
}

class _PartListCard extends StatefulWidget {
  final PartModel part;
  final int index;
  final String Function(double) formatPrice;
  final VoidCallback onTap;

  const _PartListCard({
    required this.part,
    required this.index,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  State<_PartListCard> createState() => _PartListCardState();
}

class _PartListCardState extends State<_PartListCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Colors.blue.shade200.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: widget.part.image.isNotEmpty
                      ? Image.network(
                          Utils.getBackendImgURL(widget.part.image),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.part.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.part.brand?.name ?? 'Không xác định',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.formatPrice(widget.part.price)} VND',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.part.quantity > 0
                                ? Colors.blue.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: widget.part.quantity > 0
                                    ? Colors.blue.shade600
                                    : Colors.red.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.part.quantity} ${widget.part.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: widget.part.quantity > 0
                                      ? Colors.blue.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      child: Center(
        child: Icon(Icons.build_rounded, size: 28, color: Colors.blue.shade300),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../Components/MainLayout.dart';
import '../../Models/PartModel.dart';
import '../../Models/BrandModel.dart';
import '../../Services/PartService.dart';
import '../../Services/BrandService.dart';
import '../../Utils.dart';
import 'PartDetailScreen.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _fetchData();
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
    final Color mainBlue = Colors.blue.shade700;
    final Color lightBlue = Colors.blue.shade50;
    final Color accentBlue = Colors.blue.shade400;

    return MainLayout(
      currentIndex: 2,
      onTab: (int idx) {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build, color: mainBlue, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Phụ tùng',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: mainBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tổng số: ${_filteredParts.length} phụ tùng',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: TextStyle(fontSize: 16, color: mainBlue),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm phụ tùng...',
                      hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: accentBlue),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: accentBlue),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBrandId,
                            hint: Text(
                              'Tất cả hãng',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: accentBlue,
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text('Tất cả hãng'),
                              ),
                              ..._brands.map(
                                (brand) => DropdownMenuItem<String>(
                                  value: brand.id,
                                  child: Text(brand.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _onBrandFilter(value == '' ? null : value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortOrder.isEmpty ? null : _sortOrder,
                            hint: Text(
                              'Sắp xếp',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: accentBlue,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'asc',
                                child: Text('A → Z'),
                              ),
                              DropdownMenuItem(
                                value: 'desc',
                                child: Text('Z → A'),
                              ),
                              DropdownMenuItem(
                                value: 'priceAsc',
                                child: Text('Giá ↑'),
                              ),
                              DropdownMenuItem(
                                value: 'priceDesc',
                                child: Text('Giá ↓'),
                              ),
                            ],
                            onChanged: _onSortChange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _ViewToggleButton(
                            icon: Icons.grid_view,
                            isSelected: _isGridView,
                            onTap: () => setState(() => _isGridView = true),
                          ),
                          _ViewToggleButton(
                            icon: Icons.view_list,
                            isSelected: !_isGridView,
                            onTap: () => setState(() => _isGridView = false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredParts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy phụ tùng',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: _isGridView ? _buildGridView() : _buildListView(),
                  ),
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
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredParts.length,
      itemBuilder: (context, index) {
        final part = _filteredParts[index];
        return _PartGridCard(
          part: part,
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredParts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final part = _filteredParts[index];
        return _PartListCard(
          part: part,
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
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }
}

class _PartGridCard extends StatelessWidget {
  final PartModel part;
  final String Function(double) formatPrice;
  final VoidCallback onTap;

  const _PartGridCard({
    required this.part,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: part.image.isNotEmpty
                      ? Image.network(
                          Utils.getBackendImgURL(part.image),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.build,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.build,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      part.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatPrice(part.price)} VND',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          part.brand?.name ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _PartListCard extends StatelessWidget {
  final PartModel part;
  final String Function(double) formatPrice;
  final VoidCallback onTap;

  const _PartListCard({
    required this.part,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: part.image.isNotEmpty
                    ? Image.network(
                        Utils.getBackendImgURL(part.image),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.build,
                            size: 32,
                            color: Colors.grey.shade400,
                          );
                        },
                      )
                    : Icon(Icons.build, size: 32, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        part.brand?.name ?? 'Không xác định',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formatPrice(part.price)} VND',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: part.quantity > 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Còn ${part.quantity} ${part.unit}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: part.quantity > 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
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
    );
  }
}

import 'package:flutter/material.dart';
import '../../Models/PartModel.dart';
import '../../Services/PartService.dart';
import '../../Utils.dart';
import '../parts/PartsScreen.dart';

class Accessories extends StatefulWidget {
  const Accessories({Key? key}) : super(key: key);

  @override
  State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  final PartService _partService = PartService();
  List<PartModel> _parts = [];
  bool _isLoading = true;
  bool _showAll = false;

  static const int _defaultItems = 8;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    try {
      final response = await _partService.getAllParts();
      if (response.status) {
        setState(() {
          _parts = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching parts: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> get _categories {
    final Map<String, String> uniqueCategories = {};
    for (var part in _parts) {
      if (!uniqueCategories.containsKey(part.name)) {
        uniqueCategories[part.name] = part.image;
      }
    }
    return uniqueCategories.entries
        .map((e) => {'name': e.key, 'image': e.value})
        .toList();
  }

  List<Map<String, String>> get _visibleCategories {
    if (_showAll) return _categories;
    return _categories.take(_defaultItems).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = Colors.blue.shade700;

    if (_isLoading) {
      return Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  Icon(Icons.settings, color: mainBlue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Danh mục phụ tùng',
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
                      builder: (context) => const PartsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔧 Xem tất cả',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == _categories.length - 1 ? 0 : 0,
                  ),
                  child: _AccessoryItem(
                    name: category['name']!,
                    image: category['image']!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PartsScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessoryItem extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;

  const _AccessoryItem({
    required this.name,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                child: image.isNotEmpty
                    ? Image.network(
                        Utils.getBackendImgURL(image),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.build,
                            size: 28,
                            color: Colors.grey.shade400,
                          );
                        },
                      )
                    : Icon(Icons.build, size: 28, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

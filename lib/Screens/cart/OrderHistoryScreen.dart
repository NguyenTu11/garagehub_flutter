import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../Models/OrderModel.dart';
import '../../Services/OrderService.dart';
import '../../Utils.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  IO.Socket? _socket;
  String get _socketUrl {
    final baseUrl = Utils.baseUrl;
    if (baseUrl.contains('/api/v1')) {
      return baseUrl.replaceAll('/api/v1', '');
    }
    return baseUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(
      '$_socketUrl/orders',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': Utils.userId})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {});

    _socket!.onDisconnect((_) {});

    _socket!.onConnectError((error) {
      debugPrint('📦 Order socket connection error: $error');
    });

    _socket!.on('order-status-update', (data) {
      if (data != null && mounted) {
        final updatedOrderId = data['orderId']?.toString();
        final newStatus = data['status']?.toString();

        if (updatedOrderId != null && newStatus != null) {
          setState(() {
            final index = _orders.indexWhere(
              (order) => order.id == updatedOrderId,
            );
            if (index != -1) {
              _orders[index] = OrderModel(
                id: _orders[index].id,
                orderId: _orders[index].orderId,
                userId: _orders[index].userId,
                user: _orders[index].user,
                items: _orders[index].items,
                totalAmount: _orders[index].totalAmount,
                status: newStatus,
                shippingAddress: _orders[index].shippingAddress,
                paymentMethod: _orders[index].paymentMethod,
                notes: _orders[index].notes,
                createdAt: _orders[index].createdAt,
                updatedAt: DateTime.now(),
              );
            }
          });
        }
      }
    });

    _socket!.connect();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.getOrdersByUser();
      if (response.status) {
        setState(() {
          _orders = response.data;
          _orders.sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status ?? 'Không xác định';
    }
  }

  void _showOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(
        order: order,
        formatPrice: _formatPrice,
        formatDate: _formatDate,
        getStatusColor: _getStatusColor,
        getStatusText: _getStatusText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBlue = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainBlue),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: mainBlue),
            const SizedBox(width: 8),
            Text(
              'Lịch sử mua hàng',
              style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return _OrderCard(
                    order: order,
                    formatPrice: _formatPrice,
                    formatDate: _formatDate,
                    getStatusColor: _getStatusColor,
                    getStatusText: _getStatusText,
                    onTap: () => _showOrderDetail(order),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy mua sắm để có đơn hàng đầu tiên',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatPrice;
  final String Function(DateTime?) formatDate;
  final Color Function(String?) getStatusColor;
  final String Function(String?) getStatusText;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
    required this.getStatusColor,
    required this.getStatusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn #${order.orderId ?? order.id?.substring(0, 8) ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDate(order.createdAt),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  '${order.items.length} sản phẩm',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền:'),
                Text(
                  '${formatPrice(order.totalAmount)} VND',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Xem chi tiết →',
                  style: TextStyle(
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatPrice;
  final String Function(DateTime?) formatDate;
  final Color Function(String?) getStatusColor;
  final String Function(String?) getStatusText;

  const _OrderDetailSheet({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
    required this.getStatusColor,
    required this.getStatusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Mã đơn', order.orderId ?? order.id ?? 'N/A'),
                  _buildInfoRow('Ngày đặt', formatDate(order.createdAt)),
                  _buildInfoRow('Trạng thái', getStatusText(order.status)),
                  const Divider(height: 24),
                  if (order.shippingAddress != null) ...[
                    const Text(
                      'Thông tin giao hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (order.shippingAddress!.street != null &&
                        order.shippingAddress!.street!.isNotEmpty)
                      _buildInfoRow('Địa chỉ', order.shippingAddress!.street!),
                    if (order.shippingAddress!.city != null &&
                        order.shippingAddress!.city!.isNotEmpty)
                      _buildInfoRow('Thành phố', order.shippingAddress!.city!),
                    const Divider(height: 24),
                  ],
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    _buildInfoRow('Ghi chú', order.notes!),
                    const Divider(height: 24),
                  ],
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name ?? 'Sản phẩm'} x${item.quantity}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          Text(
                            '${formatPrice(item.subtotal ?? (item.price ?? 0) * item.quantity)} đ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${formatPrice(order.totalAmount)} VND',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

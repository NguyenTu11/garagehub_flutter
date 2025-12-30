import '../Repository/OrderRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/OrderModel.dart';

class OrderService {
  late OrderRepository orderRepository;

  OrderService() {
    this.orderRepository = OrderRepository();
  }

  Future<ApiResponse<OrderModel>> getAllOrders() async {
    return await orderRepository.getAllOrders();
  }

  Future<ApiResponse<OrderModel>> getOrdersByUser() async {
    return await orderRepository.getOrdersByUser();
  }

  Future<OrderModel> getOrderById(String id) async {
    return await orderRepository.getOrderById(id);
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    return await orderRepository.createOrder(order);
  }

  Future<OrderModel> updateOrder(String id, OrderModel order) async {
    return await orderRepository.updateOrder(id, order);
  }
}

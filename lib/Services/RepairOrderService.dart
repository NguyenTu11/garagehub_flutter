import '../Repository/RepairOrderRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/RepairOrderModel.dart';

class RepairOrderService {
  late RepairOrderRepository repairOrderRepository;

  RepairOrderService() {
    this.repairOrderRepository = RepairOrderRepository();
  }

  Future<ApiResponse<RepairOrderModel>> getAllRepairOrders() async {
    return await repairOrderRepository.getAllRepairOrders();
  }

  Future<RepairOrderModel> getRepairOrderById(String id) async {
    return await repairOrderRepository.getRepairOrderById(id);
  }

  Future<RepairOrderModel> createRepairOrder(RepairOrderModel order) async {
    return await repairOrderRepository.createRepairOrder(order);
  }

  Future<RepairOrderModel> updateRepairOrder(
      String id, RepairOrderModel order) async {
    return await repairOrderRepository.updateRepairOrder(id, order);
  }

  Future<void> deleteRepairOrder(String id) async {
    return await repairOrderRepository.deleteRepairOrder(id);
  }
}


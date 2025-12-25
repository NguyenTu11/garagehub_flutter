import '../Repository/PartRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/PartModel.dart';

class PartService {
  late PartRepository partRepository;

  PartService() {
    this.partRepository = PartRepository();
  }

  Future<ApiResponse<PartModel>> getAllParts() async {
    return await partRepository.getAllParts();
  }

  Future<PartModel> getPartById(String id) async {
    return await partRepository.getPartById(id);
  }

  Future<PartModel> createPart(PartModel part, String? imagePath) async {
    return await partRepository.createPart(part, imagePath);
  }

  Future<PartModel> updatePart(
      String id, PartModel part, String? imagePath) async {
    return await partRepository.updatePart(id, part, imagePath);
  }

  Future<void> deletePart(String id) async {
    return await partRepository.deletePart(id);
  }
}


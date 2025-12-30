import '../Repository/BrandRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/BrandModel.dart';

class BrandService {
  late BrandRepository brandRepository;

  BrandService() {
    this.brandRepository = BrandRepository();
  }

  Future<ApiResponse<BrandModel>> getAllBrands() async {
    return await brandRepository.getAllBrands();
  }

  Future<BrandModel> getBrandById(String id) async {
    return await brandRepository.getBrandById(id);
  }

  Future<BrandModel> createBrand(BrandModel brand, String? imagePath) async {
    return await brandRepository.createBrand(brand, imagePath);
  }

  Future<BrandModel> updateBrand(
    String id,
    BrandModel brand,
    String? imagePath,
  ) async {
    return await brandRepository.updateBrand(id, brand, imagePath);
  }

  Future<void> deleteBrand(String id) async {
    return await brandRepository.deleteBrand(id);
  }
}

import '../Repository/MotoRepository.dart';
import '../Repository/ApiResponse.dart';
import '../Models/MotoModel.dart';

class MotoService {
  late MotoRepository motoRepository;

  MotoService() {
    this.motoRepository = MotoRepository();
  }

  Future<ApiResponse<MotoModel>> getAllMotos() async {
    return await motoRepository.getAllMotos();
  }

  Future<MotoModel> getMotoById(String licensePlate) async {
    return await motoRepository.getMotoById(licensePlate);
  }

  Future<MotoModel> createMoto(MotoModel moto) async {
    return await motoRepository.createMoto(moto);
  }

  Future<MotoModel> updateMoto(String licensePlate, MotoModel moto) async {
    return await motoRepository.updateMoto(licensePlate, moto);
  }

  Future<void> deleteMoto(String licensePlate) async {
    return await motoRepository.deleteMoto(licensePlate);
  }
}


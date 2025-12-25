import '../Repository/AuthRepository.dart';
import '../Models/UserModel.dart';

class AuthService {
  late AuthRepository authRepository;

  AuthService() {
    this.authRepository = AuthRepository();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await authRepository.login(email, password);
  }

  Future<Map<String, dynamic>> register(UserModel user) async {
    return await authRepository.register(user);
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    return await authRepository.verifyCode(email, code);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await authRepository.forgotPassword(email);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return await authRepository.verifyOtp(email, otp);
  }

  Future<Map<String, dynamic>> resetPassword(
      String resetToken, String newPassword) async {
    return await authRepository.resetPassword(resetToken, newPassword);
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    return await authRepository.changePassword(oldPassword, newPassword);
  }
}


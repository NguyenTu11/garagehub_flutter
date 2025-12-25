import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/UserModel.dart';
import '../Repository/BaseResponse.dart';
import '../Utils.dart';

class AuthRepository extends BaseResponse {
  AuthRepository();

  Future<Map<String, dynamic>> login(String email, String password) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authLogin}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Login failed');
  }

  Future<Map<String, dynamic>> register(UserModel user) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authRegister}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Registration failed');
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authVerify}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': code}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    try {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Verification failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Verification failed');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authForgotPassword}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Forgot password failed');
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authVerifyOtp}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    try {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'OTP verification failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('OTP verification failed');
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String resetToken, String newPassword) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authResetPassword}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $resetToken',
      },
      body: json.encode({
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    try {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Reset password failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Reset password failed');
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    var response = await http.post(
      Uri.parse('${Utils.baseUrl}${Utils.authChangePassword}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Utils.token}',
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    }
    super.ErrorHandle(response.statusCode);
    throw Exception('Change password failed');
  }
}


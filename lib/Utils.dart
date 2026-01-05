import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Utils {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String userName = "";
  static String userEmail = "";
  static String userId = "";
  static String token = "";
  static int selectIndex = 0;
  static String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000/api/v1';
  }

  static String get backendBaseUrl {
    return dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:8000';
  }

  static String get cloudinaryCloudName {
    return dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'nguyentu11';
  }

  static String authLogin = '/auth/login';
  static String authRegister = '/auth/register';
  static String authVerify = '/auth/verify';
  static String authForgotPassword = '/auth/forgot-password';
  static String authVerifyOtp = '/auth/verify-otp';
  static String authResetPassword = '/auth/reset-password';
  static String authChangePassword = '/auth/change-password';
  static String authGetMe = '/auth/me';
  static String brandGetAll = '/brands';
  static String brandGetById = '/brands';
  static String brandCreate = '/brands';
  static String brandUpdate = '/brands';
  static String brandDelete = '/brands';
  static String partGetAll = '/parts';
  static String partGetById = '/parts';
  static String partCreate = '/parts';
  static String partUpdate = '/parts';
  static String partDelete = '/parts';
  static String partGetByBrand = '/parts';
  static String motoGetAll = '/motos';
  static String motoGetById = '/motos';
  static String motoCreate = '/motos';
  static String motoUpdate = '/motos';
  static String motoDelete = '/motos';
  static String orderGetAll = '/orders';
  static String orderGetById = '/orders';
  static String orderCreate = '/orders';
  static String orderUpdate = '/orders';
  static String orderGetByUser = '/orders/user';
  static String repairOrderGetAll = '/repair-orders';
  static String repairOrderGetById = '/repair-orders';
  static String repairOrderCreate = '/repair-orders';
  static String repairOrderUpdate = '/repair-orders';
  static String repairOrderDelete = '/repair-orders';
  static String statisticsGetAll = '/statistics';
  static String chatGetConversations = '/chat/conversations';
  static String chatGetMessages = '/chat/messages';
  static String geminiAsk = '/gemini/ask';
  static String getBackendImgURL(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return 'https://res.cloudinary.com/$cloudinaryCloudName/image/upload/$imagePath';
  }
}

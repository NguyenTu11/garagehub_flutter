import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Utils.dart';
import 'Screens/auth/LoginScreen.dart';
import 'Screens/auth/SignupScreen.dart';
import 'Screens/auth/VerifyCodeScreen.dart';
import 'Screens/auth/ForgotPasswordScreen.dart';
import 'Screens/auth/VerifyPasswordScreen.dart';
import 'Screens/auth/ChangePasswordScreen.dart';
import 'Screens/SplashScreen.dart';
import 'Screens/home/HomePage.dart';
import 'Screens/home/SearchScreen.dart';
import 'Screens/brands/BrandsScreen.dart';
import 'Screens/parts/PartsScreen.dart';
import 'Screens/cart/CartScreen.dart';
import 'Screens/cart/OrderHistoryScreen.dart';
import 'Screens/cart/OrderSuccessScreen.dart';
import 'Screens/chat/ChatPage.dart';
import 'Screens/appointments/BookAppointmentScreen.dart';
import 'Screens/appointments/SearchAppointmentScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Utils.navigatorKey,
      title: "GarageHub Mobile",
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => SignupScreen(),
        '/verify-email': (context) => VerifyCodeScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-password': (context) => VerifyPasswordScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/home': (context) => HomePage(),
        '/search': (context) => const SearchScreen(),
        '/brands': (context) => const BrandsScreen(),
        '/parts': (context) => const PartsScreen(),
        '/cart': (context) => const CartScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/order-success': (context) => const OrderSuccessScreen(),
        '/chat': (context) => const ChatPage(),
        '/book-appointment': (context) => const BookAppointmentScreen(),
        '/search-appointment': (context) => const SearchAppointmentScreen(),
      },
    );
  }
}

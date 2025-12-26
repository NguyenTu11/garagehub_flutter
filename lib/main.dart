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
      },
    );
  }
}

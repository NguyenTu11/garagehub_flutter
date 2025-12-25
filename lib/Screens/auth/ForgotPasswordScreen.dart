import 'package:flutter/material.dart';
import '../../Services/AuthService.dart';
import '../../Components/ButtonComponent.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordScreen();
  }
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  TextEditingController txtEmail = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  AuthService authService = AuthService();

  void _showMessage({String? error, String? success}) {
    setState(() {
      errorMessage = error;
      successMessage = success;
    });
    if (error != null || success != null) {
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            if (error != null && errorMessage == error) errorMessage = null;
            if (success != null && successMessage == success)
              successMessage = null;
          });
        }
      });
    }
  }

  void forgotPasswordClick() async {
    if (txtEmail.text.isEmpty) {
      _showMessage(error: "Vui lòng nhập email");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      var result = await authService.forgotPassword(txtEmail.text);
      _showMessage(success: result['message'] ?? "Đã gửi mã OTP đến email!");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          '/verify-password',
          arguments: {'email': txtEmail.text},
        );
      });
    } catch (e) {
      _showMessage(error: "Gửi mã OTP thất bại! Vui lòng thử lại.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = 140;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: Image.asset(
                        'Assets/Images/logo_garagehub.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image,
                          size: logoSize * 0.7,
                          color: Colors.blue.shade200,
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Quên mật khẩu",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                "Nhập email để nhận mã OTP đặt lại mật khẩu",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                controller: txtEmail,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.blue.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue.shade50.withOpacity(
                                    0.15,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 24),
                              isLoading
                                  ? CircularProgressIndicator()
                                  : ButtonComponent(
                                      double.infinity,
                                      50,
                                      "Gửi mã OTP",
                                      onTap: forgotPasswordClick,
                                    ),
                              SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                                child: Text(
                                  "Bạn đã nhớ mật khẩu? Đăng nhập",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            if (errorMessage != null && successMessage == null)
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (successMessage != null && errorMessage == null)
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            successMessage!,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

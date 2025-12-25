import 'package:flutter/material.dart';
import '../../Services/AuthService.dart';
import '../../Components/ButtonComponent.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordScreen();
  }
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  String resetToken = '';

  AuthService authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      resetToken = args['resetToken'] ?? '';
    }
  }

  void changePasswordClick() async {
    if (txtNewPassword.text.isEmpty || txtConfirmPassword.text.isEmpty) {
      setState(() {
        errorMessage = "Vui lòng nhập đầy đủ thông tin";
      });
      return;
    }

    if (txtNewPassword.text != txtConfirmPassword.text) {
      setState(() {
        errorMessage = "Mật khẩu xác nhận không khớp";
      });
      return;
    }

    if (txtNewPassword.text.length < 6) {
      setState(() {
        errorMessage = "Mật khẩu phải có ít nhất 6 ký tự";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      var result = await authService.resetPassword(
        resetToken,
        txtNewPassword.text,
      );
      setState(() {
        successMessage = result['message'] ?? "Đổi mật khẩu thành công!";
      });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
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
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 0,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(height: 12),
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
                                "Đổi mật khẩu",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Nhập mật khẩu mới của bạn",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                controller: txtNewPassword,
                                obscureText: !showPassword,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu mới',
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
                                    Icons.lock,
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
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue.shade300,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextFormField(
                                controller: txtConfirmPassword,
                                obscureText: !showConfirmPassword,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Xác nhận mật khẩu',
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
                                    Icons.lock_outline,
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
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue.shade300,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showConfirmPassword =
                                            !showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              isLoading
                                  ? CircularProgressIndicator()
                                  : ButtonComponent(
                                      double.infinity,
                                      50,
                                      "Đổi mật khẩu",
                                      onTap: changePasswordClick,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

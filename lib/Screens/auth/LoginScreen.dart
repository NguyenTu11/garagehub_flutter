import 'package:flutter/material.dart';
import '../../Utils.dart';
import '../../Services/AuthService.dart';
import '../../Components/ButtonComponent.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  String? featureMessage;
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  AuthService authService = AuthService();

  void _showMessage({String? error, String? success, String? feature}) {
    setState(() {
      errorMessage = error;
      successMessage = success;
      featureMessage = feature;
    });
    if (error != null || success != null || feature != null) {
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            if (error != null && errorMessage == error) errorMessage = null;
            if (success != null && successMessage == success)
              successMessage = null;
            if (feature != null && featureMessage == feature)
              featureMessage = null;
          });
        }
      });
    }
  }

  void loginClick() async {
    if (txtEmail.text.isEmpty || txtPassword.text.isEmpty) {
      _showMessage(error: "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      featureMessage = null;
    });

    try {
      var result = await authService.login(txtEmail.text, txtPassword.text);
      if (result['status'] == true || result['token'] != null) {
        Utils.token = result['token'] ?? '';
        Utils.userId =
            result['user']?['userId'] ?? result['user']?['_id'] ?? '';
        Utils.userName = result['user']?['fullName'] ?? '';
        _showMessage(success: result['message'] ?? "Đăng nhập thành công!");
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        _showMessage(error: result['message'] ?? "Đăng nhập thất bại!");
      }
    } catch (e) {
      _showMessage(error: "Đăng nhập thất bại! Vui lòng thử lại.");
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
                                "Đăng nhập",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                controller: txtEmail,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Nhập email của bạn',
                                  labelStyle: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.blueGrey.shade200,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade100,
                                    ),
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
                              SizedBox(height: 18),
                              TextFormField(
                                controller: txtPassword,
                                obscureText: !showPassword,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  hintText: 'Nhập mật khẩu',
                                  labelStyle: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.blueGrey.shade200,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade100,
                                    ),
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
                              SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/forgot-password',
                                    );
                                  },
                                  child: Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              isLoading
                                  ? CircularProgressIndicator()
                                  : ButtonComponent(
                                      double.infinity,
                                      50,
                                      "Đăng nhập",
                                      onTap: loginClick,
                                    ),
                              SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Hoặc',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  icon: Image.asset(
                                    'Assets/Images/google_icon.png',
                                    width: 28,
                                    height: 28,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.g_mobiledata,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                  ),
                                  label: Text('Đăng nhập với Google'),
                                  onPressed: () {
                                    _showMessage(
                                      feature: 'Tính năng đang phát triển',
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  icon: Image.asset(
                                    'Assets/Images/github_icon.png',
                                    width: 26,
                                    height: 26,
                                    color: Colors.white,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.code,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                  ),
                                  label: Text('Đăng nhập với GitHub'),
                                  onPressed: () {
                                    _showMessage(
                                      feature: 'Tính năng đang phát triển',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản? ",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (errorMessage != null &&
                successMessage == null &&
                featureMessage == null)
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
            if (successMessage != null &&
                errorMessage == null &&
                featureMessage == null)
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
            if (featureMessage != null &&
                errorMessage == null &&
                successMessage == null)
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
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
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            featureMessage!,
                            style: TextStyle(
                              color: Colors.orange.shade800,
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

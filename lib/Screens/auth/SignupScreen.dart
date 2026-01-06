import 'package:flutter/material.dart';
import '../../Services/AuthService.dart';
import '../../Models/UserModel.dart';
import '../../Components/ButtonComponent.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  int step = 1;
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtDateOfBirth = TextEditingController();
  TextEditingController txtPhoneNumber = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool showPassword = false;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        txtDateOfBirth.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void nextStep() {
    if (txtFullName.text.isEmpty ||
        txtDateOfBirth.text.isEmpty ||
        txtPhoneNumber.text.isEmpty) {
      _showMessage(error: "Vui lòng nhập đầy đủ thông tin");
      return;
    }
    setState(() {
      errorMessage = null;
      successMessage = null;
      step = 2;
    });
  }

  void signupClick() async {
    if (txtAddress.text.isEmpty ||
        txtEmail.text.isEmpty ||
        txtPassword.text.isEmpty) {
      _showMessage(error: "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      List<String> dobParts = txtDateOfBirth.text.split('/');
      String dobIso =
          "${dobParts[2]}-${dobParts[1].padLeft(2, '0')}-${dobParts[0].padLeft(2, '0')}";
      UserModel user = UserModel(
        fullName: txtFullName.text,
        dateOfBirth: DateTime.parse(dobIso),
        phoneNumber: txtPhoneNumber.text,
        address: txtAddress.text,
        email: txtEmail.text,
        password: txtPassword.text,
      );

      var result = await authService.register(user);
      setState(() {
        successMessage = result['message'] ?? "Đăng ký thành công!";
      });
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          '/verify-email',
          arguments: {'email': txtEmail.text},
        );
      });
    } catch (e) {
      _showMessage(error: "Đăng ký thất bại! Vui lòng thử lại.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double logoSize = isLandscape ? 80 : 140;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: isLandscape ? 8 : 16,
                ),
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
                    SizedBox(height: isLandscape ? 8 : 12),
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isLandscape ? 20 : 28,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 20 : 24,
                            vertical: isLandscape ? 20 : 32,
                          ),
                          child: step == 1
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Đăng ký",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    TextFormField(
                                      controller: txtFullName,
                                      style: TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Họ và tên',
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Colors.blue.shade400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 18),
                                    TextFormField(
                                      controller: txtDateOfBirth,
                                      readOnly: true,
                                      style: TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Ngày sinh',
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.calendar_today,
                                          color: Colors.blue.shade400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 16,
                                        ),
                                      ),
                                      onTap: () => _selectDate(context),
                                    ),
                                    SizedBox(height: 18),
                                    TextFormField(
                                      controller: txtPhoneNumber,
                                      style: TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Số điện thoại',
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Colors.blue.shade400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 16,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                    SizedBox(height: 24),
                                    ButtonComponent(
                                      double.infinity,
                                      50,
                                      "Tiếp tục",
                                      onTap: nextStep,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Đăng ký",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    TextFormField(
                                      controller: txtAddress,
                                      style: TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Địa chỉ',
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.location_on,
                                          color: Colors.blue.shade400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 18),
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
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
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
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
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
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
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
                                        fillColor: Colors.blue.shade50
                                            .withOpacity(0.15),
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
                                    SizedBox(height: 24),
                                    isLoading
                                        ? CircularProgressIndicator()
                                        : ButtonComponent(
                                            double.infinity,
                                            50,
                                            "Đăng ký",
                                            onTap: signupClick,
                                          ),
                                    SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          step = 1;
                                        });
                                      },
                                      child: Text(
                                        "Quay lại",
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
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Đã có tài khoản? ",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Đăng nhập",
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

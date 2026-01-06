import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/AuthService.dart';
import '../../Components/ButtonComponent.dart';

class VerifyPasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VerifyPasswordScreen();
}

class _VerifyPasswordScreen extends State<VerifyPasswordScreen> {
  List<FocusNode>? codeFocusNodes;
  List<TextEditingController>? codeControllers;
  TextEditingController txtOtp = TextEditingController();
  String email = '';
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  AuthService authService = AuthService();
  bool _showingMessage = false;

  @override
  void initState() {
    super.initState();
    codeFocusNodes = List.generate(6, (_) => FocusNode());
    codeControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    if (codeFocusNodes != null) {
      for (final node in codeFocusNodes!) {
        node.dispose();
      }
    }
    if (codeControllers != null) {
      for (final ctrl in codeControllers!) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      email = args['email'] ?? '';
    }
  }

  void _onCodeChanged(int idx, String value) {
    if (codeFocusNodes == null || codeControllers == null) return;
    if (value.length == 1 && idx < 5) {
      FocusScope.of(context).requestFocus(codeFocusNodes![idx + 1]);
    }
    if (value.isEmpty && idx > 0) {
      FocusScope.of(context).requestFocus(codeFocusNodes![idx - 1]);
    }
    txtOtp.text = codeControllers!.map((c) => c.text).join();
    setState(() {});
  }

  void _onPasteCode(String pasted) {
    if (codeControllers == null) return;
    final code = pasted.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      codeControllers![i].text = i < code.length ? code[i] : '';
    }
    txtOtp.text = codeControllers!.map((c) => c.text).join();
    setState(() {});
  }

  void _showMessage({String? error, String? success}) {
    if (_showingMessage) return;
    setState(() {
      errorMessage = error;
      successMessage = success;
      _showingMessage = true;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
          successMessage = null;
          _showingMessage = false;
        });
      }
    });
  }

  void verifyOtpClick() async {
    if (codeControllers == null) return;
    txtOtp.text = codeControllers!.map((c) => c.text).join();
    if (txtOtp.text.isEmpty) {
      _showMessage(error: "Vui lòng nhập mã OTP");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var result = await authService.verifyOtp(email, txtOtp.text);
      _showMessage(success: result['message'] ?? "Xác thực OTP thành công!");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          '/change-password',
          arguments: {'email': email, 'resetToken': result['resetToken']},
        );
      });
    } catch (e) {
      _showMessage(error: e.toString().replaceFirst('Exception: ', ''));
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
    final double logoSize = isLandscape ? 70 : 140;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: isLandscape ? 8 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 0),
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
                    SizedBox(height: isLandscape ? 4 : 8),
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Xác thực OTP",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Nhập mã OTP đã được gửi đến email:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 24),
                          GestureDetector(
                            onLongPress: () async {
                              final data = await Clipboard.getData(
                                'text/plain',
                              );
                              if (data != null && data.text != null) {
                                _onPasteCode(data.text!);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (i) {
                                final isFilled =
                                    codeControllers != null &&
                                    codeControllers!.length > i &&
                                    codeControllers![i].text.isNotEmpty;
                                final isFocused =
                                    codeFocusNodes != null &&
                                    codeFocusNodes!.length > i &&
                                    codeFocusNodes![i].hasFocus;
                                Color borderColor = isFocused
                                    ? Colors.blue.shade400
                                    : (isFilled
                                          ? Colors.blue.shade700
                                          : Colors.blue.shade100);
                                Color fillColor = isFilled
                                    ? Colors.blue.shade50.withOpacity(0.25)
                                    : Colors.transparent;
                                return Container(
                                  width: 44,
                                  height: 54,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child:
                                      codeControllers != null &&
                                          codeControllers!.length > i &&
                                          codeFocusNodes != null &&
                                          codeFocusNodes!.length > i
                                      ? TextField(
                                          controller: codeControllers![i],
                                          focusNode: codeFocusNodes![i],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          maxLength: 1,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onChanged: (v) =>
                                              _onCodeChanged(i, v),
                                          onTap: () => setState(() {}),
                                        )
                                      : SizedBox.shrink(),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 24),
                          isLoading
                              ? CircularProgressIndicator()
                              : ButtonComponent(
                                  double.infinity,
                                  50,
                                  "Xác thực",
                                  onTap: verifyOtpClick,
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 110),
                  ],
                ),
              ),
            ),
            if (errorMessage != null)
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
            if (successMessage != null)
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

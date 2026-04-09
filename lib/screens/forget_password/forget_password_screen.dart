import 'package:flutter/material.dart';
import 'package:movie_app/api/api_manager.dart';
import 'package:movie_app/core/styles/app_colors.dart';
import 'package:movie_app/core/styles/app_input_decoration.dart';
import 'package:movie_app/screens/register/language_provider.dart';

import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final ApiManager _apiManager = ApiManager();

  int _currentStep = 1;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPassword = TextEditingController();

  bool _oldObscured = true;
  bool _newObscured = true;
  bool _confirmObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPassword.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVerifyEmail(bool isArabic) {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar(isArabic
          ? "من فضلك ادخل البريد الإلكتروني"
          : "Please enter your email");
      return;
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      _showSnackBar(isArabic
          ? "البريد الإلكتروني غير صحيح"
          : "Please enter a valid email");
      return;
    }

    _showSnackBar(
      isArabic
          ? "تم إرسال رابط التحقق على بريدك"
          : "Verification sent to your email",
      isError: false,
    );
    setState(() => _currentStep = 2);
  }

  void _handleVerifyCode(bool isArabic) {
    setState(() => _currentStep = 3);
  }

  Future<void> _handleResetPassword(bool isArabic) async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNew = _confirmNewPassword.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmNew.isEmpty) {
      _showSnackBar(
          isArabic ? "من فضلك املأ جميع الحقول" : "Please fill all fields");
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar(isArabic
          ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
          : "Password must be at least 6 characters");
      return;
    }

    if (newPassword != confirmNew) {
      _showSnackBar(isArabic
          ? "كلمة المرور الجديدة وتأكيدها غير متطابقين"
          : "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiManager.resetPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      _showSnackBar(
        isArabic
            ? "تم تغيير كلمة المرور بنجاح"
            : "Password changed successfully",
        isError: false,
      );

      Navigator.pushReplacementNamed(context, 'login');
    } catch (e) {
      _showSnackBar(
          isArabic ? "حدث خطأ، حاول مرة أخرى" : "An error occurred, try again");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isArabic = langProvider.currentLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.appBarIcon),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          isArabic ? "نسيت كلمة المرور" : "Forget Password",
          style: const TextStyle(color: AppColors.appBarTitle),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildStepIndicator(),
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/Forgot password.png',
              width: 200,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.lock_reset,
                size: 120,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30),
            if (_currentStep == 1) _buildStep1(isArabic),
            if (_currentStep == 2) _buildStep2(isArabic),
            if (_currentStep == 3) _buildStep3(isArabic),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == _currentStep;
        final isDone = step < _currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 32 : 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isDone || isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : Text(
                        '$step',
                        style: TextStyle(
                          color:
                              isActive ? Colors.black : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (i < 2)
              Container(
                width: 40,
                height: 2,
                color:
                    step < _currentStep ? AppColors.primary : AppColors.surface,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStep1(bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic
              ? "أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين"
              : "Enter your email and we'll send you a reset link",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: AppColors.textPrimary),
          keyboardType: TextInputType.emailAddress,
          decoration: AppInputDecoration.field(
            hint: isArabic ? "البريد الإلكتروني" : "Email",
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: isArabic ? "تحقق من البريد" : "Verify Email",
          onPressed: () => _handleVerifyEmail(isArabic),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic
              ? "تم إرسال كود التحقق على بريدك الإلكتروني"
              : "Verification code sent to your email",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            letterSpacing: 8,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: AppInputDecoration.field(
            hint: "------",
            prefixIcon: Icons.pin_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: isArabic ? "تأكيد الكود" : "Verify Code",
          onPressed: () => _handleVerifyCode(isArabic),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _handleVerifyEmail(isArabic),
          child: Text(
            isArabic ? "إعادة إرسال الكود" : "Resend Code",
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic ? "أدخل كلمة المرور الجديدة" : "Enter your new password",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        _buildPasswordField(
          controller: _oldPasswordController,
          hint: isArabic ? "كلمة المرور الحالية" : "Current Password",
          isObscured: _oldObscured,
          onToggle: () => setState(() => _oldObscured = !_oldObscured),
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          controller: _newPasswordController,
          hint: isArabic ? "كلمة المرور الجديدة" : "New Password",
          isObscured: _newObscured,
          onToggle: () => setState(() => _newObscured = !_newObscured),
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          controller: _confirmNewPassword,
          hint: isArabic ? "تأكيد كلمة المرور الجديدة" : "Confirm New Password",
          isObscured: _confirmObscured,
          onToggle: () => setState(() => _confirmObscured = !_confirmObscured),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: isArabic ? "تغيير كلمة المرور" : "Reset Password",
          onPressed: () => _handleResetPassword(isArabic),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: AppInputDecoration.field(
        hint: hint,
        prefixIcon: Icons.lock_outline,
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: AppColors.iconSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}

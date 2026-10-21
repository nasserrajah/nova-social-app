import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/top_notification.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onSwitchToLogin});

  final VoidCallback? onSwitchToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notificationController = TopNotificationController();

  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _notificationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _notificationController.show(
        context,
        message: context.tr(
          'يجب الموافقة على الشروط والأحكام',
          'You must agree to the terms and conditions',
        ),
        isSuccess: false,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      RegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        isArabic: context.isArabic,
      ),
    );
  }

  void _handleSocialSignUp(String provider) {
    context.read<AuthBloc>().add(
      SocialLoginRequested(provider, isArabic: context.isArabic),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;

    if (widget.onSwitchToLogin != null) {
      widget.onSwitchToLogin!();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            _notificationController.show(
              context,
              message: isArabic
                  ? 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول'
                  : 'Account created successfully! Please login',
              isSuccess: true,
            );

            final authBloc = context.read<AuthBloc>();
            Future<void>.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              authBloc.add(const AuthMessageCleared());
              _navigateToLogin();
            });
          });
        } else if (state is AuthFailure) {
          _notificationController.show(
            context,
            message: state.message,
            isSuccess: false,
          );
          context.read<AuthBloc>().add(const AuthMessageCleared());
        }
      },
      child: Directionality(
        textDirection: context.appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.cardDark,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    isArabic ? 'إنشاء حساب' : 'CREATE ACCOUNT',
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'انضم إلينا وابدأ رحلتك'
                        : 'Join us and start your journey',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildForm(isArabic),
                  const SizedBox(height: 40),
                  Text(
                    isArabic ? 'أو سجل باستخدام' : 'Or sign up with',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _multiColorGoogleButton(
                        onTap: () => _handleSocialSignUp('google'),
                      ),
                      const SizedBox(width: 20),
                      _socialButton(
                        FontAwesomeIcons.facebookF,
                        Colors.blue,
                        () => _handleSocialSignUp('facebook'),
                      ),
                      const SizedBox(width: 20),
                      _socialButton(
                        FontAwesomeIcons.twitter,
                        Colors.lightBlueAccent,
                        () => _handleSocialSignUp('twitter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic
                            ? 'لديك حساب بالفعل؟ '
                            : 'Already have an account? ',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Text(
                          isArabic ? 'تسجيل الدخول' : 'LOGIN',
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              hintText: isArabic ? 'الاسم الكامل' : 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isArabic
                      ? 'يرجى إدخال الاسم الكامل'
                      : 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _emailController,
              hintText: isArabic ? 'البريد الإلكتروني' : 'Mail ID',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isArabic
                      ? 'يرجى إدخال البريد الإلكتروني'
                      : 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return isArabic ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _passwordController,
              hintText: isArabic ? 'كلمة المرور' : 'Password',
              icon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.amber,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isArabic
                      ? 'يرجى إدخال كلمة المرور'
                      : 'Please enter password';
                }
                if (value.length < 6) {
                  return isArabic
                      ? 'كلمة المرور قصيرة جدًا'
                      : 'Password too short';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() => _agreeToTerms = value ?? false);
                  },
                  activeColor: AppColors.amber,
                  checkColor: Colors.black,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showTermsDialog,
                    child: Text.rich(
                      TextSpan(
                        text: isArabic ? 'أوافق على ' : 'I agree to ',
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: isArabic
                                ? 'الشروط والأحكام'
                                : 'Terms & Conditions',
                            style: const TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isArabic ? 'إنشاء حساب' : 'CREATE ACCOUNT',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.amber),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.amber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardLight,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _multiColorGoogleButton({required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardLight,
        ),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF4285F4),
                Color(0xFFEA4335),
                Color(0xFFFBBC05),
                Color(0xFF34A853),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            FontAwesomeIcons.google,
            size: 26,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    final isArabic = context.isArabic;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        title: Text(
          isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
          style: const TextStyle(
            color: AppColors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            isArabic
                ? 'بإنشائك لهذا الحساب، فإنك توافق على:\n\n'
                      '1. الالتزام بسياسات الاستخدام\n'
                      '2. احترام خصوصية الآخرين\n'
                      '3. عدم نشر محتوى مخالف\n'
                      '4. الحفاظ على أمان الحساب\n\n'
                      'لمزيد من التفاصيل، تفضل بزيارة صفحة الشروط.'
                : 'By creating this account, you agree to:\n\n'
                      '1. Comply with usage policies\n'
                      '2. Respect others\' privacy\n'
                      '3. Not post inappropriate content\n'
                      '4. Maintain account security\n\n'
                      'For more details, please visit the terms page.',
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              isArabic ? 'فهمت' : 'I Understand',
              style: const TextStyle(color: AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

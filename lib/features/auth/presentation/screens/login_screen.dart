import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/top_notification.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSwitchToSignUp});

  final VoidCallback? onSwitchToSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notificationController = TopNotificationController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _rememberMeLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const RememberMeRequested());
      }
    });
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
        isArabic: context.isArabic,
      ),
    );
  }

  void _handleForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const ForgotPasswordDialog(),
      ),
    );
  }

  void _navigateToSignUp() {
    if (widget.onSwitchToSignUp != null) {
      widget.onSwitchToSignUp!();
    } else {
      Navigator.of(context).pushReplacementNamed('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/feed');
            }
          });
        } else if (state is AuthFailure) {
          _notificationController.show(
            context,
            message: state.message,
            isSuccess: false,
          );
          context.read<AuthBloc>().add(const AuthMessageCleared());
        } else if (state is AuthRememberMeLoaded) {
          if (!_rememberMeLoaded) {
            _emailController.text = state.email ?? '';
            _passwordController.text = state.password ?? '';
            _rememberMe = state.hasCredentials;
            _rememberMeLoaded = true;
          }
        }
      },
      child: Directionality(
        textDirection: context.appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.cardDark,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isArabic ? 'مرحباً بعودتك!' : 'Welcome Back!',
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLoginCard(isArabic),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: RichText(
                        text: TextSpan(
                          text: isArabic
                              ? 'ليس لديك حساب؟ '
                              : 'Don’t have an account? ',
                          style: const TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: isArabic ? 'إنشاء حساب' : 'Sign Up',
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
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
            Text(
              isArabic ? 'تسجيل الدخول' : 'LOGIN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 35),
            _buildTextField(
              controller: _emailController,
              hintText: isArabic ? 'البريد الإلكتروني' : 'Email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isArabic
                      ? 'يرجى إدخال البريد الإلكتروني'
                      : 'Please enter email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return isArabic ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
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
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        activeColor: AppColors.amber,
                      ),
                      Flexible(
                        child: Text(
                          isArabic ? 'تذكرني' : 'Remember me',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: Text(
                    isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
                            isArabic ? 'تسجيل الدخول' : 'Login',
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
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.amber),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.amber.withValues(alpha: 0.8)),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.amber, width: 1.5),
        ),
      ),
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _notificationController = TopNotificationController();

  @override
  void dispose() {
    _notificationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      ForgotPasswordRequested(
        _emailController.text.trim(),
        isArabic: context.isArabic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          context.read<AuthBloc>().add(const AuthMessageCleared());
          final navigator = Navigator.of(context);
          navigator.pop();

          showDialog<void>(
            context: navigator.context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.black87,
              title: const Text(
                'تم الإرسال بنجاح',
                style: TextStyle(color: Colors.greenAccent),
              ),
              content: const Text(
                'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'حسنًا',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ],
            ),
          );
        } else if (state is AuthFailure) {
          _notificationController.show(
            context,
            message: state.message,
            isSuccess: false,
          );
          context.read<AuthBloc>().add(const AuthMessageCleared());
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          isArabic ? 'استعادة كلمة المرور' : 'Reset Password',
          style: const TextStyle(color: Colors.yellow),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic
                    ? 'أدخل بريدك الإلكتروني لإرسال رابط الاستعادة'
                    : 'Enter your email to receive reset link',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.yellow),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic
                        ? 'يرجى إدخال البريد الإلكتروني'
                        : 'Please enter email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return isArabic
                        ? 'بريد إلكتروني غير صالح'
                        : 'Invalid email';
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(isArabic ? 'إرسال' : 'Send'),
              );
            },
          ),
        ],
      ),
    );
  }
}

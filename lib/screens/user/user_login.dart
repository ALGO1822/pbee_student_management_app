import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/providers/user_login_provider.dart';
import 'package:pbee_collate/util/validator.dart';
import 'package:pbee_collate/widget/custom_button.dart';
import 'package:pbee_collate/widget/custom_input.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Local state for password visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<UserLoginProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to your dashboard.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      CustomInput(
                        controller: emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validator.email,
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: passwordController,
                        hintText: 'Password',
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: Validator.password,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: GestureDetector(
                        child: Icon(
                          _isPasswordVisible
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Login',
                        isLoading: loginProvider.isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            loginProvider.handleLogin(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              context: context,
                            );
                          }
                        },
                        backgroundColor: Colors.purple,
                        icon: LucideIcons.logIn,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ambulance Driver',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  _buildErrorBanner(),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          controller.errorMessage.value,
          style: TextStyle(color: Colors.red.shade700),
        ),
      );
    });
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!GetUtils.isEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Obx(
          () => TextFormField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return Obx(
          () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Sign In',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


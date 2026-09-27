import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';

class AuthenticationController extends GetxController {
  final AuthService _authService;
  final StorageService _storage;

  AuthenticationController({
    required AuthService authService,
    required StorageService storage,
  })  : _authService = authService,
        _storage = storage;

  // ── Form ──────────────────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ── Observables ───────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  // ── Actions ───────────────────────────────────────────────────────────────

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    final request = LoginRequest(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final LoginResponse response = await _authService.login(request);

    if (response.success && response.token != null) {
      await _saveToken(response.token!, response.refreshToken);
      await _saveUserData(response.user);
      Get.offAllNamed(Routes.dashboard);
    } else {
      errorMessage.value =
          response.message ?? 'Login failed. Please try again.';
    }

    isLoading.value = false;
  }

  Future<void> logout() async {
    final token = await _storage.read('auth_token');
    if (token != null) {
      await _authService.logout(token);
    }
    await _storage.deleteAll();
    Get.offAllNamed(Routes.authentication);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _saveToken(String token, String? refreshToken) async {
    await _storage.write('auth_token', token);
    if (refreshToken != null) {
      await _storage.write('refresh_token', refreshToken);
    }
  }

  Future<void> _saveUserData(UserData? user) async {
    if (user == null) return;
    await _storage.write('user_data', jsonEncode(user.toJson()));
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}


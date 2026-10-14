import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';

class AuthenticationController extends GetxController {
  AuthenticationController({
    required AuthService authService,
    required StorageService storage,
  }) : _authService = authService,
       _storage = storage;

  final AuthService _authService;
  final StorageService _storage;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    restoreSession();
  }

  Future<void> restoreSession() async {
    final token = await _storage.read(StorageService.authTokenKey);
    if (token != null &&
        token.isNotEmpty &&
        Get.currentRoute == Routes.authentication) {
      Get.offAllNamed(Routes.dashboard);
    }
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _authService.login(
        LoginRequest(
          phoneNumber: phoneController.text.trim(),
          password: passwordController.text,
        ),
      );
      await _storage.write(StorageService.authTokenKey, response.accessToken);
      if (response.refreshToken?.isNotEmpty == true) {
        await _storage.write(
          StorageService.refreshTokenKey,
          response.refreshToken!,
        );
      }
      if (response.user != null) {
        await _storage.write(
          StorageService.userDataKey,
          jsonEncode(response.user!.toJson()),
        );
      }
      Get.offAllNamed(Routes.dashboard);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.logout();
    } catch (_) {
      // Local logout still succeeds if the server is unavailable.
    } finally {
      await _storage.clearSession();
      isLoading.value = false;
      Get.offAllNamed(Routes.authentication);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

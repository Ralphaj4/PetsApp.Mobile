import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsapp_mobile/presentation/auth/widgets/loading/paws_loading.dart';
import 'package:petsapp_mobile/core/theme/app_colors.dart';
import '../viewmodels/login_vm.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 40),
              child: Text(
                'Hello,\nWelcome Back!',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: const Text(
                  'Water is life. Water is a basic human need. In various lines of life, humans need water.',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (loginState.isLoading)
              const PawsLoading()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

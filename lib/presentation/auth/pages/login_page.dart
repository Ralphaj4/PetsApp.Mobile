import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsapp_mobile/presentation/auth/widgets/loading/paws_loading.dart';
import 'package:petsapp_mobile/core/theme/app_colors.dart';
import 'package:petsapp_mobile/core/providers/base_url_provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:petsapp_mobile/presentation/widgets/bottom_action_button.dart';
import 'package:petsapp_mobile/core/utils/validators.dart';
import '../viewmodels/login_vm.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerBaseUrl = TextEditingController();
  late Country selectedCountry;
  late FocusNode phoneFocusNode;
  bool _isPhoneFocused = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    selectedCountry = Country.parse('LB');
    phoneFocusNode = FocusNode();
    phoneFocusNode.addListener(_onPhoneFocusChange);
    controllerPhone.addListener(_validatePhone);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllerBaseUrl.text = ref.read(baseUrlProvider);
    });
  }

  void _onPhoneFocusChange() {
    setState(() {
      _isPhoneFocused = phoneFocusNode.hasFocus;
    });
  }

  void _validatePhone() {
    setState(() {
      final error = Validators.validatePhoneNumber(
        controllerPhone.text,
        selectedCountry.countryCode,
      );
      _isPhoneValid = error == null;
    });
  }

  void _handleLogin() {
    if (!_isPhoneValid) return;

    final mobileNumber = '+${selectedCountry.phoneCode}${controllerPhone.text}';

    ref.read(loginViewModelProvider.notifier).login(
          mobileNumber: mobileNumber,
          otp: '', // For now, sending empty OTP. You can add OTP field later
        );
  }

  void _saveBaseUrl() {
    final url = controllerBaseUrl.text.trim();
    if (url.isNotEmpty) {
      ref.read(baseUrlProvider.notifier).setBaseUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server URL saved'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    controllerPhone.dispose();
    controllerBaseUrl.dispose();
    phoneFocusNode.removeListener(_onPhoneFocusChange);
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    // Listen to error and success states
    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        // Clear error after showing
        ref.read(loginViewModelProvider.notifier).clearError();
      }

      if (next.authResponse != null && previous?.authResponse == null) {
        // Login successful, navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Top content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60.0,
                      left: 16.0,
                      right: 40,
                    ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          _isPhoneFocused = hasFocus;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isPhoneFocused
                                ? AppColors.primary
                                : AppColors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Country Picker Button
                            GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryListTheme: CountryListThemeData(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40),
                                    ),
                                    inputDecoration: InputDecoration(
                                      labelText: 'Search country',
                                      labelStyle: const TextStyle(
                                        color: AppColors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onSelect: (Country country) {
                                    setState(() {
                                      selectedCountry = country;
                                      _validatePhone();
                                    });
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 14.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedCountry.flagEmoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+${selectedCountry.phoneCode}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Divider
                            Container(
                              width: 1,
                              height: 24,
                              color: AppColors.primary.withAlpha(
                                (0.3 * 255).round(),
                              ),
                            ),
                            // Phone Number Field
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: TextField(
                                  controller: controllerPhone,
                                  focusNode: phoneFocusNode,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Phone number',
                                    hintStyle: TextStyle(color: AppColors.grey),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Base URL input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controllerBaseUrl,
                          decoration: InputDecoration(
                            labelText: 'Server URL',
                            hintText: 'http://192.168.0.1:5075',
                            hintStyle: const TextStyle(color: AppColors.grey),
                            labelStyle: const TextStyle(color: AppColors.grey),
                            prefixIcon: const Icon(Icons.dns_outlined, color: AppColors.grey),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.save_outlined, color: AppColors.primary),
                              onPressed: _saveBaseUrl,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.url,
                          onSubmitted: (_) => _saveBaseUrl(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Saved: ${ref.watch(baseUrlProvider)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (loginState.isLoading) ...[
                    const PawsLoading(),
                    const SizedBox(height: 12),
                    Text(
                      'Calling: ${ref.watch(baseUrlProvider)}/api/Auth/start',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 36.0,
            ),
            child: BottomActionButton(
              text: 'Login',
              onPressed: _isPhoneValid ? _handleLogin : null,
              enabled: _isPhoneValid,
            ),
          ),
        ],
      ),
    );
  }
}

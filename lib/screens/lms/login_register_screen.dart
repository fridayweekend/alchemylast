import 'package:flutter/material.dart';

import '../../shared/auth_prototype_store.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isIndividual = true;
  bool obscurePassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final learningAreaController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    countryController.dispose();
    learningAreaController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final role = isIndividual ? 'Learner' : 'Employer';
      final created = AuthPrototypeStore.instance.registerAccount(
        email: emailController.text,
        password: passwordController.text,
        role: role,
        displayName: nameController.text,
      );
      if (!created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this email already exists.'),
          ),
        );
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        role == 'Employer' ? '/employer' : '/dashboard',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MT Alchemy Learning')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8E5F0)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prototype account: available until this app restarts. Use demo details only.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Individual'),
                          icon: Icon(Icons.person_outline),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Employer'),
                          icon: Icon(Icons.business_outlined),
                        ),
                      ],
                      selected: {isIndividual},
                      onSelectionChanged: (selection) {
                        setState(() {
                          isIndividual = selection.first;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    if (isIndividual) ...[
                      _field(
                        controller: nameController,
                        label: 'Full Name',
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                      ),
                      _field(
                        controller: phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: countryController,
                        label: 'Country',
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: learningAreaController,
                        label: 'Preferred Learning Areas',
                        hint: 'e.g. Leadership, Communication',
                        validator: requiredValidator,
                      ),
                    ] else ...[
                      _field(
                        controller: nameController,
                        label: 'Organisation Name',
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: emailController,
                        label: 'Corporate Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                      ),
                      _field(
                        controller: phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: countryController,
                        label: 'Country',
                        validator: requiredValidator,
                      ),
                      _field(
                        controller: learningAreaController,
                        label: 'Industry',
                        validator: requiredValidator,
                      ),
                    ],

                    _field(
                      controller: passwordController,
                      label: 'Password',
                      obscureText: obscurePassword,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Use at least 8 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    _field(
                      controller: confirmPasswordController,
                      label: 'Confirm password',
                      obscureText: true,
                      validator: (value) => value != passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submitForm,
                        child: const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Already registered? Sign in'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hint,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

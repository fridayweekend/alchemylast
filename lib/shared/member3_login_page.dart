import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';
import 'auth_prototype_store.dart';

class Member3LoginPage extends StatefulWidget {
  const Member3LoginPage({
    super.key,
    this.redirectRoute,
    this.requiredRole,
    this.allowedRoles,
  });
  final String? redirectRoute;
  final String? requiredRole;
  final List<String>? allowedRoles;

  @override
  State<Member3LoginPage> createState() => _Member3LoginPageState();
}

class Member3AccessDeniedPage extends StatelessWidget {
  const Member3AccessDeniedPage({super.key, required this.requiredRole});
  final String requiredRole;

  @override
  Widget build(BuildContext context) => PageWidth(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: InfoCard(
        child: Column(
          children: [
            const Icon(
              Icons.admin_panel_settings_outlined,
              size: 54,
              color: deepBlue,
            ),
            const SizedBox(height: 18),
            Text(
              'Workspace access required',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'This page is for a $requiredRole account. Sign out and choose the correct demo account from Login.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                AuthPrototypeStore.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.switch_account_outlined),
              label: const Text('Switch account'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Member3LoginPageState extends State<Member3LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _homeFor(String role) => switch (role) {
    'Admin' => '/admin',
    'Employer' => '/employer',
    'Trainer' => '/trainer-dashboard',
    _ => '/dashboard',
  };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final role = AuthPrototypeStore.instance.signIn(
      _email.text,
      _password.text,
    );
    if (role == null) {
      setState(() => _error = 'Email or password is incorrect.');
      return;
    }
    if (widget.allowedRoles != null && !widget.allowedRoles!.contains(role)) {
      AuthPrototypeStore.instance.signOut();
      setState(
        () => _error = 'This page requires a ${widget.requiredRole} account.',
      );
      return;
    }
    final destination = widget.redirectRoute ?? _homeFor(role);
    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MT Alchemy'),
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
          child: const Text('Register'),
        ),
      ],
    ),
    body: SafeArea(
      child: PageWidth(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.sizeOf(context).height < 700 ? 20 : 56,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: InfoCard(
                padding: MediaQuery.sizeOf(context).width < 500 ? 22 : 36,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF0B9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_open,
                          color: deepBlue,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.requiredRole == null
                            ? 'Sign in to continue to your MT Alchemy workspace.'
                            : 'A ${widget.requiredRole} account is required to continue.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) =>
                            value == null ||
                                !RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value.trim())
                            ? 'Enter a valid email address'
                            : null,
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _hidePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.key_outlined),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter your password'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.login),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Learner, Trainer, Employer and Admin access use this same sign-in. Your account role controls which workspace opens.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Demo sign-in only. Replace this with Member 2’s authentication service before production.',
                        style: TextStyle(color: Colors.black54, height: 1.4),
                      ),
                      TextButton.icon(
                        onPressed: () => go(context, '/register'),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text(
                          'Create a Learner or Employer account',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => go(context, '/store'),
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Continue browsing the store'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

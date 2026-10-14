import 'package:flutter/material.dart';
import 'auth_prototype_store.dart';

String get accountDashboard => switch (AuthPrototypeStore.instance.role) {
  'Admin' => '/admin',
  'Employer' => '/employer',
  'Trainer' => '/trainer-dashboard',
  _ => '/dashboard',
};

class LearningNavigation extends StatelessWidget {
  const LearningNavigation({super.key});
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Account navigation',
    icon: const Icon(Icons.menu),
    onSelected: (route) {
      if (route == 'logout') {
        AuthPrototypeStore.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      } else {
        Navigator.pushNamed(context, route);
      }
    },
    itemBuilder: (_) => [
      const PopupMenuItem(value: '/', child: Text('Home')),
      const PopupMenuItem(value: '/hub', child: Text('Browse courses')),
      if (AuthPrototypeStore.instance.isSignedIn) ...[
        PopupMenuItem(
          value: accountDashboard,
          child: const Text('My dashboard'),
        ),
        const PopupMenuItem(value: '/dashboard', child: Text('My learning')),
        const PopupMenuItem(value: '/profile', child: Text('My profile')),
        const PopupMenuItem(value: 'logout', child: Text('Sign out')),
      ] else
        const PopupMenuItem(value: '/login', child: Text('Sign in')),
    ],
  );
}

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});
  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  late final name = TextEditingController(
    text: AuthPrototypeStore.instance.displayName,
  );
  String? message;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person_outline, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'My profile',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${AuthPrototypeStore.instance.role} · ${AuthPrototypeStore.instance.email}',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  setState(() => message = 'Enter your name.');
                  return;
                }
                final ok = await AuthPrototypeStore.instance.updateProfile(
                  name.text.trim(),
                );
                if (mounted) {
                  setState(
                    () => message = ok
                        ? 'Profile saved.'
                        : 'Could not save your profile.',
                  );
                }
              },
              child: const Text('Save profile'),
            ),
            if (message != null) Text(message!),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, accountDashboard),
              child: const Text('Go to my dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

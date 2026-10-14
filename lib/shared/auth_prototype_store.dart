import 'package:shared_preferences/shared_preferences.dart';
import '../commerce/commerce_prototype_store.dart';
import '../data/progress_store.dart';
import 'package:flutter/foundation.dart';

/// Temporary role session for the UI prototype. Replace this with Member 2's
/// authentication provider before merging the final application.
class AuthPrototypeStore extends ChangeNotifier {
  AuthPrototypeStore._();
  static final AuthPrototypeStore instance = AuthPrototypeStore._();

  static const _accounts =
      <String, ({String password, String role, String displayName})>{
        'admin@mtalchemy.demo': (
          password: 'AlchemyAdmin!26',
          role: 'Admin',
          displayName: 'MT Alchemy Admin',
        ),
        'employer@mtalchemy.demo': (
          password: 'AlchemyEmployer!26',
          role: 'Employer',
          displayName: 'ABC Sdn Bhd',
        ),
        'trainer@mtalchemy.demo': (
          password: 'AlchemyTrainer!26',
          role: 'Trainer',
          displayName: 'MT Alchemy Trainer',
        ),
        'learner@mtalchemy.demo': (
          password: 'AlchemyLearner!26',
          role: 'Learner',
          displayName: 'MT Alchemy Learner',
        ),
      };

  // Prototype-only accounts created in this running app. Production accounts
  // must be created and verified by the shared authentication backend.
  final Map<String, ({String password, String role, String displayName})>
  _registeredAccounts = {};

  String? _email;
  String? _role;
  String? _displayName;
  String? get email => _email;
  String? get role => _role;
  String? get displayName => _displayName;
  bool get isSignedIn => _email != null;

  String? signIn(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final account =
        _accounts[normalizedEmail] ?? _registeredAccounts[normalizedEmail];
    if (account == null || account.password != password) return null;
    _email = normalizedEmail;
    _role = account.role;
    _displayName = account.displayName;
    CommercePrototypeStore.instance.activeEmployer = _role == 'Employer'
        ? _email
        : null;
    selectLearner(_email);
    notifyListeners();
    return account.role;
  }

  bool registerAccount({
    required String email,
    required String password,
    required String role,
    required String displayName,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (!{'Learner', 'Employer'}.contains(role) ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail) ||
        password.length < 8 ||
        _accounts.containsKey(normalizedEmail) ||
        _registeredAccounts.containsKey(normalizedEmail)) {
      return false;
    }
    _registeredAccounts[normalizedEmail] = (
      password: password,
      role: role,
      displayName: displayName.trim(),
    );
    _email = normalizedEmail;
    _role = role;
    _displayName = displayName.trim();
    CommercePrototypeStore.instance.activeEmployer = _role == 'Employer'
        ? _email
        : null;
    selectLearner(_email);
    notifyListeners();
    return true;
  }

  Future<bool> updateProfile(String name) async {
    if (_email == null || name.trim().isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('profile_name_$_email', name.trim())) {
        return false;
      }
      _displayName = name.trim();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadProfile() async {
    final email = _email;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_email != email) return;
      _displayName = prefs.getString('profile_name_$email') ?? _displayName;
      notifyListeners();
    } catch (_) {
      /* Keep the account name if local storage is unavailable. */
    }
  }

  bool hasRole(String role) => _role == role;

  void signOut() {
    CommercePrototypeStore.instance.activeEmployer = null;
    selectLearner(null);
    _email = null;
    _role = null;
    _displayName = null;
    notifyListeners();
  }
}

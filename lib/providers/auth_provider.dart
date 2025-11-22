import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_home_ai/models/home_model.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? emailOrPhone;
  final String? ownerName;
  final String? assistantName;
  final Home? currentHome;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.emailOrPhone,
    this.ownerName,
    this.assistantName,
    this.currentHome,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? emailOrPhone,
    String? ownerName,
    String? assistantName,
    Home? currentHome,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      ownerName: ownerName ?? this.ownerName,
      assistantName: assistantName ?? this.assistantName,
      currentHome: currentHome ?? this.currentHome,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadUser();
    return AuthState();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      final userId = prefs.getString('userId');
      final emailOrPhone = prefs.getString('emailOrPhone');
      final ownerName = prefs.getString('ownerName');
      final assistantName = prefs.getString('assistantName');
      
      // Mock loading home
      final homeId = prefs.getString('homeId') ?? 'default_home';
      final home = Home(id: homeId, name: "My Home", ownerId: userId ?? 'user');

      state = AuthState(
        isAuthenticated: true,
        userId: userId,
        emailOrPhone: emailOrPhone,
        ownerName: ownerName,
        assistantName: assistantName,
        currentHome: home,
      );
    }
  }

  Future<void> loginWithEmail(String email) async {
    await _performMockLogin(email, 'email');
  }

  Future<void> loginWithGoogle() async {
    await _performMockLogin('user@gmail.com', 'google');
  }

  Future<void> loginWithPhone(String phone) async {
    await _performMockLogin(phone, 'phone');
  }

  Future<void> _performMockLogin(String identifier, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = const Uuid().v4(); // New User ID for every new login simulation
    final homeId = const Uuid().v4(); // New Home for this user

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('emailOrPhone', identifier);
    await prefs.setString('homeId', homeId);
    
    // Reset names for new user setup
    await prefs.remove('ownerName');
    await prefs.remove('assistantName');

    state = AuthState(
      isAuthenticated: true,
      userId: userId,
      emailOrPhone: identifier,
      currentHome: Home(id: homeId, name: "My Home", ownerId: userId),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState(isAuthenticated: false);
  }

  Future<void> saveProfile(String ownerName, String assistantName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ownerName', ownerName);
    await prefs.setString('assistantName', assistantName);
    
    state = state.copyWith(
      ownerName: ownerName,
      assistantName: assistantName,
    );
  }

  // Share Logic (Mock)
  Future<void> shareHome(String emailOrPhone) async {
    // In a real app, this would add the user to the Home's member list in Firestore
    print("Sharing home with $emailOrPhone");
    // We can simulate this by just showing a success message in the UI
  }
}

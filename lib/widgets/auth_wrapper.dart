import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

/// AuthWrapper watches auth state and returns either HomeScreen or LoginScreen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // If already authenticated via Provider (e.g., Demo mode or restored session)
    if (userProvider.uid != null) {
      return const HomeScreen();
    }

    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (userProvider.uid == null && snapshot.data!.uid.isNotEmpty) {
                userProvider.setUid(snapshot.data!.uid);
              }
            });
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      );
    } catch (_) {
      // Fallback for platforms/environments without active Firebase setup
      return const LoginScreen();
    }
  }
}

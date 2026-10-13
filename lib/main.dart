import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyPlaceholderWebApiKeyForDemo12345678',
          appId: '1:1234567890:web:abcdef123456',
          messagingSenderId: '1234567890',
          projectId: 'health-assistant-app',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init note: $e');
  }
  runApp(const HealthAssistantApp());
}

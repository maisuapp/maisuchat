import 'package:firebase_core/firebase_core.dart';

/// Runtime configuration for the Flutter Web Firebase app.
///
/// Values are supplied with `--dart-define` so local, staging and production
/// builds can use different Firebase projects without committing configuration
/// to the repository.
class FirebaseRuntimeConfig {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const measurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get options {
    if (!isConfigured) {
      throw StateError(
        'Firebase Web não está configurado. Passe os valores FIREBASE_* '
        'com --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }
}

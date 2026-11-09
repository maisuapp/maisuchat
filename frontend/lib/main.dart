import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'firebase_runtime_config.dart';
import 'sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await _initializeFirebase();
  runApp(MaisuChatApp(firebaseStatus: firebaseStatus));
}

class FirebaseStatus {
  const FirebaseStatus({
    required this.isReady,
    this.message,
  });

  final bool isReady;
  final String? message;
}

Future<FirebaseStatus> _initializeFirebase() async {
  if (!FirebaseRuntimeConfig.isConfigured) {
    return const FirebaseStatus(
      isReady: false,
      message:
          'Firebase não configurado neste build. Passe os valores FIREBASE_* com --dart-define.',
    );
  }

  try {
    await Firebase.initializeApp(options: FirebaseRuntimeConfig.options);
    return const FirebaseStatus(isReady: true);
  } on FirebaseException catch (error) {
    debugPrint('Firebase initialization failed: ${error.code}');
    return FirebaseStatus(
      isReady: false,
      message:
          'Firebase não pôde ser inicializado (${error.code}). O modo demonstração está disponível.',
    );
  } catch (error) {
    debugPrint('Firebase initialization failed: $error');
    return const FirebaseStatus(
      isReady: false,
      message:
          'Firebase não pôde ser inicializado. O modo demonstração está disponível.',
    );
  }
}

class MaisuChatApp extends StatefulWidget {
  const MaisuChatApp({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  State<MaisuChatApp> createState() => _MaisuChatAppState();
}

class _MaisuChatAppState extends State<MaisuChatApp> {
  bool _demoSignedIn = false;

  void _enterDemo() => setState(() => _demoSignedIn = true);

  void _exitDemo() => setState(() => _demoSignedIn = false);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'MaisuChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        fontFamily: 'Arial',
        visualDensity: VisualDensity.standard,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.secondaryContainer,
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      home: _home,
    );
  }

  Widget get _home {
    if (_demoSignedIn) {
      return DashboardPage(
        demoMode: true,
        onSignOut: _exitDemo,
      );
    }
    if (widget.firebaseStatus.isReady) {
      return AuthGate(onDemoContinue: _enterDemo);
    }
    return SignInPage(
      firebaseAvailable: false,
      setupMessage: widget.firebaseStatus.message,
      onDemoContinue: _enterDemo,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.onDemoContinue});

  final VoidCallback onDemoContinue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return SignInPage(
            firebaseAvailable: true,
            onDemoContinue: onDemoContinue,
          );
        }

        return DashboardPage(
          userEmail: user.email,
          onSignOut: () => FirebaseAuth.instance.signOut(),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 14),
            Text(
              'Carregando seu workspace…',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    required this.firebaseAvailable,
    required this.onDemoContinue,
    this.setupMessage,
  });

  final bool firebaseAvailable;
  final VoidCallback onDemoContinue;
  final String? setupMessage;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyAuthError(error))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        'E-mail ou senha inválidos.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      'user-disabled' => 'Esta conta foi desativada no Firebase.',
      'network-request-failed' =>
        'Sem conexão. Verifique a internet e tente novamente.',
      _ => 'Não foi possível entrar agora. Tente novamente.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final form = _SignInForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              isSubmitting: _isSubmitting,
              obscurePassword: _obscurePassword,
              firebaseAvailable: widget.firebaseAvailable,
              setupMessage: widget.setupMessage,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSignIn: _signIn,
              onDemoContinue: widget.onDemoContinue,
            );

            if (!isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: form,
                ),
              );
            }

            return Row(
              children: [
                Expanded(child: _BrandPanel(color: scheme.primary)),
                SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 52),
                    child: form,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LogoMark(compact: false),
          const SizedBox(height: 28),
          Text(
            'Converse com mais pessoas.\nAutomatize o que importa.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: -1.1,
                ),
          ),
          const SizedBox(height: 18),
          const SizedBox(
            width: 460,
            child: Text(
              'Organize seus canais, crie jornadas simples e acompanhe cada conversa em um só lugar.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const _BenefitRow(
            icon: Icons.auto_awesome_rounded,
            text: 'Automações que parecem humanas',
          ),
          const SizedBox(height: 12),
          const _BenefitRow(
            icon: Icons.forum_outlined,
            text: 'Inbox para o time inteiro',
          ),
          const SizedBox(height: 12),
          const _BenefitRow(
            icon: Icons.insights_outlined,
            text: 'Métricas claras para decidir melhor',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 19),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.obscurePassword,
    required this.firebaseAvailable,
    required this.onTogglePassword,
    required this.onSignIn,
    required this.onDemoContinue,
    this.setupMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final bool obscurePassword;
  final bool firebaseAvailable;
  final String? setupMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;
  final VoidCallback onDemoContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LogoMark(compact: true),
          const SizedBox(height: 28),
          Text(
            'Bem-vindo ao MaisuChat',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.7,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            firebaseAvailable
                ? 'Entre para continuar no seu workspace.'
                : 'Explore a interface com dados de demonstração.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (!firebaseAvailable) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: scheme.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      setupMessage ??
                          'Firebase não configurado neste build. O modo demonstração está disponível.',
                      style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDemoContinue,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Explorar demonstração'),
              ),
            ),
          ] else ...[
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@empresa.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe seu e-mail.';
                }
                if (!value.contains('@')) return 'Digite um e-mail válido.';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => onSignIn(),
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: onTogglePassword,
                  icon: Icon(obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe sua senha.';
                if (value.length < 6) return 'Use pelo menos 6 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : onSignIn,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar no workspace'),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: onDemoContinue,
              child: Text(
                firebaseAvailable
                    ? 'Continuar sem conta · modo demonstração'
                    : 'Continuar em modo demonstração',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Ao continuar, você concorda com os termos de uso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/mono_tag.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _show('Preencha todos os campos.');
      return;
    }
    if (password != _confirmController.text) {
      _show('As senhas não coincidem.');
      return;
    }
    if (password.length < 6) {
      _show('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'nome': name,
            'email': email,
            'criadoEm': FieldValue.serverTimestamp(),
            'atualizadoEm': FieldValue.serverTimestamp(),
          });
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'invalid-email' => 'Informe um e-mail válido.',
        'weak-password' => 'Escolha uma senha mais forte.',
        'network-request-failed' => 'Sem conexão. Verifique sua internet.',
        _ => 'Não foi possível criar a conta.',
      };
      if (mounted) _show(message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? AppColors.textPrimary : const Color(0xFF183B50);
    final secondary = dark ? AppColors.textMuted : const Color(0xFF638092);
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xFFF3F8FA),
      appBar: AppBar(
        title: Text(
          'CRIAR CONTA',
          style: monoStyle(fontSize: 12, color: primary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MonoTag('Novo cadastro'),
                    const SizedBox(height: 8),
                    Text(
                      'Criar minha conta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leva menos de um minuto.',
                      style: TextStyle(fontSize: 13, color: secondary),
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Nome completo',
                      hint: 'Seu nome',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'E-mail',
                      hint: 'seuemail@exemplo.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Senha',
                      hint: 'Crie uma senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Confirmar senha',
                      hint: 'Repita a senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      controller: _confirmController,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Cadastrar'),
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
}

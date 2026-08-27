import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/mono_tag.dart';
import '../widgets/status_badge.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? AppColors.textPrimary : const Color(0xFF183B50);
    final secondary = dark ? AppColors.textMuted : const Color(0xFF638092);
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xFFF3F8FA),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / marca
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emergencyRed.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOCORRO FÁCIL',
                            style: monoStyle(
                              fontSize: 13,
                              color: primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Perfil de saúde de emergência',
                            style: monoStyle(
                              fontSize: 9,
                              color: dark
                                  ? AppColors.accentCyan
                                  : AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Card de login
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const MonoTag('Autenticação'),
                            const StatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acessar minha conta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use suas credenciais para continuar.',
                          style: TextStyle(fontSize: 13, color: secondary),
                        ),

                        const SizedBox(height: 24),

                        const AppTextField(
                          label: 'E-mail',
                          hint: 'seuemail@exemplo.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Senha',
                          hint: 'Digite sua senha',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          trailing: Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: dark
                                  ? AppColors.accentCyan
                                  : AppColors.accentBlue,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            },
                            child: const Text('Entrar'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: dark
                                    ? AppColors.border
                                    : const Color(0xFFD7E5EB),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('ou', style: monoStyle(fontSize: 9)),
                            ),
                            Expanded(
                              child: Divider(
                                color: dark
                                    ? AppColors.border
                                    : const Color(0xFFD7E5EB),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Não tenho conta. Criar cadastro',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

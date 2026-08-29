import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import '../services/user_profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  String name = 'Usuário', email = '';
  String? photo;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        name = p.getString('nome')?.trim().isNotEmpty == true
            ? p.getString('nome')!
            : 'Usuário';
        email = p.getString('email') ?? '';
        photo = p.getString('profile_photo');
      });
  }

  Future<void> open(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    load();
  }

  @override
  Widget build(BuildContext c) {
    final dark = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xfff3f8fa),
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 27,
                backgroundImage: _image(photo),
                child: _image(photo) == null ? const Icon(Icons.person) : null,
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: email.isEmpty
                  ? const Text('Complete seu perfil')
                  : Text(email),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => open(const EditProfileScreen()),
            ),
          ),
          section('CONTA', [
            tile(
              Icons.person_outline,
              'Editar perfil',
              'Nome, foto e dados pessoais',
              () => open(const EditProfileScreen()),
            ),
            tile(
              Icons.password,
              'Alterar senha',
              'Atualize sua senha de acesso',
              () => open(const ChangePasswordScreen()),
            ),
            tile(
              Icons.security,
              'Segurança',
              'Biometria, PIN e duas etapas',
              () => open(const SecurityScreen()),
            ),
          ]),
          section('PREFERÊNCIAS', [
            tile(
              Icons.notifications_outlined,
              'Notificações',
              'Escolha os avisos recebidos',
              () => open(
                const ToggleScreen(
                  title: 'Notificações',
                  options: {
                    'notify_emergency': 'Alertas de emergência',
                    'notify_learning': 'Lembretes de aprendizado',
                    'notify_updates': 'Novidades do aplicativo',
                    'notify_security': 'Alertas de segurança',
                  },
                ),
              ),
            ),
            tile(
              Icons.palette_outlined,
              'Tema',
              'Claro, escuro ou automático',
              () => open(const ThemeScreen()),
            ),
            tile(
              Icons.language,
              'Idioma',
              'Idioma do aplicativo',
              () => open(const LanguageScreen()),
            ),
          ]),
          section('PRIVACIDADE', [
            tile(
              Icons.privacy_tip_outlined,
              'Privacidade',
              'Uso e exibição dos dados',
              () => open(
                const ToggleScreen(
                  title: 'Privacidade',
                  options: {
                    'privacy_profile': 'Exibir meu perfil de saúde',
                    'privacy_location': 'Usar localização em emergências',
                    'privacy_analytics': 'Compartilhar dados anônimos',
                    'privacy_personalization': 'Permitir personalização',
                  },
                ),
              ),
            ),
            tile(
              Icons.app_settings_alt,
              'Permissões',
              'Câmera, localização e mais',
              () => open(const PermissionsScreen()),
            ),
            tile(
              Icons.data_usage,
              'Uso de dados',
              'Rede e armazenamento',
              () => open(
                const ToggleScreen(
                  title: 'Uso de dados',
                  options: {
                    'data_wifi': 'Downloads apenas no Wi-Fi',
                    'data_saver': 'Economia de dados',
                    'data_cache': 'Conteúdo disponível offline',
                  },
                ),
              ),
            ),
          ]),
          section('AJUDA', [
            tile(
              Icons.help_outline,
              'Perguntas frequentes',
              'Respostas para dúvidas comuns',
              () => open(const FaqScreen()),
            ),
            tile(
              Icons.support_agent,
              'Falar com o suporte',
              'suporte@sops.app',
              () => open(const SupportScreen()),
            ),
            tile(
              Icons.bug_report_outlined,
              'Reportar problema',
              'Conte o que não funcionou',
              () => open(const SupportScreen(report: true)),
            ),
          ]),
          section('SESSÃO', [
            tile(
              Icons.logout,
              'Sair',
              'Encerrar a sessão atual',
              logout,
              danger: true,
            ),
            tile(
              Icons.delete_forever,
              'Excluir conta',
              'Remover conta e dados',
              deleteAccount,
              danger: true,
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  ImageProvider? _image(String? p) =>
      p != null && File(p).existsSync() ? FileImage(File(p)) : null;
  Widget section(String t, List<Widget> x) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: x),
        ),
      ],
    ),
  );
  Widget tile(
    IconData i,
    String t,
    String s,
    VoidCallback f, {
    bool danger = false,
  }) => ListTile(
    leading: Icon(i, color: danger ? AppColors.emergencyRed : null),
    title: Text(
      t,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: danger ? AppColors.emergencyRed : null,
      ),
    ),
    subtitle: Text(s),
    trailing: const Icon(Icons.chevron_right),
    onTap: f,
  );
  Future<void> logout() async {
    if (!await confirm('Sair da conta?', 'Você precisará entrar novamente.'))
      return;
    await UserProfileService.signOut();
  }

  Future<void> deleteAccount() async {
    final ctl = TextEditingController();
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('Excluir conta permanentemente?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Todos os dados deste dispositivo serão apagados. Esta ação não pode ser desfeita.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctl,
                  decoration: const InputDecoration(
                    labelText: 'Digite EXCLUIR',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  d,
                  ctl.text.trim().toUpperCase() == 'EXCLUIR',
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    ctl.dispose();
    if (!ok) return;
    await (await SharedPreferences.getInstance()).clear();
    await ThemeController.setMode(ThemeMode.light);
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> confirm(String a, String b) async =>
      await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(a),
          content: Text(b),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditState();
}

class _EditState extends State<EditProfileScreen> {
  final f = {
    for (final k in ['nome', 'email', 'telefone', 'nascimento', 'cidade'])
      k: TextEditingController(),
  };
  String? photo;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    for (final e in f.entries) e.value.text = p.getString(e.key) ?? '';
    if (mounted) setState(() => photo = p.getString('profile_photo'));
  }

  Future<void> pick() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );
    if (x != null && mounted) setState(() => photo = x.path);
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    for (final e in f.entries) await p.setString(e.key, e.value.text.trim());
    if (photo != null) await p.setString('profile_photo', photo!);
    if (mounted) {
      message(context, 'Perfil atualizado.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext c) => Page(
    title: 'Editar perfil',
    children: [
      Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: photo != null && File(photo!).existsSync()
                  ? FileImage(File(photo!))
                  : null,
              child: photo == null ? const Icon(Icons.person, size: 40) : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton.filled(
                onPressed: pick,
                icon: const Icon(Icons.camera_alt, size: 18),
              ),
            ),
          ],
        ),
      ),
      for (final x in [
        ('Nome completo', 'nome', Icons.person_outline),
        ('E-mail', 'email', Icons.email_outlined),
        ('Telefone', 'telefone', Icons.phone_outlined),
        ('Data de nascimento', 'nascimento', Icons.cake_outlined),
        ('Cidade', 'cidade', Icons.location_city),
      ])
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: TextField(
            controller: f[x.$2],
            decoration: InputDecoration(
              labelText: x.$1,
              prefixIcon: Icon(x.$3),
            ),
          ),
        ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: save,
        icon: const Icon(Icons.save),
        label: const Text('Salvar alterações'),
      ),
    ],
  );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _PasswordState();
}

class _PasswordState extends State<ChangePasswordScreen> {
  final old = TextEditingController(),
      next = TextEditingController(),
      again = TextEditingController();
  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    if (p.getString('password') != null &&
        p.getString('password') != old.text) {
      message(context, 'Senha atual incorreta.');
      return;
    }
    if (next.text.length < 8) {
      message(context, 'A senha deve ter pelo menos 8 caracteres.');
      return;
    }
    if (next.text != again.text) {
      message(context, 'As senhas não coincidem.');
      return;
    }
    await p.setString('password', next.text);
    if (mounted) {
      message(context, 'Senha alterada.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext c) => Page(
    title: 'Alterar senha',
    children: [
      const Text(
        'Use pelo menos 8 caracteres, combinando letras, números e símbolos.',
      ),
      for (final x in [
        ('Senha atual', old),
        ('Nova senha', next),
        ('Confirmar nova senha', again),
      ])
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: TextField(
            controller: x.$2,
            obscureText: true,
            decoration: InputDecoration(
              labelText: x.$1,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
        ),
      const SizedBox(height: 20),
      FilledButton(onPressed: save, child: const Text('Alterar senha')),
    ],
  );
}

class ToggleScreen extends StatefulWidget {
  const ToggleScreen({super.key, required this.title, required this.options});
  final String title;
  final Map<String, String> options;
  @override
  State<ToggleScreen> createState() => _ToggleState();
}

class _ToggleState extends State<ToggleScreen> {
  final values = <String, bool>{};
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        for (final k in widget.options.keys)
          values[k] =
              p.getBool(k) ?? k.contains('security') || k.contains('emergency');
      });
  }

  @override
  Widget build(BuildContext c) => Page(
    title: widget.title,
    children: [
      for (final e in widget.options.entries)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.value),
          value: values[e.key] ?? false,
          onChanged: (v) async {
            setState(() => values[e.key] = v);
            await (await SharedPreferences.getInstance()).setBool(e.key, v);
          },
        ),
    ],
  );
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<ThemeMode>(
    valueListenable: ThemeController.mode,
    builder: (c, v, _) => Page(
      title: 'Tema',
      children: [
        for (final x in [
          (ThemeMode.light, 'Claro', Icons.light_mode),
          (ThemeMode.dark, 'Escuro', Icons.dark_mode),
        ])
          RadioListTile<ThemeMode>(
            value: x.$1,
            groupValue: v,
            title: Text(x.$2),
            secondary: Icon(x.$3),
            onChanged: (n) {
              if (n != null) ThemeController.setMode(n);
            },
          ),
      ],
    ),
  );
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageState();
}

class _LanguageState extends State<LanguageScreen> {
  String v = 'pt_BR';
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => v = p.getString('language') ?? v);
    });
  }

  @override
  Widget build(BuildContext c) => Page(
    title: 'Idioma',
    children: [
      const Text('Escolha o idioma de preferência do aplicativo.'),
      for (final x in [
        ('pt_BR', 'Português (Brasil)'),
        ('en_US', 'English'),
        ('es_ES', 'Español'),
      ])
        RadioListTile<String>(
          value: x.$1,
          groupValue: v,
          title: Text(x.$2),
          onChanged: (n) async {
            if (n == null) return;
            setState(() => v = n);
            await (await SharedPreferences.getInstance()).setString(
              'language',
              n,
            );
          },
        ),
    ],
  );
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityState();
}

class _SecurityState extends State<SecurityScreen> {
  bool bio = false, two = false;
  final pin = TextEditingController();
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted)
        setState(() {
          bio = p.getBool('security_biometric') ?? false;
          two = p.getBool('security_2fa') ?? false;
        });
    });
  }

  Future<void> setBio(bool v) async {
    if (v) {
      try {
        if (!await LocalAuthentication().authenticate(
          localizedReason: 'Confirme sua identidade para ativar a biometria',
        ))
          return;
      } catch (_) {
        if (mounted) message(context, 'Biometria indisponível.');
        return;
      }
    }
    setState(() => bio = v);
    await (await SharedPreferences.getInstance()).setBool(
      'security_biometric',
      v,
    );
  }

  Future<void> savePin() async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin.text)) {
      message(context, 'Use um PIN de 4 a 6 números.');
      return;
    }
    await (await SharedPreferences.getInstance()).setString(
      'security_pin',
      pin.text,
    );
    pin.clear();
    if (mounted) message(context, 'PIN salvo.');
  }

  @override
  Widget build(BuildContext c) => Page(
    title: 'Segurança',
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Acesso com biometria'),
        value: bio,
        onChanged: setBio,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Autenticação em duas etapas'),
        subtitle: const Text('Exigir uma segunda verificação ao entrar'),
        value: two,
        onChanged: (v) async {
          setState(() => two = v);
          await (await SharedPreferences.getInstance()).setBool(
            'security_2fa',
            v,
          );
        },
      ),
      const Divider(),
      TextField(
        controller: pin,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(labelText: 'PIN de segurança'),
      ),
      FilledButton.tonal(onPressed: savePin, child: const Text('Definir PIN')),
    ],
  );
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});
  @override
  State<PermissionsScreen> createState() => _PermissionsState();
}

class _PermissionsState extends State<PermissionsScreen> {
  final ps = {
    'Câmera': Permission.camera,
    'Localização': Permission.location,
    'Microfone': Permission.microphone,
    'Contatos': Permission.contacts,
  };
  final st = <String, PermissionStatus>{};
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    for (final e in ps.entries) st[e.key] = await e.value.status;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext c) => Page(
    title: 'Permissões',
    children: [
      const Text('As permissões são solicitadas apenas quando necessárias.'),
      for (final e in ps.entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.key),
          subtitle: Text(
            st[e.key]?.isGranted == true ? 'Permitida' : 'Não permitida',
          ),
          trailing: OutlinedButton(
            onPressed: () async {
              final s = await e.value.request();
              if (s.isPermanentlyDenied) await openAppSettings();
              refresh();
            },
            child: Text(
              st[e.key]?.isGranted == true ? 'Gerenciar' : 'Permitir',
            ),
          ),
        ),
    ],
  );
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext c) => Page(
    title: 'Perguntas frequentes',
    children: [
      for (final x in [
        (
          'Como meus dados são usados?',
          'Eles compõem sua ficha de emergência e seguem os controles de privacidade.',
        ),
        (
          'O app funciona sem internet?',
          'Os dados já salvos permanecem disponíveis; recursos externos podem exigir conexão.',
        ),
        ('Como atualizar meus dados?', 'Use Configurações > Editar perfil.'),
      ])
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(x.$1),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(x.$2),
            ),
          ],
        ),
    ],
  );
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, this.report = false});
  final bool report;
  @override
  State<SupportScreen> createState() => _SupportState();
}

class _SupportState extends State<SupportScreen> {
  final text = TextEditingController();
  @override
  Widget build(BuildContext c) => Page(
    title: widget.report ? 'Reportar problema' : 'Falar com o suporte',
    children: [
      const Text(
        'Descreva sua solicitação. A mensagem ficará pronta para ser enviada a suporte@sops.app.',
      ),
      const SizedBox(height: 14),
      TextField(
        controller: text,
        minLines: 5,
        maxLines: 8,
        decoration: InputDecoration(
          labelText: widget.report
              ? 'O que aconteceu?'
              : 'Como podemos ajudar?',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () {
          if (text.text.trim().length < 10) {
            message(context, 'Inclua mais detalhes.');
            return;
          }
          message(context, 'Solicitação registrada para envio ao suporte.');
          text.clear();
        },
        icon: const Icon(Icons.send),
        label: const Text('Enviar'),
      ),
    ],
  );
}

class Page extends StatelessWidget {
  const Page({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext c) {
    final dark = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.bgDark : const Color(0xfff3f8fa),
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void message(BuildContext c, String s) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(s)));

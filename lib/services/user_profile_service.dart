import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  UserProfileService._();

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static DocumentReference<Map<String, dynamic>> _document(String uid) =>
      _firestore.collection('usuarios').doc(uid);

  static String _text(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static List<String> _contacts(Map<String, dynamic> data) {
    final value = data['contatosEmergencia'] ?? data['contatos_emergencia'];
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final single = _text(data, [
      'contatoEmergencia',
      'telefoneEmergencia',
      'contato',
    ]);
    return single.isEmpty ? <String>[] : <String>[single];
  }

  static Future<void> cacheProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = _contacts(data);
    final values = <String, String>{
      'nome': _text(data, ['nome', 'nomeCompleto', 'displayName']),
      'email': _text(data, ['email']),
      'telefone': _text(data, ['telefone', 'phone']),
      'nascimento': _text(data, ['nascimento', 'dataNascimento']),
      'cidade': _text(data, ['cidade']),
      'sangue': _text(data, ['sangue', 'tipoSanguineo']),
      'alergias': _text(data, ['alergias']),
      'medicamentos': _text(data, ['medicamentos']),
      'doencas': _text(data, ['doencas', 'condicoes']),
    };
    for (final entry in values.entries) {
      await prefs.setString(entry.key, entry.value);
    }
    await prefs.setStringList('contatos_emergencia', contacts);
    await prefs.setString('contato', contacts.join(' · '));
  }

  static Future<void> clearCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'nome',
      'email',
      'telefone',
      'nascimento',
      'cidade',
      'sangue',
      'alergias',
      'medicamentos',
      'doencas',
      'contatos_emergencia',
      'contato',
    ]) {
      await prefs.remove(key);
    }
  }

  static Future<void> signOut() async {
    await clearCachedProfile();
    await _auth.signOut();
  }

  static Future<void> syncCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final fallbackName = _authenticationName(user);
    final fallback = {'nome': fallbackName, 'email': user.email ?? ''};
    try {
      final snapshot = await _document(user.uid).get();
      final data = snapshot.data();
      if (data != null) {
        await cacheProfile({...fallback, ...data});
        return;
      }

      await _document(user.uid).set({
        'uid': user.uid,
        ...fallback,
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await cacheProfile(fallback);
    } on FirebaseException {
      // Uma falha de regra ou rede no Firestore não invalida uma sessão que
      // já foi autenticada. Mantém o acesso com os dados seguros do Auth e
      // tenta sincronizar novamente na próxima inicialização.
      await cacheProfile(fallback);
    }
  }

  static String _authenticationName(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final emailName = user.email?.split('@').first.trim() ?? '';
    if (emailName.isEmpty) return 'Usuário';
    final normalized = emailName.replaceAll(RegExp(r'[._-]+'), ' ');
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static Future<void> saveCurrentProfile({
    required String nome,
    required String sangue,
    required String alergias,
    required String medicamentos,
    required String doencas,
    required List<String> contatos,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Nenhum usuário autenticado.');
    final data = <String, dynamic>{
      'uid': user.uid,
      'nome': nome.trim(),
      'email': user.email ?? '',
      'sangue': sangue.trim(),
      'alergias': alergias.trim(),
      'medicamentos': medicamentos.trim(),
      'doencas': doencas.trim(),
      'contatosEmergencia': contatos,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
    await _document(user.uid).set(data, SetOptions(merge: true));
    await cacheProfile(data);
    if (nome.trim().isNotEmpty && user.displayName != nome.trim()) {
      await user.updateDisplayName(nome.trim());
    }
  }
}

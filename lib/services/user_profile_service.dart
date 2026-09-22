import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });
  final String name;
  final String phone;
  final String relationship;
  bool get isEmpty =>
      name.trim().isEmpty &&
      phone.trim().isEmpty &&
      relationship.trim().isEmpty;
  String get displayName {
    final details = [
      relationship.trim(),
      phone.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    return name.trim().isEmpty
        ? details
        : details.isEmpty
        ? name.trim()
        : '${name.trim()} ($details)';
  }

  Map<String, String> toMap() => {
    'nome': name.trim(),
    'telefone': phone.trim(),
    'parentesco': relationship.trim(),
  };
  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(
        name: (map['nome'] ?? map['name'] ?? '').toString(),
        phone: (map['telefone'] ?? map['phone'] ?? '').toString(),
        relationship: (map['parentesco'] ?? map['relationship'] ?? '')
            .toString(),
      );
}

class UserProfileService {
  UserProfileService._();
  static final profileVersion = ValueNotifier<int>(0);
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static DocumentReference<Map<String, dynamic>> _document(String uid) =>
      _firestore.collection('users').doc(uid);
  static String _text(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static List<EmergencyContact> _contacts(Map<String, dynamic> data) {
    final value = data['contatosEmergencia'] ?? data['contatos_emergencia'];
    if (value is List)
      return value
          .map(
            (item) => item is Map
                ? EmergencyContact.fromMap(Map<String, dynamic>.from(item))
                : EmergencyContact(
                    name: '',
                    phone: item.toString(),
                    relationship: '',
                  ),
          )
          .where((contact) => !contact.isEmpty)
          .toList();
    final single = _text(data, [
      'contatoEmergencia',
      'telefoneEmergencia',
      'contato',
    ]);
    return single.isEmpty
        ? []
        : [EmergencyContact(name: '', phone: single, relationship: '')];
  }

  static Future<List<EmergencyContact>> loadEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('contatos_emergencia_detalhados');
    if (saved != null)
      return saved
          .map((item) {
            try {
              return EmergencyContact.fromMap(
                Map<String, dynamic>.from(jsonDecode(item) as Map),
              );
            } catch (_) {
              return EmergencyContact(name: '', phone: item, relationship: '');
            }
          })
          .where((contact) => !contact.isEmpty)
          .toList();
    return (prefs.getStringList('contatos_emergencia') ?? const <String>[])
        .map(
          (phone) => EmergencyContact(name: '', phone: phone, relationship: ''),
        )
        .toList();
  }

  static Future<void> cacheProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = _contacts(data);
    final values = <String, String>{
      'nome': _text(data, ['nome', 'nomeCompleto', 'displayName']),
      'email': _text(data, ['email']),
      'telefone': _text(data, ['telefone', 'phone']),
      'nascimento': _text(data, [
        data.containsKey('dataNascimento') ? 'dataNascimento' : 'nascimento',
      ]),
      'cidade': _text(data, ['cidade']),
      'sangue': _text(data, ['sangue', 'tipoSanguineo']),
      'alergias': _text(data, ['alergias']),
      'medicamentos': _text(data, ['medicamentos']),
      'doencas': _text(
        data,
        data.containsKey('condicoesPreexistentes')
            ? ['condicoesPreexistentes']
            : ['doencas', 'condicoes'],
      ),
    };
    for (final entry in values.entries) {
      await prefs.setString(entry.key, entry.value);
    }
    await prefs.setStringList(
      'contatos_emergencia_detalhados',
      contacts.map((contact) => jsonEncode(contact.toMap())).toList(),
    );
    final display = contacts
        .map((contact) => contact.displayName)
        .where((value) => value.isNotEmpty)
        .toList();
    await prefs.setStringList('contatos_emergencia', display);
    await prefs.setString('contato', display.join(' / '));
    profileVersion.value++;
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
      'contatos_emergencia_detalhados',
      'contato',
      'profile_photo',
      'profile_photo_uid',
      'profile_uid',
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
    final fallback = {
      'nome': _authenticationName(user),
      'email': user.email ?? '',
    };
    String photo = user.photoURL?.trim() ?? '';
    for (final provider in user.providerData) {
      if (photo.isNotEmpty) break;
      photo = provider.photoURL?.trim() ?? '';
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('profile_uid') != user.uid) {
      await clearCachedProfile();
      await prefs.setString('profile_uid', user.uid);
    }
    if (prefs.getString('profile_photo_uid') != user.uid)
      await prefs.remove('profile_photo');
    await prefs.setString('profile_photo_uid', user.uid);
    Future<void> cachePhoto(Map<String, dynamic> data) async {
      final savedPhoto = _text(data, [
        'photoURL',
        'photoUrl',
        'fotoURL',
        'fotoUrl',
        'foto',
        'avatarUrl',
      ]);
      final remote = savedPhoto.isNotEmpty ? savedPhoto : photo;
      if (remote.isNotEmpty) await prefs.setString('profile_photo', remote);
    }

    await cachePhoto(const {});
    try {
      final snapshot = await _document(user.uid).get();
      final data = snapshot.data();
      if (data != null) {
        await cachePhoto(data);
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
      // Mantém o perfil local caso a sincronização esteja temporariamente
      // indisponível, em vez de substituí-lo por valores vazios.
    }
  }

  static String _authenticationName(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final emailName = user.email?.split('@').first.trim() ?? '';
    if (emailName.isEmpty) return 'Usuário';
    return emailName
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static Future<void> saveCurrentProfile({
    required String nome,
    required String email,
    required String telefone,
    required String nascimento,
    required String cidade,
    required String sangue,
    required String alergias,
    required String medicamentos,
    required String doencas,
    required List<EmergencyContact> contatos,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Nenhum usuário autenticado.');
    final data = <String, dynamic>{
      'uid': user.uid,
      'nome': nome.trim(),
      'email': email.trim(),
      'telefone': telefone.trim(),
      'dataNascimento': nascimento.trim(),
      'cidade': cidade.trim(),
      'sangue': sangue.trim(),
      'alergias': alergias.trim(),
      'medicamentos': medicamentos.trim(),
      'condicoesPreexistentes': doencas.trim(),
      'contatosEmergencia': contatos.map((contact) => contact.toMap()).toList(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
    await _document(user.uid).set(data, SetOptions(merge: true));
    await cacheProfile(data);
    if (nome.trim().isNotEmpty && user.displayName != nome.trim())
      await _updateAuthenticationName(user, nome);
  }

  static Future<void> removeEmergencyContact(EmergencyContact contact) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Nenhum usuário autenticado.');
    final document = _document(user.uid);
    final remaining = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final contacts = _contacts(snapshot.data() ?? {});
      final index = contacts.indexWhere(
        (item) => mapEquals(item.toMap(), contact.toMap()),
      );
      if (index >= 0) {
        contacts.removeAt(index);
        transaction.set(document, {
          'contatosEmergencia': contacts.map((item) => item.toMap()).toList(),
          'atualizadoEm': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return contacts;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'contatos_emergencia_detalhados',
      remaining.map((item) => jsonEncode(item.toMap())).toList(),
    );
    final display = remaining.map((item) => item.displayName).toList();
    await prefs.setStringList('contatos_emergencia', display);
    await prefs.setString('contato', display.join(' / '));
    profileVersion.value++;
  }

  static Future<void> _updateAuthenticationName(User user, String nome) async {
    try {
      await user.updateDisplayName(nome.trim());
    } on FirebaseAuthException {
      // Firestore already persisted the profile; Auth display name is secondary.
    }
  }

  static Future<void> saveBasicProfile({
    required String nome,
    required String email,
    required String telefone,
    required String nascimento,
    required String cidade,
    String? photo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Nenhum usuário autenticado.');

    final data = <String, dynamic>{
      'uid': user.uid,
      'nome': nome.trim(),
      'email': email.trim(),
      'telefone': telefone.trim(),
      'dataNascimento': nascimento.trim(),
      'cidade': cidade.trim(),
      if (photo != null && photo.trim().isNotEmpty) 'foto': photo.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
    await _document(user.uid).set(data, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    for (final entry in {
      'nome': nome.trim(),
      'email': email.trim(),
      'telefone': telefone.trim(),
      'nascimento': nascimento.trim(),
      'cidade': cidade.trim(),
    }.entries) {
      await prefs.setString(entry.key, entry.value);
    }
    if (photo != null && photo.trim().isNotEmpty) {
      await prefs.setString('profile_photo', photo.trim());
      await prefs.setString('profile_photo_uid', user.uid);
    }
    profileVersion.value++;
    if (nome.trim().isNotEmpty && user.displayName != nome.trim()) {
      await _updateAuthenticationName(user, nome);
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socorro_facil/services/user_profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Perfil existente em users fornece nascimento e condicoes ao cartao',
    () async {
      await UserProfileService.cacheProfile({
        'dataNascimento': '2000-08-15',
        'condicoesPreexistentes': 'Asma',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('nascimento'), '2000-08-15');
      expect(prefs.getString('doencas'), 'Asma');
      await UserProfileService.cacheProfile({
        'condicoesPreexistentes': '',
        'doencas': 'Asma',
      });
      expect(prefs.getString('doencas'), isEmpty);
    },
  );

  test('Sincronizacao publica perfil e contatos para o cartao', () async {
    final version = UserProfileService.profileVersion.value;
    await UserProfileService.cacheProfile({
      'nome': 'Ana',
      'tipoSanguineo': 'O+',
      'contatosEmergencia': [
        {'nome': 'Maria', 'telefone': '35999999999', 'parentesco': 'Mae'},
      ],
    });
    final contacts = await UserProfileService.loadEmergencyContacts();
    final prefs = await SharedPreferences.getInstance();
    expect(contacts.single.name, 'Maria');
    expect(contacts.single.phone, '35999999999');
    expect(contacts.single.relationship, 'Mae');
    expect(prefs.getString('contato'), contains('Maria'));
    expect(prefs.getString('sangue'), 'O+');
    expect(UserProfileService.profileVersion.value, version + 1);
  });

  test(
    'Remover contatos atualiza o cartao sem restaurar contato antigo',
    () async {
      await UserProfileService.cacheProfile({
        'contatosEmergencia': [],
        'contato': 'Contato antigo',
      });
      expect(await UserProfileService.loadEmergencyContacts(), isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('contato'), isEmpty);
    },
  );
}

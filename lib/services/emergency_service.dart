import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Encapsula o fluxo de emergência para que ele possa ser usado por várias
/// telas sem duplicar tratamento de permissão e de erro.
class EmergencyService {
  const EmergencyService();

  Future<String> requestEmergencyCall() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Ative a localização do aparelho e ligue para o SAMU pelo 192.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'Localização não autorizada. Ligue para o SAMU pelo 192.';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'A localização foi bloqueada nas configurações. Ligue para o SAMU pelo 192.';
    }

    try {
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on LocationServiceDisabledException {
      return 'Ative a localização do aparelho e ligue para o SAMU pelo 192.';
    } catch (_) {
      return 'Não foi possível obter sua localização. Ligue para o SAMU pelo 192.';
    }

    final opened = await launchUrl(Uri(scheme: 'tel', path: '192'));
    return opened
        ? 'Localização obtida. Abrindo ligação para o SAMU.'
        : 'Localização obtida. Ligue para o SAMU pelo 192.';
  }
}

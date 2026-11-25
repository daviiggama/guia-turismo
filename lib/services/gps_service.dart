import 'package:geolocator/geolocator.dart';

class GpsService {
  /// Retorna a posição atual ou null se o GPS estiver desligado
  /// ou o usuário negar a permissão.
  Future<Position?> posicaoAtual() async {
    final gpsLigado = await Geolocator.isLocationServiceEnabled();
    if (!gpsLigado) return null;

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }
}

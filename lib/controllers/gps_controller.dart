import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guia/services/gps_service.dart';

class GpsController extends ChangeNotifier {
  Position? posicao;
  String erro = '';

  Future<void> atualizarPosicao() async {
    try {
      posicao = await GpsService().posicaoAtual();
      erro = posicao == null ? 'Localização indisponível' : '';
    } catch (e) {
      erro = 'Erro ao obter a localização';
    }
    notifyListeners();
  }

  /// Distância em texto até um ponto (ex: "850 m" ou "12,3 km").
  /// Retorna null se ainda não temos a posição do usuário.
  String? distanciaAte(double latitude, double longitude) {
    if (posicao == null) return null;
    final metros = Geolocator.distanceBetween(
      posicao!.latitude,
      posicao!.longitude,
      latitude,
      longitude,
    );
    if (metros < 1000) return '${metros.round()} m';
    return '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}

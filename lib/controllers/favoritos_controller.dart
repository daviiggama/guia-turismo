import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// guarda no aparelho os ids dos lugares favoritados
class FavoritosController extends ChangeNotifier {
  final Set<int> _ids = {};

  FavoritosController() {
    _carregar();
  }

  bool ehFavorito(int id) => _ids.contains(id);

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList('favoritos') ?? [];
    _ids.addAll(salvos.map(int.parse));
    notifyListeners();
  }

  Future<void> alternar(int id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favoritos', _ids.map((i) => i.toString()).toList());
  }
}

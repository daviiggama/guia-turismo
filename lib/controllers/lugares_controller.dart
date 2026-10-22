import 'package:flutter/material.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/categorias_service.dart';
import 'package:guia/services/lugares_services.dart';
import 'package:guia/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;
  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> get categorias => _categorias;

  //inicializar
  LugaresController() {
    listarLugares();
  }

  Future<void> listarLugares() async {
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      final lugaresService = LugaresServices();
      final listaLugares = await lugaresService.buscarLugares();
      _lugares = listaLugares;
    } catch (error) {
      erro = "Erro ao listar: $error";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarCategorias() async {
    try {
      _categorias = await CategoriasService().buscarCategorias();
    } catch (e) {
      erro = "Erro ao carregar categorias: $e";
    }
    notifyListeners();
  }

  /// Devolve null em caso de sucesso, ou a mensagem de erro.
  Future<String?> cadastrarLugar(LugaresModel dados) async {
    final token = await SessionService().pegarToken() ?? '';
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      await LugaresServices().cadastrarLugar(dados, token);
      await listarLugares();
      return null;
    } catch (e) {
      carregando = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

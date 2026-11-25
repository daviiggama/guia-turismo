import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/models/localizacao_model.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/categorias_service.dart';
import 'package:guia/services/localizacao_service.dart';
import 'package:guia/services/lugares_services.dart';
import 'package:guia/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  String aviso = ""; // mensagem quando o lugar foi salvo mas a foto falhou
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

  /// Devolve a localização ou null se o endereço não for encontrado.
  Future<LocalizacaoModel?> buscarLocalizacao(String texto) {
    return LocalizacaoService().buscarLocalizacao(texto);
  }

  /// Devolve null em caso de sucesso, ou a mensagem de erro.
  Future<String?> cadastrarLugar(LugaresModel dados, {File? foto}) async {
    final token = await SessionService().pegarToken() ?? '';
    carregando = true;
    erro = "";
    aviso = "";
    notifyListeners();
    try {
      final service = LugaresServices();
      int? id = await service.cadastrarLugar(dados, token);

      if (foto != null) {
        // se a API não devolveu o id, procura o lugar recém criado na lista
        if (id == null) {
          final lista = await service.buscarLugares();
          id = lista.firstWhere((l) => l.nome == dados.nome).id;
        }
        try {
          await service.enviarFoto(id, foto, token);
        } catch (e) {
          aviso = 'Lugar cadastrado, mas a foto não foi enviada.';
        }
      }
      await listarLugares();
      return null;
    } catch (e) {
      carregando = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

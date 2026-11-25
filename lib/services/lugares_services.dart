import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class LugaresServices {
  String url = 'https://guia.liliaborges.com.br/lugares';
  int pagina = 1;
  int limite = 200; // traz todos, o mapa precisa de todos os pontos

  Future<List<LugaresModel>> buscarLugares() async {
    try {
      final response = await http.get(
        Uri.parse('$url?pagina=$pagina&limite=$limite'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        final lugares = <LugaresModel>[];
        for (final item in data) {
          try {
            lugares.add(LugaresModel.fromJson(item));
          } catch (e) {
            // ignora um registro com dados inválidos em vez de quebrar a lista
            debugPrint('Lugar ignorado: $e');
          }
        }
        return lugares;
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cadastra o lugar. Retorna o id criado (ou null se a API não devolver).
  /// Lança exceção se o cadastro falhar.
  Future<int?> cadastrarLugar(LugaresModel dados, String token) async {
    if (token.isEmpty) {
      throw Exception('Não autorizado! Faça login novamente.');
    }
    final resposta = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dados.toJson()),
    );
    final Map<String, dynamic> corpo = jsonDecode(resposta.body);
    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final data = corpo['data'];
      return data is Map ? data['id'] : null;
    }
    if (resposta.statusCode == 401 || resposta.statusCode == 403) {
      throw Exception('Sessão expirada. Saia e faça login novamente.');
    }
    throw Exception(corpo['message'] ?? 'Erro ${resposta.statusCode}');
  }

  /// Envia a foto para a galeria do lugar (multipart, campo "foto").
  Future<void> enviarFoto(int lugarId, File foto, String token) async {
    final requisicao =
        http.MultipartRequest('POST', Uri.parse('$url/$lugarId/galeria'));
    requisicao.headers['Authorization'] = 'Bearer $token';
    requisicao.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final resposta = await http.Response.fromStream(await requisicao.send());
    if (resposta.statusCode != 201 && resposta.statusCode != 200) {
      throw Exception('Erro ao enviar a foto (${resposta.statusCode})');
    }
  }
}

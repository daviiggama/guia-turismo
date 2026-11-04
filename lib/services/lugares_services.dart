import 'dart:convert';
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
        return data.map((item) => LugaresModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna a mensagem da API. Lança exceção se o cadastro falhar.
  Future<String> cadastrarLugar(LugaresModel dados, String token) async {
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
      return corpo['message'] ?? 'Lugar cadastrado com sucesso!';
    }
    if (resposta.statusCode == 401 || resposta.statusCode == 403) {
      throw Exception('Sessão expirada. Saia e faça login novamente.');
    }
    throw Exception(corpo['message'] ?? 'Erro ${resposta.statusCode}');
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String url = 'https://guia.liliaborges.com.br/login';

  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      );
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return dados['data'];
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Depois do login com Google, entra na API com o mesmo e-mail.
  /// Se a conta ainda não existir na API, cria e entra em seguida.
  Future<Map> autenticarComGoogle(
      String nome, String email, String idGoogle) async {
    final senha = 'google-$idGoogle';
    Map dados = await autenticar(email, senha);
    if (dados['token'] == null) {
      await http.post(
        Uri.parse('https://guia.liliaborges.com.br/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
      );
      dados = await autenticar(email, senha);
    }
    return dados;
  }
}

import 'dart:convert';
import 'package:guia/models/localizacao_model.dart';
import 'package:http/http.dart' as http;

class LocalizacaoService {
  // o Nominatim exige que o app se identifique no header
  final Map<String, String> _headers = {'User-Agent': 'GuiaTurismoApp'};

  /// Aceita um endereço ou um CEP. Retorna null se não encontrar.
  Future<LocalizacaoModel?> buscarLocalizacao(String texto) async {
    String busca = texto.trim();

    // se for CEP, descobre o endereço no ViaCEP antes
    final apenasNumeros = busca.replaceAll(RegExp(r'\D'), '');
    if (apenasNumeros.length == 8) {
      final enderecoCep = await _buscarCep(apenasNumeros);
      if (enderecoCep == null) return null;
      busca = enderecoCep;
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': busca,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'br',
    });
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar o endereço (${response.statusCode})');
    }
    final List<dynamic> resultados = jsonDecode(response.body);
    if (resultados.isEmpty) return null;
    return LocalizacaoModel.fromJson(resultados.first);
  }

  Future<String?> _buscarCep(String cep) async {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode != 200) return null;
    final dados = jsonDecode(response.body);
    if (dados['erro'] == true) return null;
    final partes = [
      dados['logradouro'],
      dados['bairro'],
      dados['localidade'],
      dados['uf'],
    ];
    return partes.where((p) => p != null && p != '').join(', ');
  }
}

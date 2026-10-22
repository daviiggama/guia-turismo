import 'dart:convert';
import 'package:guia/models/categoria_model.dart';
import 'package:http/http.dart' as http;

class CategoriasService {
  final String url = 'https://guia.liliaborges.com.br/categorias';

  Future<List<CategoriaModel>> buscarCategorias() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => CategoriaModel.fromJson(item)).toList();
    }
    throw Exception('Erro ao buscar categorias: ${response.body}');
  }
}

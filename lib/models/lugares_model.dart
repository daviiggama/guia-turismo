class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String descricao;
  final int categoriaId;
  final List<String> fotos;

  LugaresModel({
    this.id = 0,
    required this.nome,
    this.categoria,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.descricao = '',
    this.fotos = const [],
  });

  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      categoria: json['categoria']?['nome'],
      categoriaId: json['categoriaId'] ?? 0,
      // a API pode devolver inteiro (ex: 0) ou vazio, então converte via num
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      descricao: json['descricao'] ?? '',
      // a galeria vem como lista de { id, urlFoto, lugarId }
      fotos: (json['galeria'] as List? ?? [])
          .map((foto) => foto['urlFoto'].toString())
          .toList(),
    );
  }

  // corpo esperado pelo POST /lugares
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'categoriaId': categoriaId,
    };
  }
}

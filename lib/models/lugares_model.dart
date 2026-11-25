class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  // num porque a API pode mandar inteiro (ex: 0) ou decimal
  final num latitude;
  final num longitude;
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
      latitude: json['latitude'] ?? 0,
      longitude: json['longitude'] ?? 0,
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

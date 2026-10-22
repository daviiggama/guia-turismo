class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String descricao;
  final int categoriaId;

  LugaresModel({
    this.id = 0,
    required this.nome,
    this.categoria,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.descricao = '',
  });

  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      categoria: json['categoria']?['nome'],
      categoriaId: json['categoriaId'],
      // a API pode devolver inteiro (ex: 0), então converte via num
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      descricao: json['descricao'] ?? '',
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

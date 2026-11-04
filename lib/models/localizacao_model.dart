class LocalizacaoModel {
  final double latitude;
  final double longitude;
  final String endereco;

  LocalizacaoModel({
    required this.latitude,
    required this.longitude,
    required this.endereco,
  });

  // o Nominatim devolve lat/lon como texto
  factory LocalizacaoModel.fromJson(Map<String, dynamic> json) {
    return LocalizacaoModel(
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      endereco: json['display_name'] ?? '',
    );
  }
}

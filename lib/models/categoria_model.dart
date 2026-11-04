import 'package:flutter/material.dart';

class CategoriaModel {
  final int id;
  final String nome;

  CategoriaModel({required this.id, required this.nome});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(id: json['id'], nome: json['nome']);
  }
}

// ícone de cada categoria (usado na lista e no mapa)
IconData iconeDaCategoria(String? categoria) {
  switch (categoria) {
    case 'Praias':
      return Icons.beach_access;
    case 'Ilhas':
      return Icons.landscape;
    case 'Gastronomia':
      return Icons.restaurant;
    case 'Dicas':
      return Icons.lightbulb;
    case 'Points':
      return Icons.account_balance;
    default:
      return Icons.place;
  }
}

import 'package:flutter/material.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/models/lugares_model.dart';

/// Foto redonda do lugar. Se não tiver foto (ou falhar ao carregar),
/// mostra o ícone da categoria.
class FotoLugar extends StatelessWidget {
  final LugaresModel lugar;
  final double tamanho;

  const FotoLugar({super.key, required this.lugar, this.tamanho = 44});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final icone = Container(
      width: tamanho,
      height: tamanho,
      color: cores.primaryContainer,
      child: Icon(
        iconeDaCategoria(lugar.categoria),
        size: tamanho * 0.5,
        color: cores.onPrimaryContainer,
      ),
    );

    return ClipOval(
      child: lugar.fotos.isEmpty
          ? icone
          : Image.network(
              lugar.fotos.first,
              width: tamanho,
              height: tamanho,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => icone,
            ),
    );
  }
}

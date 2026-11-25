import 'package:flutter/material.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/gps_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/widgets/foto_lugar.dart';
import 'package:guia/widgets/lugar_detalhes.dart';
import 'package:provider/provider.dart';

class LugarCard extends StatelessWidget {
  final LugaresModel lugar;

  const LugarCard({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final favoritos = context.watch<FavoritosController>();
    final distancia = context
        .watch<GpsController>()
        .distanciaAte(lugar.latitude, lugar.longitude);
    final categoria = lugar.categoria ?? 'Sem categoria';

    return Card(
      elevation: 0,
      color: cores.surfaceContainerHighest.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () => mostrarDetalhesLugar(context, lugar),
        leading: FotoLugar(lugar: lugar),
        title: Text(
          lugar.nome.isEmpty ? '(sem nome)' : lugar.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            Text(distancia == null ? categoria : '$categoria · $distancia'),
        trailing: IconButton(
          tooltip: 'Favoritar',
          onPressed: () => favoritos.alternar(lugar.id),
          icon: Icon(
            favoritos.ehFavorito(lugar.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: favoritos.ehFavorito(lugar.id) ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/gps_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/widgets/foto_lugar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Painel que sobe de baixo com os dados do lugar.
/// Usado na lista e no mapa.
void mostrarDetalhesLugar(BuildContext context, LugaresModel lugar) {
  showModalBottomSheet(
    context: context,
    builder: (_) => _DetalhesLugar(lugar: lugar),
  );
}

class _DetalhesLugar extends StatelessWidget {
  final LugaresModel lugar;

  const _DetalhesLugar({required this.lugar});

  // abre o Google Maps (ou outro app de mapas) com a rota até o lugar
  Future<void> _comoChegar(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${lugar.latitude},${lugar.longitude}',
    );
    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosController>();
    final distancia = context
        .watch<GpsController>()
        .distanciaAte(lugar.latitude, lugar.longitude);
    final favorito = favoritos.ehFavorito(lugar.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FotoLugar(lugar: lugar, tamanho: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lugar.nome,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(lugar.categoria ?? 'Sem categoria'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Favoritar',
                onPressed: () => favoritos.alternar(lugar.id),
                icon: Icon(
                  favorito ? Icons.favorite : Icons.favorite_border,
                  color: favorito ? Colors.red : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(lugar.descricao.isEmpty ? 'Sem descrição' : lugar.descricao),
          if (distancia != null) ...[
            const SizedBox(height: 8),
            Text('A $distancia de você'),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _comoChegar(context),
              icon: const Icon(Icons.directions),
              label: const Text('Como chegar'),
            ),
          ),
        ],
      ),
    );
  }
}

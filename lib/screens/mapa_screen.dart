import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  // ignora lugares com coordenadas vazias (0,0) ou fora do limite
  bool _temCoordenadaValida(LugaresModel lugar) {
    if (lugar.latitude == 0 && lugar.longitude == 0) return false;
    return lugar.latitude.abs() <= 90 && lugar.longitude.abs() <= 180;
  }

  void _mostrarDetalhes(BuildContext context, LugaresModel lugar) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconeDaCategoria(lugar.categoria),
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(lugar.nome,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(lugar.categoria ?? 'Sem categoria'),
            const SizedBox(height: 12),
            Text(lugar.descricao.isEmpty ? 'Sem descrição' : lugar.descricao),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa dos lugares')),
      body: Consumer<LugaresController>(
        builder: (context, controller, child) {
          if (controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          final lugares =
              controller.lugares.where(_temCoordenadaValida).toList();
          if (lugares.isEmpty) {
            return const Center(child: Text('Nenhum lugar com localização.'));
          }
          final pontos =
              lugares.map((l) => LatLng(l.latitude, l.longitude)).toList();

          return FlutterMap(
            options: MapOptions(
              // enquadra todos os pins na tela (ou centraliza se só tiver um)
              initialCameraFit: pontos.length > 1
                  ? CameraFit.coordinates(
                      coordinates: pontos,
                      padding: const EdgeInsets.all(48),
                      maxZoom: 15,
                    )
                  : null,
              initialCenter: pontos.first,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.guia',
              ),
              MarkerLayer(
                markers: lugares.map((lugar) {
                  return Marker(
                    point: LatLng(lugar.latitude, lugar.longitude),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _mostrarDetalhes(context, lugar),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        child:
                            Icon(iconeDaCategoria(lugar.categoria), size: 22),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

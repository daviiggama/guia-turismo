import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia/controllers/gps_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/widgets/foto_lugar.dart';
import 'package:guia/widgets/lugar_detalhes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  String? _categoriaFiltro; // null = mostra todas

  @override
  void initState() {
    super.initState();
    context.read<GpsController>().atualizarPosicao();
  }

  // ignora lugares com coordenadas vazias (0,0) ou fora do limite
  bool _temCoordenadaValida(LugaresModel lugar) {
    if (lugar.latitude == 0 && lugar.longitude == 0) return false;
    return lugar.latitude.abs() <= 90 && lugar.longitude.abs() <= 180;
  }

  void _irParaMinhaLocalizacao(GpsController gps) {
    if (gps.posicao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível obter sua localização.')),
      );
      return;
    }
    _mapController.move(
      LatLng(gps.posicao!.latitude, gps.posicao!.longitude),
      15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final gps = context.watch<GpsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa dos lugares')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Minha localização',
        onPressed: () => _irParaMinhaLocalizacao(gps),
        child: const Icon(Icons.my_location),
      ),
      body: Consumer<LugaresController>(
        builder: (context, controller, child) {
          if (controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = controller.lugares.where(_temCoordenadaValida).toList();
          if (todos.isEmpty) {
            return const Center(child: Text('Nenhum lugar com localização.'));
          }

          // categorias que existem nos lugares, para os botões de filtro
          final categorias =
              todos.map((l) => l.categoria ?? 'Sem categoria').toSet().toList();
          final lugares = todos
              .where((l) =>
                  _categoriaFiltro == null ||
                  (l.categoria ?? 'Sem categoria') == _categoriaFiltro)
              .toList();
          final pontos =
              todos.map((l) => LatLng(l.latitude, l.longitude)).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.guia',
                  ),
                  MarkerLayer(
                    markers: [
                      // pins dos lugares, com a foto de cada um
                      ...lugares.map((lugar) {
                        return Marker(
                          point: LatLng(lugar.latitude, lugar.longitude),
                          width: 52,
                          height: 52,
                          child: GestureDetector(
                            onTap: () => mostrarDetalhesLugar(context, lugar),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cores.primary,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: FotoLugar(lugar: lugar, tamanho: 46),
                            ),
                          ),
                        );
                      }),
                      // bolinha azul da localização do usuário
                      if (gps.posicao != null)
                        Marker(
                          point: LatLng(
                              gps.posicao!.latitude, gps.posicao!.longitude),
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              // filtro por categoria
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _categoriaFiltro == null,
                          onSelected: (_) =>
                              setState(() => _categoriaFiltro = null),
                        ),
                      ),
                      ...categorias.map(
                        (categoria) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(categoria),
                            selected: _categoriaFiltro == categoria,
                            onSelected: (_) =>
                                setState(() => _categoriaFiltro = categoria),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

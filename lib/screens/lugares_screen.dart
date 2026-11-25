import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/gps_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/services/session_service.dart';
import 'package:guia/widgets/lugar_card.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  @override
  void initState() {
    super.initState();
    // pede a localização para mostrar a distância até cada lugar
    context.read<GpsController>().atualizarPosicao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: SessionService().pegarNome(),
          builder: (context, snapshot) {
            final nome = snapshot.data ?? '';
            return Text(nome.isEmpty ? 'Lugares para visitar' : 'Olá, $nome');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Ver no mapa',
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, 'mapa'),
          ),
          IconButton(
            tooltip: 'Alternar tema',
            icon: Icon(context.watch<ThemeController>().escuro
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => context.read<ThemeController>().alternarTema(),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthController>().deslogarUsuario();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, 'login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, 'cadastro'),
        icon: const Icon(Icons.add),
        label: const Text('Novo lugar'),
      ),
      body: Consumer<LugaresController>(
        builder: (context, lugaresController, child) {
          if (lugaresController.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lugaresController.erro != '') {
            return Center(child: Text(lugaresController.erro));
          }
          if (lugaresController.lugares.isEmpty) {
            return const Center(child: Text("Nenhum lugar encontrado!"));
          }

          return RefreshIndicator(
            onRefresh: lugaresController.listarLugares,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              itemCount: lugaresController.lugares.length,
              itemBuilder: (context, index) {
                final lugar = lugaresController.lugares[index];
                return LugarCard(lugar: lugar);
              },
            ),
          );
        },
      ),
    );
  }
}

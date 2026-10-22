import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatelessWidget {
  const LugaresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lugares para visitar"),
        actions: [
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
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(lugar.nome.isEmpty ? '(sem nome)' : lugar.nome),
                    subtitle: Text(lugar.categoria ?? 'Sem categoria'),
                    leading: const CircleAvatar(child: Icon(Icons.place)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

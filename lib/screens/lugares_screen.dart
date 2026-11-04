import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/services/session_service.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatelessWidget {
  const LugaresScreen({super.key});

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
                final cores = Theme.of(context).colorScheme;
                final descricao = lugar.descricao.trim();
                return Card(
                  elevation: 0,
                  color: cores.surfaceContainerHighest.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: cores.primaryContainer,
                      foregroundColor: cores.onPrimaryContainer,
                      child: Icon(iconeDaCategoria(lugar.categoria)),
                    ),
                    title: Text(
                      lugar.nome.isEmpty ? '(sem nome)' : lugar.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      descricao.isEmpty
                          ? (lugar.categoria ?? 'Sem categoria')
                          : '${lugar.categoria ?? 'Sem categoria'} · $descricao',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

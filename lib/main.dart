import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/camera_controller.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/gps_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/screens/cadastro_lugar.dart';
import 'package:guia/screens/login_screen.dart';
import 'package:guia/screens/lugares_screen.dart';
import 'package:guia/screens/mapa_screen.dart';
import 'package:provider/provider.dart';

// cor da identidade do app (azul oceano)
const corPrincipal = Color(0xFF1E6FB8);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // sem o google-services.json o app abre, mas o login com Google falha
    debugPrint('Erro ao iniciar o Firebase: $e');
  }
  runApp(const Inicializar());
}

class Inicializar extends StatelessWidget {
  const Inicializar({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => CameraController()),
        ChangeNotifierProvider(create: (_) => GpsController()),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, tema, child) => MaterialApp(
          title: 'Guia de Turismo',
          debugShowCheckedModeBanner: false,
          themeMode: tema.modo,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: corPrincipal),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: corPrincipal, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          initialRoute: 'login',
          routes: {
            'login': (context) => const LoginScreen(),
            'lugares': (context) => const LugaresScreen(),
            'cadastro': (context) => const CadastroLugar(),
            'mapa': (context) => const MapaScreen(),
          },
        ),
      ),
    );
  }
}

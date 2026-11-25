import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guia/services/auth_service.dart';
import 'package:guia/services/session_service.dart';

class AuthController extends ChangeNotifier {
  int idLogado = 0;
  bool carregando = false;
  String erro = '';

  Future<bool> autenticarUsuario(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final Map dados = await AuthService().autenticar(email, senha);
      final String? token = dados['token'];
      if (token == null) {
        erro = 'Login ou senha inválidos!';
        return false;
      }
      await SessionService().salvarToken(token);
      await SessionService().salvarUsuario(dados['usuario']);
      return true;
    } catch (e) {
      erro = 'Erro: ${e.toString()}';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> entrarComGoogle() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      // 1) login no Google
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final conta = await googleSignIn.authenticate();

      // 2) login no Firebase com a credencial do Google
      final credencial = GoogleAuthProvider.credential(
        idToken: conta.authentication.idToken,
      );
      final resultado =
          await FirebaseAuth.instance.signInWithCredential(credencial);
      final usuario = resultado.user!;

      // 3) entra na API do guia com o mesmo e-mail (precisa do token dela)
      final Map dados = await AuthService().autenticarComGoogle(
        usuario.displayName ?? usuario.email!,
        usuario.email!,
        usuario.uid,
      );
      final String? token = dados['token'];
      if (token == null) {
        erro = 'Não foi possível entrar com essa conta Google.';
        return false;
      }
      await SessionService().salvarToken(token);
      await SessionService().salvarUsuario(dados['usuario']);
      return true;
    } on GoogleSignInException catch (e) {
      erro = e.code == GoogleSignInExceptionCode.canceled
          ? 'Login cancelado.'
          : 'Erro no login com Google: ${e.description ?? e.code.name}';
      return false;
    } catch (e) {
      erro = 'Erro: ${e.toString()}';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> deslogarUsuario() async {
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Erro ao sair do Google: $e');
    }
    await SessionService().logout();
  }
}

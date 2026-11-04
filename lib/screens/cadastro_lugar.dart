import 'package:flutter/material.dart';
import 'package:guia/controllers/camera_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int? _categoriaId;
  bool _salvando = false;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    context.read<LugaresController>().carregarCategorias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // aceita vírgula como separador decimal
  double? _paraDouble(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  String? _validarCoordenada(String? valor, double limite) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
    final numero = _paraDouble(valor);
    if (numero == null) return 'Número inválido';
    if (numero.abs() > limite) return 'Deve estar entre -$limite e $limite';
    return null;
  }

  // procura o endereço/CEP e preenche latitude e longitude
  Future<void> _buscarEndereco() async {
    final texto = _enderecoController.text.trim();
    if (texto.isEmpty) return;
    setState(() => _buscando = true);
    String mensagem;
    try {
      final local =
          await context.read<LugaresController>().buscarLocalizacao(texto);
      if (local == null) {
        mensagem = 'Endereço não encontrado. Tente ser mais específico.';
      } else {
        _latitudeController.text = local.latitude.toStringAsFixed(6);
        _longitudeController.text = local.longitude.toStringAsFixed(6);
        mensagem = 'Encontrado: ${local.endereco}';
      }
    } catch (e) {
      mensagem = 'Não foi possível buscar o endereço.';
    }
    if (!mounted) return;
    setState(() => _buscando = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final lugar = LugaresModel(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      latitude: _paraDouble(_latitudeController.text)!,
      longitude: _paraDouble(_longitudeController.text)!,
      categoriaId: _categoriaId!,
    );
    final erro = await context.read<LugaresController>().cadastrarLugar(lugar);

    if (!mounted) return;
    setState(() => _salvando = false);
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lugar cadastrado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _fotoSelecionada(BuildContext context) {
    final camera = context.watch<CameraController>();
    return Column(
      children: [
        if (camera.imagemSelecionada != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(camera.imagemSelecionada!,
                height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: camera.carregando ? null : camera.abrirCamera,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Câmera'),
            ),
            TextButton.icon(
              onPressed: camera.carregando ? null : camera.abrirGaleria,
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<LugaresController>().categorias;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar lugar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titulo('Informações'),
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: categorias
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.nome)))
                    .toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
                validator: (v) => v == null ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: 16),
              _titulo('Localização'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _enderecoController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _buscarEndereco(),
                      decoration: const InputDecoration(
                        labelText: 'Endereço ou CEP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Buscar coordenadas',
                    onPressed: _buscando ? null : _buscarEndereco,
                    icon: _buscando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _validarCoordenada(v, 90),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _validarCoordenada(v, 180),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _titulo('Foto'),
              _fotoSelecionada(context),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

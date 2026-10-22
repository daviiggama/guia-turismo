import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> chamarGaleria() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    return foto == null ? null : File(foto.path);
  }

  Future<File?> chamarCamera() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    return foto == null ? null : File(foto.path);
  }
}

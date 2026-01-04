import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/core/usecases/usecase.dart';

/// UseCase para subir foto de perfil a Firebase Storage.
///
/// Responsabilidad:
/// - Subir imagen a Firebase Storage
/// - Retornar URL pública de la imagen
/// - Actualizar photoURL en Firebase Auth
///
/// Entrada:
/// - UploadProfilePhotoParams:
///   - filePath: ruta local del archivo de imagen
///   - userId: ID del usuario
///
/// Salida:
/// - String con URL pública de la imagen subida
///
/// Uso típico:
/// ```dart
/// // Usuario selecciona imagen
/// final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
///
/// if (pickedFile != null) {
///   final photoUrl = await uploadPhotoUseCase(UploadProfilePhotoParams(
///     filePath: pickedFile.path,
///     userId: currentUser.uid,
///   ));
///
///   print('Foto subida: $photoUrl');
/// }
/// ```
///
/// Ruta en Storage: users/{userId}/profile.jpg
///
/// Nota: Sobrescribe foto anterior si existe.
class UploadProfilePhotoUseCase
    implements UseCase<String, UploadProfilePhotoParams> {
  final UserRepository repository;

  UploadProfilePhotoUseCase(this.repository);

  @override
  Future<String> call(UploadProfilePhotoParams params) {
    return repository.uploadProfilePhoto(params.filePath, params.userId);
  }
}

/// Parámetros para subir foto de perfil.
class UploadProfilePhotoParams {
  final String filePath;
  final String userId;

  UploadProfilePhotoParams({required this.filePath, required this.userId});
}

import 'package:smartmeal/domain/repositories/user_repository.dart'; 
import 'package:smartmeal/core/usecases/usecase.dart';
  
class UploadProfilePhotoUseCase implements UseCase<String, UploadProfilePhotoParams> {  
  final UserRepository repository;
  
  UploadProfilePhotoUseCase(this.repository);  
  
  @override
  Future<String> call(UploadProfilePhotoParams params) {
    return repository.uploadProfilePhoto(params.filePath, params.userId); 
  }  
}  
 
class UploadProfilePhotoParams {
  final String filePath;
  final String userId;
 
  UploadProfilePhotoParams({required this.filePath, required this.userId});
} 

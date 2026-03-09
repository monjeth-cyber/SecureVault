// Mockito annotations – run `dart run build_runner build` to generate mocks.
import 'package:mockito/annotations.dart';
import 'package:secure_vault/services/auth_service.dart';
import 'package:secure_vault/services/biometric_service.dart';
import 'package:secure_vault/services/secure_storage_service.dart';

@GenerateMocks([AuthService, BiometricService, SecureStorageService])
void main() {}

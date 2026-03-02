import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'FIREBASE_API_KEY', obfuscate: true)
  static final String firebaseApiKey = _Env.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_APP_ID', obfuscate: true)
  static final String firebaseAppId = _Env.firebaseAppId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', obfuscate: true)
  static final String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', obfuscate: true)
  static final String firebaseProjectId = _Env.firebaseProjectId;
}

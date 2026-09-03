import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads local configuration bundled by Flutter, without any CLI flags.
Future<void> loadAppEnvironment() => dotenv.load(fileName: '.env');

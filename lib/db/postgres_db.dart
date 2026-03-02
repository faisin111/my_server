import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class PostgresDb {
  static late Connection connection;

   static Future<void> init(DotEnv env) async {
    final host =
        Platform.environment['DB_HOST'] ?? env['DB_HOST'];
    final port =
        Platform.environment['DB_PORT'] ?? env['DB_PORT'];
    final db =
        Platform.environment['DB_NAME'] ?? env['DB_NAME'];
    final user =
        Platform.environment['DB_USER'] ?? env['DB_USER'];
    final pass =
        Platform.environment['DB_PASS'] ?? env['DB_PASS'];

    if ([host, port, db, user, pass].contains(null)) {
      throw Exception('Database environment variables not set');
    }

    connection = await Connection.open(
      Endpoint(
        host: host!,
        port: int.parse(port!),
        database: db!,
        username: user!,
        password: pass!,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.require, // cloud safe
      ),
    );

    // Create table if not exists
    await connection.execute(
      Sql.named('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          name TEXT,
          email TEXT
        )
      '''),
    );

    print('PostgreSQL connected');
  }
}

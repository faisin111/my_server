import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class PostgresDb {
  static late Connection connection;

  static Future<void> init(DotEnv env) async {
    connection = await Connection.open(
      Endpoint(
       host: env['DB_HOST']!,
        port: int.parse(env['DB_PORT']!),
        database: env['DB_NAME']!,
        username: env['DB_USER']!,
        password: env['DB_PASS']!,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
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

import 'dart:io';

import 'package:postgres/postgres.dart';

class PostgresDb {
  static late Connection connection;

  static Future<void> init() async {
    connection = await Connection.open(
      Endpoint(
        host: Platform.environment['DB_HOST']!,
        port: int.parse(Platform.environment['DB_PORT']!),
        database: Platform.environment['DB_NAME']!,
        username: Platform.environment['DB_USER']!,
        password: Platform.environment['DB_PASS']!,
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

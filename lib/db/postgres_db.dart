import 'package:postgres/postgres.dart';

class PostgresDb {
  static late Connection connection;

  static Future<void> init() async {
    connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'my_database',
        username: 'postgres',
        password: 'password',
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

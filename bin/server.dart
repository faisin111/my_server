import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:my_server/db/postgres_db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:my_server/routes/user_routes.dart';

Future<void> main() async {
  final env=DotEnv();
   if (File('.env').existsSync()) {
    env.load();
    print('.env loaded');
  } else {
    print('No .env file found, using platform environment');
  }
  try {
    await PostgresDb.init(env);
  } catch (e) {
    print('Postgres initialization failed: $e');
    exit(1);
  }

  final app = Router();

  // Routes
  app.mount('/users', UserRoutes().router);

  app.get('/', (Request req) {
    return Response.ok(
      'My Dart Server is running',
      headers: {'Content-Type': 'text/plain'},
    );
  });

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('Server running at http://localhost:${server.port}');
}

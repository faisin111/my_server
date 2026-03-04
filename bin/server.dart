import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:my_server/db/postgres_db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:my_server/routes/user_routes.dart';

Future<void> main() async {
  final corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };
  final env = DotEnv();
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
  Middleware corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: corsHeaders);
        }

        final response = await innerHandler(request);
        return response.change(headers: corsHeaders);
      };
    };
  }

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(app);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('Server running at http://localhost:${server.port}');
}

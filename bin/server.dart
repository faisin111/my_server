import 'dart:io';

import 'package:my_server/db/mongo_db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:my_server/routes/user_routes.dart';

Future<void> main() async {
  try {
    // 🔥 Initialize Hive (REQUIRED)
    await HiveDb.init();
  } catch (e) {
    print('Hive initialization failed: $e');
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

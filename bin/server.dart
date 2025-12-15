import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:my_server/db/hive_db.dart';
import 'package:my_server/routes/user_routes.dart';

void main() async {
  await HiveDB.init();

  final app = Router();
  app.mount('/users/', UserRoutes().router);

  await io.serve(logRequests().addHandler(app), '0.0.0.0', 8080);

  print("Server running at http://localhost:8080");
}

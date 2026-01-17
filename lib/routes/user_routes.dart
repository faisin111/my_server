import 'dart:convert';
import 'package:my_server/db/mongo_db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

int? safeHiveId(String id) {
  try {
    return int.parse(id);
  } catch (_) {
    return null;
  }
}

class UserRoutes {
  Router get router {
    final router = Router();

    // GET ALL USERS
    router.get('/', (Request req) async {
      final users = HiveDb.usersBox.values.toList().asMap().entries.map((e) {
        final user = Map<String, dynamic>.from(e.value);
        user['id'] = e.key;
        return user;
      }).toList();

      return Response.ok(
        jsonEncode(users),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // CREATE USER
    router.post('/', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final id = await HiveDb.usersBox.add(data);

      return Response.ok(
        jsonEncode({"message": "User added", "id": id}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // GET USER BY ID
    router.get('/<id>', (Request req, String id) async {
      final index = safeHiveId(id);

      if (index == null || !HiveDb.usersBox.containsKey(index)) {
        return Response.notFound(
          jsonEncode({"error": "User not found"}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = Map<String, dynamic>.from(HiveDb.usersBox.getAt(index));
      user['id'] = index;

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // UPDATE USER
    router.put('/<id>', (Request req, String id) async {
      final index = safeHiveId(id);

      if (index == null || !HiveDb.usersBox.containsKey(index)) {
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid id"}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await req.readAsString();
      final updatedData = jsonDecode(body) as Map<String, dynamic>;

      await HiveDb.usersBox.putAt(index, updatedData);

      return Response.ok(
        jsonEncode({"message": "User updated"}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // DELETE USER
    router.delete('/<id>', (Request req, String id) async {
      final index = safeHiveId(id);

      if (index == null || !HiveDb.usersBox.containsKey(index)) {
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid id"}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await HiveDb.usersBox.deleteAt(index);

      return Response.ok(
        jsonEncode({"message": "User deleted"}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}

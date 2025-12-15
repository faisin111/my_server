import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_server/db/hive_db.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    // GET ALL USERS

    router.get('/', (Request req) {
      try {
        if (!HiveDB.users.isOpen) {
          return Response.internalServerError(
            body: jsonEncode({"error": "Users box is not open"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final usersList = HiveDB.users.values.map((user) {
          if (user is Map) return user;
          if (user.toJson != null) {
            return user.toJson();
          }
          return {"value": user.toString()};
        }).toList();

        return Response.ok(
          jsonEncode(usersList),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, s) {
        print("GET USERS ERROR: $e");
        print(s);
        return Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // CREATE USER

    router.post('/', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        final id = HiveDB.users.length + 1;
        await HiveDB.users.put(id, data);

        return Response.ok(
          jsonEncode({"message": "User added", "id": id}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: "POST Error: $e");
      }
    });

    // GET USER BY ID (only digits)

    router.get('/<id|[0-9]+>', (Request req, String id) {
      try {
        final cleanId = id.trim();

        final user = HiveDB.users.get(int.parse(cleanId));

        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        return Response.ok(
          jsonEncode(user),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: "GET ID Error: $e");
      }
    });

    // UPDATE USER
    router.put('/<id|[0-9]+>', (Request req, String id) async {
      try {
        final cleanId = id.trim();
        final userId = int.parse(cleanId);

        final existingUser = HiveDB.users.get(userId);
        if (existingUser == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final body = await req.readAsString();
        final updatedData = jsonDecode(body);

        await HiveDB.users.put(userId, updatedData);

        return Response.ok(
          jsonEncode({"message": "User updated", "id": userId}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({"error": "PUT Error: $e"}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE USER

    router.delete('/<id|[0-9]+>', (Request req, String id) {
      try {
        final cleanId = id.trim();

        HiveDB.users.delete(int.parse(cleanId));

        return Response.ok(
          jsonEncode({"message": "User deleted"}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: "DELETE Error: $e");
      }
    });

    // CATCH ALL OTHER ROUTES (IMPORTANT)

    router.all('/<ignored|.*>', (Request req) {
      return Response.notFound(jsonEncode({"error": "Route not found"}));
    });

    return router;
  }
}

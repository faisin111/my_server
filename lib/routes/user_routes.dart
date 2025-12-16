import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_server/db/hive_db.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    // GET ALL USERS

    router.get('/', (Request req) async {
      try {
        if (!HiveDB.users.isOpen) {
          return Response.internalServerError(
            body: jsonEncode({"error": "Users box is not open"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final usersList = HiveDB.users.values.map((user) {
          if (user is Map) return user;

          return {"value": user.toString()};
        }).toList();

        return Response.ok(
          jsonEncode(usersList.isEmpty ? "No users available" : usersList),
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

    router.post('/<username>', (Request req, String username) async {
      try {
        final body = await req.readAsString();

        if (body.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({"error": "Request body is empty"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        dynamic data;
        try {
          data = jsonDecode(body);
        } catch (_) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid JSON format"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        await HiveDB.users.put(username, data);

        return Response.ok(
          jsonEncode({"message": "User added", "username": username}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({"error": "POST Error: $e"}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET USER BY ID (only digits)

    router.get('/<username>', (Request req, String username) async {
      try {
        final user = await HiveDB.users.get(username);

        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {'Content-Type': 'application/json'},
          );
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
    router.put('/<username>', (Request req, String username) async {
      try {
        final existingUser = HiveDB.users.get(username);
        if (existingUser == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final body = await req.readAsString();
        final updatedData = jsonDecode(body);

        await HiveDB.users.put(username, updatedData);

        return Response.ok(
          jsonEncode({"message": "User updated", "username": username}),
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

    router.delete('/<username>', (Request req, String username) async {
      try {
        if (!HiveDB.users.containsKey(username)) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        await HiveDB.users.delete(username);

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

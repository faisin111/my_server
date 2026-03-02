import 'dart:convert';
import 'package:my_server/db/postgres_db.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    // GET ALL USERS
    router.get('/', (Request req) async {
      final result = await PostgresDb.connection.execute(
        Sql.named('SELECT id, name, email FROM users'),
      );

      final users = result
          .map((row) => {"id": row[0], "name": row[1], "email": row[2]})
          .toList();

      return Response.ok(
        jsonEncode(users),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // CREATE USER
    router.post('/', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final result = await PostgresDb.connection.execute(
        Sql.named('''
          INSERT INTO users (name, email)
          VALUES (@name, @email)
          RETURNING id
        '''),
        parameters: {'name': data['name'], 'email': data['email']},
      );

      return Response.ok(
        jsonEncode({"message": "User added", "id": result.first[0]}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // GET USER BY ID
    router.get('/<id>', (Request req, String id) async {
      final result = await PostgresDb.connection.execute(
        Sql.named('SELECT id, name, email FROM users WHERE id = @id'),
        parameters: {'id': int.parse(id)},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({"error": "User not found"}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = {
        "id": result.first[0],
        "name": result.first[1],
        "email": result.first[2],
      };

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // UPDATE USER
    router.put('/<id>', (Request req, String id) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      await PostgresDb.connection.execute(
        Sql.named('''
          UPDATE users
          SET name = @name, email = @email
          WHERE id = @id
        '''),
        parameters: {
          'id': int.parse(id),
          'name': data['name'],
          'email': data['email'],
        },
      );

      return Response.ok(
        jsonEncode({"message": "User updated"}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // DELETE USER
    router.delete('/<id>', (Request req, String id) async {
      await PostgresDb.connection.execute(
        Sql.named('DELETE FROM users WHERE id = @id'),
        parameters: {'id': int.parse(id)},
      );

      return Response.ok(
        jsonEncode({"message": "User deleted"}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}

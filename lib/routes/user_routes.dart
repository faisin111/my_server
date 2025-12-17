import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_server/db/mongo_db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

ObjectId? safeObjectId(String id) {
  try {
    return ObjectId.parse(id);
  } catch (_) {
    return null;
  }
}

class UserRoutes {
  Router get router {
    final router = Router();

    // GET ALL USERS
    router.get('/', (Request req) async {
      final users = await MongoDb.users.find().toList();
      return Response.ok(jsonEncode(users),
          headers: {'Content-Type': 'application/json'});
    });

    // CREATE USER
    router.post('/', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final result = await MongoDb.users.insertOne(data);

      return Response.ok(
        jsonEncode({
          "message": "User added",
          "id": (result.id as ObjectId).toHexString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // GET USER BY ID
    router.get('/<id>', (Request req, String id) async {
         final objectId = safeObjectId(id);

      if (objectId == null) {
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid id"}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user =
          await MongoDb.users.findOne(where.id(ObjectId.parse(id)));

      if (user == null) {
        return Response.notFound(
            jsonEncode({"error": "User not found"}));
      }

      return Response.ok(jsonEncode(user),
          headers: {'Content-Type': 'application/json'});
    });

    // UPDATE USER
    router.put('/<id>', (Request req, String id) async {
       final objectId = safeObjectId(id);

      if (objectId == null) {
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid id"}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      final body = await req.readAsString();
      final updatedData = jsonDecode(body) as Map<String, dynamic>;
      updatedData.remove('_id');

      final modifier = modify;
      updatedData.forEach((k, v) => modifier.set(k, v));

      await MongoDb.users.updateOne(
          where.id(ObjectId.parse(id)), modifier);

      return Response.ok(jsonEncode({"message": "User updated"}),
          headers: {'Content-Type': 'application/json'});
    });

    // DELETE USER
    router.delete('/<id>', (Request req, String id) async {
        final objectId = safeObjectId(id);

      if (objectId == null) {
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid id"}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      await MongoDb.users.deleteOne(
          where.id(ObjectId.parse(id)));

      return Response.ok(jsonEncode({"message": "User deleted"}),
          headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}


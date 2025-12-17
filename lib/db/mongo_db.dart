import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  static late Db db;
  static late DbCollection users;

  static Future<void> init() async {
    // final mongoUrl = Platform.environment['MONGO_URL'];

    // if (mongoUrl == null || mongoUrl.isEmpty) {
    //   throw Exception('MONGO_URL is not set');
    // }

    db = Db("mongodb+srv://admin:CLzyys6WZqXHvI1J@cluster0.1misyhm.mongodb.net/mydb?retryWrites=true&w=majority");
    await db.open();
    users = db.collection('users');
    print('Mongo DB created');
  }
}

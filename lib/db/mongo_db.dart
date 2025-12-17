import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  static late Db db;
  static late DbCollection users;

  static Future<void> init() async {
    final mongoUrl = Platform.environment['MONGO_URL'];

    if (mongoUrl == null || mongoUrl.isEmpty) {
      throw Exception('MONGO_URL is not set');
    }

    db = Db(mongoUrl);
    await db.open();
    users = db.collection('users');
    print('Mongo DB created');
  }
}

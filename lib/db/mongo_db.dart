import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  static late Db db;
  static late DbCollection users;

  static Future<void> init() async {
    db = Db(
      Platform
          .environment["mongodb+srv://<admin>:<CLzyys6WZqXHvI1J>@cluster0.1misyhm.mongodb.net/?appName=Cluster0"]!,
    );

    await db.open();
    users = db.collection('users');
    print('Mongo DB created');
  }
}

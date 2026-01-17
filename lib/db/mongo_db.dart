import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  static late Db db;
  static late DbCollection users;

  static Future<void> init() async {
    // final mongoUrl = Platform.environment['MONGO_URL'];

    // if (mongoUrl == null || mongoUrl.isEmpty) {
    //   throw Exception('MONGO_URL is not set');
    // }
    //  dbb=Db("mongodb+srv://faisin123:CLzyys6WZqXHvI1J@cluster0.h2wjcex.mongodb.net/?dartServer=Cluster0")
    db = Db(
      "mongodb+srv://faisin123:CLzyys6WZqXHvI1J@cluster0.h2wjcex.mongodb.net/?dartServer=Cluster0",
    );
    await db.open();
    users = db.collection('users');
    print('Mongo DB created');
  }
}

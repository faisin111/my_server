import 'package:mongo_dart/mongo_dart.dart';

class MongoDb {
  static late Db db;
  static late DbCollection users;

  static Future<void> init() async {
    // db = Db(
    //   "mongodb+srv://faisin123:CLzyys6WZqXHvI1J@cluster0.h2wjcex.mongodb.net/?dartServer=Cluster0",
    // );
    db = Db(
      "mongodb://faisin123:CLzyys6WZqXHvI1J@HOST1:27017,HOST2:27017,HOST3:27017/dartServer",
      "?ssl=true&replicaSet=atlas-xxxxx&authSource=admin&retryWrites=true&w=majority",
    );
    await db.open();
    users = db.collection('users');
    print('Mongo DB created');
  }
}

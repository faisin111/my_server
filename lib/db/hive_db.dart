import 'package:hive/hive.dart';
import 'dart:io';

class HiveDB {
  static late Box users;

  static Future<void> init() async {
    final dir = Directory('./my_server_data');

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    Hive.init(dir.path);

    users = await Hive.openBox('users');
  }
}

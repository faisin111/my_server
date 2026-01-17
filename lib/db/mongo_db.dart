import 'dart:io';

import 'package:hive/hive.dart';

class HiveDb {
  static late Box usersBox;

  static Future<void> init() async {
    // Set Hive directory (important for server)
    final dir = Directory.current.path;
    Hive.init(dir);

    // Open box (similar to MongoDB collection)
    usersBox = await Hive.openBox('users');

    print('Hive DB initialized');
  }
}

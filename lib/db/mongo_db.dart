import 'dart:io';

import 'package:hive/hive.dart';

class HiveDb {
  static late Box usersBox;

  static Future<void> init() async {
    final dir = Directory('/tmp/hive');

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    Hive.init(dir.path);

    usersBox = await Hive.openBox('users');

    print('Hive DB initialized at ${dir.path}');
  }
}

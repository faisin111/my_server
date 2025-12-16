import 'package:hive/hive.dart';
import 'dart:io';

class HiveDB {
  static late Box users;

  static Future init() async {
    final dbPath = '${Platform.environment['HOME']}/my_server_data';

    Hive.init(dbPath);

    users = await Hive.openBox('users');
  }
}

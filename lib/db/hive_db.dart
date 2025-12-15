import 'package:hive/hive.dart';
import 'dart:io';

class HiveDB {
  static late Box users;

  static Future init() async {
    final dbPath = '${Directory.current.path}/hive_data';

    Hive.init(dbPath);

    users = await Hive.openBox('users');
  }
}

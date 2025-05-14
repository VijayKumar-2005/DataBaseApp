import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> openBox() async {
    await Hive.initFlutter();
    await Hive.openBox('myBox');
  }

  static Future<Box> getBox() async {
    return await Hive.openBox('myBox');
  }

  static Future<void> putValue(String key, dynamic value) async {
    var box = await getBox();
    await box.put(key, value);
  }

  static Future<dynamic> getValue(String key) async {
    var box = await getBox();
    return box.get(key);
  }

  static Future<void> deleteValue(String key) async {
    var box = await getBox();
    await box.delete(key);
  }

  static Future<bool> containsKey(String key) async {
    var box = await getBox();
    return box.containsKey(key);
  }

  static Future<void> closeBox() async {
    var box = await getBox();
    await box.close();
  }
}

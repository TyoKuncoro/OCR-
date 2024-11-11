import 'dart:async';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'package:ocr/model/recognized_text.dart';

import '../model/recognized_text_dao.dart';

part 'db.g.dart';

@Database(version: 1, entities: [RecognizedText])
abstract class DbManager extends FloorDatabase {
  RecognizedTextDao get recognizedTextDao;

  static DbManager? _instance;

  static DbManager get instance {
    if (_instance == null) {
      throw Exception("Instance is null");
    }

    return _instance!;
  }

  static Future<void> init() async {
    _instance ??= await $FloorDbManager.databaseBuilder("main.db").build();
  }
}

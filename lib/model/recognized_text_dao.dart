import 'package:floor/floor.dart';

import 'recognized_text.dart';

@dao
abstract class RecognizedTextDao {
  @Query('SELECT * FROM RecognizedText')
  Future<List<RecognizedText>> findAll();

  @insert
  Future<void> insertItem(RecognizedText val);
}
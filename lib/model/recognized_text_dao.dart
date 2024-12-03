import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

import 'recognized_text.dart';

//interface for accessing table inside database
@dao //dao = database object
abstract class RecognizedTextDao {
  // @Query('SELECT * FROM RecognizedTextItem where text LIKE :searchText')
  // Future<List<RecognizedTextItem>> searchByText(String searchText);

  @Query('SELECT * FROM RecognizedTextItem')
  Future<List<RecognizedTextItem>> getList();

  @Query('SELECT * FROM RecognizedTextItem')
  Stream<List<RecognizedTextItem>> getStreamList();

  @Query('SELECT * FROM RecognizedTextItem where id =:itemId')
  Future<RecognizedTextItem?> getById(int itemId);

  @Query('DELETE FROM RecognizedTextItem')
  Future<void> clear();

  @insert
  Future<void> add(RecognizedTextItem val);

  @delete
  Future<void> remove(RecognizedTextItem val);

  @Update(onConflict: OnConflictStrategy.fail)
  Future<void> update(RecognizedTextItem val);
}

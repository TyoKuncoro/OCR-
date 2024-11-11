import 'dart:typed_data';
import 'package:floor/floor.dart';

@entity
class RecognizedText {
  @primaryKey
  int? id;
  final Uint8List image;

  RecognizedText(this.image);
}
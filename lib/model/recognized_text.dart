import 'dart:typed_data';
import 'package:floor/floor.dart';

// entity as table in db
@entity
class RecognizedTextItem {
  @primaryKey
  int? id; //column id
  // String? title;
  final Uint8List image; //store as bytes
  String text; // scanned text in selected image
  late int timeCreated; // store time in epoch/unix timestamp
  late int timeLastUpdated = 0; // store time in epoch/unix timestamp

  RecognizedTextItem({this.id, required this.image, required this.text}) {
    if (text.trim().isEmpty) {
      throw Exception(
          "either image has no text or scanner unable to scan the image");
    }

    timeCreated = DateTime.now().millisecondsSinceEpoch;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ocr/model/recognized_text.dart';
import 'package:ocr/widget/empty_state_list.dart';
import 'package:ocr/utils/db.dart';

import '../ui/text_scanner.dart';

class RecognizedTextList extends StatefulWidget {
  static const int MENU_SHARE = 0;
  static const int MENU_REMOVE = 1;

  RecognizedTextList({Key? key}) : super(key: key);

  @override
  State<RecognizedTextList> createState() => RecognizedTextListState();
}

class RecognizedTextListState extends State<RecognizedTextList> {
  final Stream<List<RecognizedTextItem>> list =
      DbManager.instance.recognizedTextDao.getStreamList();
  final List<int?> _id = [];
  final List<String> _text = [];
  final List<Uint8List> _images = [];
  final List<RecognizedTextItem> _searchToShow = [];

  final double _gridPad = 16;

  final double _roundCorner = 10;

  bool searchMode = false;

  void search(String keySearch) async {
    var list2 = await DbManager.instance.recognizedTextDao.getList();
    print("tipe data: ${list2.runtimeType}");
    for (var element in list2) {
      _id.add(element.id);
      _text.add(element.text);
      _images.add(element.image);
    }
    for (int i = 0; i < _text.length; i++) {
      if (_text[i].toLowerCase().contains(keySearch)) {
        RecognizedTextItem _searchedList =
            RecognizedTextItem(id: _id[i], text: _text[i], image: _images[i]);
        _searchToShow.add(_searchedList);
      }
    }
    setState(() {
      if (keySearch.isEmpty) {
        searchMode = false;
      } else {
        searchMode = true;
      }
    });

    print("list: ${list.runtimeType}");

    // for (var element in list2) {
    // setState(() {
    //   if (keySearch.isEmpty) {
    //     _filteredItems.add(element.id);
    //   }
    //   _items.add(element.text);
    //   _filteredItems = _items
    //       .where(
    //           (item) => item.toLowerCase().contains(keySearch.toLowerCase()))
    //       .toList();
    // });
    // print("ID: ${_id}");
    // print("text: ${_text}");
    // print("images: ${_images}");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecognizedTextItem>>(
      stream: list,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return EmptyState(
            message: "Error ${snapshot.error}",
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            message: "No data",
          );
        }

        final list = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(_gridPad),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: _gridPad,
            mainAxisSpacing: _gridPad,
          ),
          itemCount: searchMode ? _searchToShow.length : list.length,
          itemBuilder: (context, index) {
            var item = searchMode ? _searchToShow[index] : list[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(_roundCorner),
              child: Stack(
                children: [
                  Image(
                    width: double.infinity,
                    image: MemoryImage(item.image),
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        item.text.replaceAll("\n", " "),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return TextScanner(item: item);
                          },
                        ));
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(20)),
                        child: Material(
                          color: Colors.black54,
                          child: PopupMenuButton<int>(
                            constraints:
                                BoxConstraints(minWidth: 0, minHeight: 0),
                            iconColor: Colors.white,
                            icon: Icon(Icons.menu),
                            padding: EdgeInsets.all(0),
                            position: PopupMenuPosition.under,
                            menuPadding: EdgeInsets.all(0),
                            shape: LinearBorder.start(),
                            onSelected: (value) {
                              switch (value) {
                                case RecognizedTextList.MENU_REMOVE:
                                  DbManager.instance.recognizedTextDao
                                      .remove(item);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: RecognizedTextList.MENU_REMOVE,
                                child: Center(
                                    child: Icon(Icons.playlist_remove,
                                        color: Colors.blue)),
                              ),
                              PopupMenuItem(
                                value: RecognizedTextList.MENU_SHARE,
                                child: Center(
                                    child: Icon(Icons.share_outlined,
                                        color: Colors.blue)),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

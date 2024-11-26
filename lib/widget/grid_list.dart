import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr/model/recognized_text.dart';
import 'package:ocr/widget/empty_state_list.dart';
import 'package:ocr/utils/db.dart';

import '../ui/text_scanner.dart';

class RecognizedTextList extends StatelessWidget {
  static const int MENU_SHARE =0;
  static const int MENU_REMOVE = 1;

  final Stream<List<RecognizedTextItem>> _list =
      DbManager.instance.recognizedTextDao.getStreamList();
  final double _gridPad = 16;
  final double _roundCorner = 10;

  RecognizedTextList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecognizedTextItem>>(
      stream: _list,
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
          itemCount: list.length,
          itemBuilder: (context, index) {
            var item = list[index];
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
                            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            iconColor: Colors.white,
                            icon: Icon(Icons.menu),
                            padding: EdgeInsets.all(0),
                            position: PopupMenuPosition.under,
                            menuPadding: EdgeInsets.all(0),
                            shape: LinearBorder.start(),
                            onSelected: (value) {
                              switch (value){
                                case MENU_REMOVE:
                                  DbManager.instance.recognizedTextDao.remove(item);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: MENU_REMOVE,
                                child: Center(child: Icon(Icons.playlist_remove, color: Colors.blue)),
                              ),
                              PopupMenuItem(
                                value: MENU_SHARE,
                                child: Center(child: Icon(Icons.share_outlined, color: Colors.blue)),
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

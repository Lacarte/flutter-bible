import 'package:bible_app/Models/Chapter.dart';
import 'package:bible_app/Views/BookPanel.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/Models/Book.dart';

class BookDrawer extends StatelessWidget {
  final List<Book> books;
  final Function(Book, Chapter) showChapterVerses;

  BookDrawer({Key key, @required this.books, @required this.showChapterVerses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      semanticLabel: "Books",
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => BookPanel(
                  book: this.books[index], openChapter: this.showChapterVerses),
              itemCount: this.books.length,
            ),
          ),
        ],
      ),
    );
  }
}

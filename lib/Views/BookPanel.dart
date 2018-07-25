import 'package:bible_app/Models/Book.dart';
import 'package:bible_app/Models/Chapter.dart';
import 'package:bible_app/Views/ChapterCircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookPanel extends StatelessWidget {
  final Book book;
  final Function(Book, Chapter) openChapter;
  const BookPanel({Key key, @required this.book, @required this.openChapter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Text(
          book.name,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BookChapterPanel(
            book: book,
            context: context,
            onCircleTap: openChapter,
          ),
        )
      ],
    );
  }
}

class BookChapterPanel extends StatelessWidget {
  const BookChapterPanel({
    Key key,
    @required this.context,
    @required this.book,
    @required this.onCircleTap,
  }) : super(key: key);

  final BuildContext context;
  final Book book;
  final Function(Book, Chapter) onCircleTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: -25.0,
      runSpacing: 10.0,
      children: book.chapters
          .map(
            (chap) => ChapterCircle(
                book: book,
                chapter: chap,
                context: context,
                onTap: onCircleTap),
          )
          .toList(),
    );
  }
}

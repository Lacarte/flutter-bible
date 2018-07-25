import 'package:bible_app/Models/Book.dart';
import 'package:bible_app/Models/Chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChapterCircle extends StatelessWidget {
  const ChapterCircle({
    Key key,
    @required this.context,
    @required this.chapter,
    @required this.book,
    @required this.onTap,
  }) : super(key: key);

  final BuildContext context;
  final Chapter chapter;
  final Book book;
  final void Function(Book, Chapter) onTap;

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      child: Text(
        chapter.number.toString(),
        style: Theme.of(context).textTheme.display1,
      ),
      onPressed: () => onTap(book, chapter),
      shape: CircleBorder(),
      padding: EdgeInsets.all(8.0),
      elevation: 0.0,
    );
  }
}

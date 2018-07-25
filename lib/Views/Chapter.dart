import 'package:bible_app/Models/Chapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:bible_app/Models/Book.dart';
import 'package:bible_app/Designs/Designs.dart';

class Verses extends StatelessWidget {
  final Chapter chapter;
  final Book book;
  final Function(DismissDirection) swipeAction;
  final bool addBackgrounds;
  final LongPressGestureRecognizer longPressRecognizer;

  Verses(this.chapter, this.book, this.swipeAction, this.addBackgrounds,
      [this.longPressRecognizer]);

  Widget build(BuildContext context) {
    List<TextSpan> chapterText = new List<TextSpan>();
    for (var verse in chapter.verses) {
      var number = new TextSpan(
        text: ' ' + verse.number.toString() + ' ',
        style: new TextStyle(fontWeight: FontWeight.bold),
        recognizer: longPressRecognizer,
      );
      var verText = new TextSpan(
        text: verse.text,
        style: new TextStyle(fontWeight: FontWeight.normal),
        recognizer: longPressRecognizer,
      );
      chapterText.add(number);
      chapterText.add(verText);
    }
    return new Dismissible(
      secondaryBackground: this.getNextBook(context),
      background: this.getPrevBook(context),
      resizeDuration: null,
      onDismissed: (DismissDirection direction) => this.swipeAction(direction),
      child: new ChapterText(
          book: book, chapter: chapter, chapterText: chapterText),
      key: new ValueKey(chapter.number),
    );
  }

  getPrevBook(context) {
    if (1 == chapter.number) {
      return new Column();
    } else {
      return new Verses(
          book.getChapter(chapter.number - 1), book, swipeAction, false);
    }
  }

  getNextBook(context) {
    if (book.chapters.length == chapter.number) {
      return new Column(
        children: <Widget>[
          new Text(
            "End of " + book.name,
            style: Theme.of(context).textTheme.display1,
          )
        ],
      );
    } else {
      return new Verses(
          book.getChapter(chapter.number + 1), book, swipeAction, false);
    }
  }
}

class ChapterText extends StatelessWidget {
  const ChapterText({
    Key key,
    @required this.book,
    @required this.chapter,
    @required this.chapterText,
  }) : super(key: key);

  final Book book;
  final Chapter chapter;
  final List<TextSpan> chapterText;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.fromLTRB(7.0, 3.0, 0.0, 2.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new RichText(
                        textAlign: TextAlign.left,
                        text: new TextSpan(
                          text: book.name + ' ' + chapter.number.toString(),
                          style: Designs.darkTheme.textTheme.body2,
                        ),
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RichText(
                    text: new TextSpan(
                      children: chapterText,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bible_app/Model/AppState.dart';
import 'package:bible_app/Model/Chapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/Utility/BibleImporter.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;

import 'package:bible_app/Model/Book.dart';
import 'package:bible_app/Designs/Designs.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: Designs.darkTheme,
      home: new MyHomePage(title: 'The Bible'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Book> books = new List<Book>();
  Widget body;
  LongPressGestureRecognizer _longPressRecognizer;
  AppState appState = new AppState();

  Future<String> getFileData(String path) {
    try {
      var data = rootBundle.loadString(path);
      return data;
    } catch (e) {
      return Future.value("");
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _stateFile async {
    final path = await _localPath;
    return File('$path/state.json');
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (appState.isValid()) {
      this.saveCurrentBookAndChapter();
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _longPressRecognizer = new LongPressGestureRecognizer()
        ..onLongPress = _handlePress;
      var importer;
      //var  books;C:\Dev\flutter\apps\bible_app\lib\Resources\ESV.xml
      getFileData('resources/esv.xml').then((String value) {
        importer = new BibleImporter(value);

        this.books = importer.getAllBooks().toList();
        try {
          readCurrentBookAndChapter().then((String value) {
            Map stateMap = json.decode(value);
            appState = new AppState.fromJson(stateMap);
            setState(() {
              if (appState.currentBook == null) {
                appState.currentBook = this.books.first;
                appState.currentChapter = 1;
              }
              var currentBook = this.books.firstWhere(
                  (b) => b.name == appState.currentBook.name,
                  orElse: () => this.books.first);

              showVerses(
                  currentBook.getChapter(appState.currentChapter), currentBook);
            });
          });
        } catch (e) {
          setState(() {
            if (appState.currentBook == null) {
              appState.currentBook = this.books.first;
              appState.currentChapter = 1;
            }
            var currentBook = this.books.firstWhere(
                (b) => b.name == appState.currentBook.name,
                orElse: () => this.books.first);

            showVerses(
                currentBook.getChapter(appState.currentChapter), currentBook);
          });
        }
      });

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      //String data = getFileData("ESV.xml") as String;
      //var importer = new BibleImporter(data);
      //var books = importer.getAllBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    //var importedBooks = importer.getAllBooks();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: this.body,
      ),
      drawer: new Drawer(
        semanticLabel: "Books",
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    getBookPanel(this.books[index]),
                itemCount: this.books.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void expandBook(int index, bool isExpanded) {}

  /*  Widget getBookList() {
        var panel = new ExpansionPanelList(
            animationDuration: new Duration(seconds: 1),
            expansionCallback: (int index, bool isExpanded) {
              //TODO: make books expand on click anywhere on listing
              setState(() {
                this.books[index].isExpanded = !isExpanded;
              });
            },
            children: this.books.map((aBook) => getBookPanel(aBook)).toList());
        return panel;
      } */

  Widget getBookPanel(Book aBook) {
    return ExpansionTile(
      title: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Text(
          aBook.name,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: getBookChapterPanels(aBook),
        )
      ],
    );
  }

  showVerses(Chapter chapter, Book book) {
    setState(() {
      appState.currentChapter = chapter.number;
      appState.currentBook = book;
      this.body = new Verses(
          chapter, book, swipeToNextChapter, true, _longPressRecognizer);
    });
  }

  swipeToNextChapter(DismissDirection swipeDetails) {
    if (swipeDetails == DismissDirection.endToStart) {
      if (books.last == appState.currentBook &&
          appState.currentChapter == appState.currentBook.chapters.length) {
        var nextBook = this.books.first;
        showVerses(nextBook.chapters.first, nextBook);
      } else if (appState.currentBook.chapters.length ==
          appState.currentChapter) {
        var nextBook = this.books[this.books.indexOf(appState.currentBook) + 1];
        showVerses(nextBook.chapters.first, nextBook);
      } else {
        showVerses(appState.currentBook.getChapter(appState.currentChapter + 1),
            appState.currentBook);
      }
    } else {
      if (books.first == appState.currentBook && appState.currentChapter == 1) {
        var nextBook = this.books.last;
        showVerses(nextBook.chapters.last, nextBook);
      } else if (1 == appState.currentChapter) {
        var prevBook = this.books[this.books.indexOf(appState.currentBook) - 1];
        showVerses(prevBook.chapters.last, prevBook);
      } else {
        showVerses(appState.currentBook.getChapter(appState.currentChapter - 1),
            appState.currentBook);
      }
    }
  }

  void openChapter(Chapter chapter, Book book) {
    Navigator.of(context).pop();
    books.forEach((Book b) => b.isExpanded = false);
    showVerses(chapter, book);
  }

  void _handlePress() {
    HapticFeedback.vibrate();
  }

  Widget getBookChapterPanels(Book aBook) {
    return Wrap(
      spacing: -25.0,
      runSpacing: 10.0,
      children: aBook.chapters
          .map(
            (chap) => ChapterCircle(
                book: aBook,
                chapter: chap,
                context: context,
                onTap: openChapter),
          )
          .toList(),
    );
  }

  List<Row> getBookChapterColumns(Book aBook) {
    List<Row> rows = new List<Row>();
    for (var i = 0; i < aBook.chapters.length / 6; i++) {
      int lowerBound = i * 6;
      int upperBound = i * 6 + 6;
      upperBound = upperBound > aBook.chapters.length - 1
          ? aBook.chapters.length - 1
          : upperBound;
      Row aRow = new Row(
          children: aBook.chapters
              .sublist(lowerBound, upperBound)
              .map(
                (chap) => ChapterCircle(
                    book: aBook,
                    chapter: chap,
                    context: context,
                    onTap: openChapter),
              )
              .toList());
      rows.add(aRow);
    }
    return rows;
  }

  Future<File> saveCurrentBookAndChapter() async {
    final file = await _stateFile;

    // Write the file
    return file.writeAsString(json.encode(appState));
  }

  Future<String> readCurrentBookAndChapter() async {
    try {
      final file = await _stateFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If we encounter an error, return 0
      return "";
    }
  }
}

class ChapterCircle extends StatelessWidget {
  const ChapterCircle({
    Key key,
    @required this.context,
    @required this.chapter,
    @required this.book,
    this.onTap,
  }) : super(key: key);

  final BuildContext context;
  final Chapter chapter;
  final Book book;
  final void Function(Chapter chapter, Book book) onTap;

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      child: Text(
        chapter.number.toString(),
        style: Theme.of(context).textTheme.display1,
      ),
      onPressed: () => onTap(chapter, book),
      shape: CircleBorder(),
      padding: EdgeInsets.all(8.0),
      elevation: 0.0,
    );
  }
}

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

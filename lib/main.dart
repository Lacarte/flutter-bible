import 'dart:async';
import 'dart:convert';

import 'package:bible_app/Models/AppState.dart';
import 'package:bible_app/Models/Chapter.dart';
import 'package:bible_app/Views/BooksDrawer.dart';
import 'package:bible_app/Views/Chapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/Utility/BibleImporter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bible_app/Models/Book.dart';
import 'package:bible_app/Designs/Designs.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String membershipKey = 'david.anderson.bibleapp';

  Future<String> getFileData(String path) {
    try {
      var data = rootBundle.loadString(path);
      return data;
    } catch (e) {
      return Future.value("");
    }
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
    BibleImporter importer;
    //var  books;C:\Dev\flutter\apps\bible_app\lib\Resources\ESV.xml

    setState(() {
      getFileData('resources/esv.xml').then((String value) {
        importer = new BibleImporter(value);

        importer.getAllBooks().then((bookList) {
          this.books = bookList;
        });
        //try {
        readCurrentBookAndChapter().then((AppState appState) {
          if (appState.currentBook == null) {
            appState.currentBook = this.books.first;
            appState.currentChapter = 1;
          }
          var currentBook = importer.getBook(appState.currentBook.name);
          if (currentBook == null) {
            this.books.first;
          }

          showVerses(
              currentBook, currentBook.getChapter(appState.currentChapter));
        });
        /* } catch (e) {
          if (appState.currentBook == null) {
            appState.currentBook = this.books.first;
            appState.currentChapter = 1;
          }
          var currentBook = this.books.firstWhere(
              (b) => b.name == appState.currentBook.name,
              orElse: () => this.books.first);

          showVerses(
              currentBook, currentBook.getChapter(appState.currentChapter));
        } */
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: new BookDrawer(books: books, showChapterVerses: openChapter),
    );
  }

  showVerses(Book book, Chapter chapter) {
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
        showVerses(nextBook, nextBook.chapters.first);
      } else if (appState.currentBook.chapters.length ==
          appState.currentChapter) {
        var nextBook = this.books[this.books.indexOf(appState.currentBook) + 1];
        showVerses(nextBook, nextBook.chapters.first);
      } else {
        showVerses(appState.currentBook,
            appState.currentBook.getChapter(appState.currentChapter + 1));
      }
    } else {
      if (books.first == appState.currentBook && appState.currentChapter == 1) {
        var nextBook = this.books.last;
        showVerses(nextBook, nextBook.chapters.last);
      } else if (1 == appState.currentChapter) {
        var prevBook = this.books[this.books.indexOf(appState.currentBook) - 1];
        showVerses(prevBook, prevBook.chapters.last);
      } else {
        showVerses(appState.currentBook,
            appState.currentBook.getChapter(appState.currentChapter - 1));
      }
    }
  }

  void openChapter(Book book, Chapter chapter) {
    Navigator.of(context).pop();
    books.forEach((Book b) => b.isExpanded = false);
    showVerses(book, chapter);
  }

  void saveCurrentBookAndChapter() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(membershipKey, json.encode(this.appState));
  }

  Future<AppState> readCurrentBookAndChapter() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      var loadedAppState =
          new AppState.fromJson(json.decode(sp.getString(membershipKey)));

      return loadedAppState;
    } catch (e) {
      return new AppState();
    }
  }
}

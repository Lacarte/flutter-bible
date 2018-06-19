import 'dart:async';

import 'package:bible_app/Model/Chapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/Utility/BibleImporter.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;

import 'package:bible_app/Model/Book.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.grey,
        primaryColor: Colors.grey.shade100,
        primaryTextTheme: Theme.of(context).textTheme.copyWith(
          display1: Theme.of(context).textTheme.display1.copyWith(color: Colors.black)
        ),
      ),
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
  Book book;
  Chapter chapter;
  LongPressGestureRecognizer _longPressRecognizer;

  Future<String> getFileData(String path) {
    return rootBundle.loadString(path);
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
              setState(() {
                this.books = importer.getAllBooks().toList();
                showVerses(books.first.chapters.first, books.first);
              });
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
                child: this.body),
            drawer: new Drawer(
              semanticLabel: "Books",
              child: new ListView(
                children: <Widget>[
                  new Container(
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        'Books',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ),
                    decoration:
                        new BoxDecoration(color: Theme.of(context).primaryColor),
                  ),
                  this.getBookList(books)
                ],
              ),
            ),
          );
        }
      
        void expandBook(int index, bool isExpanded) {}
      
        Widget getBookList(books) {
          var panel = new ExpansionPanelList(
              animationDuration: new Duration(seconds: 1),
              expansionCallback: (int index, bool isExpanded) {
                //TODO: make books expand on click anywhere on listing
                setState(() {
                  books[index].isExpanded = !isExpanded;
                });
              },
              children: this
                  .books
                  .map(
                    (aBook) => new ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return new Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new Text(
                              aBook.name,
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                        body: new Container(
                          height: 200.0,
                          child: new GridView.count(
                              crossAxisCount: 6,
                              children: aBook.chapters
                                  .map(
                                    (chap) => new GestureDetector(
                                          onTap: () => openChapter(chap, aBook),
                                          child: new Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: new DecoratedBox(
                                              decoration: new BoxDecoration(
                                                  color:
                                                      Theme.of(context).buttonColor,
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          40.0)),
                                              child: new FittedBox(
                                                alignment: Alignment.center,
                                                child: new Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: new Text(
                                                    chap.number.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .button,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList()),
                        ),
                        isExpanded: aBook.isExpanded),
                  )
                  .toList());
          return panel;
        }
      
        showVerses(Chapter chapter, Book book) {
          setState(() {
            this.chapter = chapter;
            this.book = book;
            this.body = new Verses(chapter, book, swipeToNextChapter, true,  _longPressRecognizer);
          });
        }
      
        swipeToNextChapter(DismissDirection swipeDetails) {
          if (swipeDetails == DismissDirection.endToStart) {
            if (books.last == book && chapter.number == book.chapters.length) {
              var nextBook = this.books.first;
              showVerses(nextBook.chapters.first, nextBook);
            } else if (book.chapters.length == chapter.number) {
              var nextBook = this.books[this.books.indexOf(book) + 1];
              showVerses(nextBook.chapters.first, nextBook);
            } else {
              showVerses(book.getChapter(chapter.number + 1), book);
            }
          } else {
            if (books.first == book && chapter.number == 1) {
              var nextBook = this.books.last;
              showVerses(nextBook.chapters.last, nextBook);
            } else if (1 == chapter.number) {
              var prevBook = this.books[this.books.indexOf(book) - 1];
              showVerses(prevBook.chapters.last, prevBook);
            } else {
              showVerses(book.getChapter(chapter.number - 1), book);
            }
          }
        }
      
        void openChapter(Chapter chapter, Book book) {
          Navigator.of(context).pop();
          books.forEach((Book b) => b.isExpanded = false);
          showVerses(chapter, book);
        }
      
        ExpansionPanel getBookPanel(Book book) {
          return new ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return new GestureDetector(
                  onTap: () => {},
                  child: new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Text(
                      book.name,
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
              body: new Container(
                height: 200.0,
                child: new GridView.count(
                    crossAxisCount: 6,
                    children: book.chapters
                        .map(
                          (chap) => new GestureDetector(
                                onTap: () => openChapter(chap, book),
                                child: new Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: new DecoratedBox(
                                    decoration: new BoxDecoration(
                                        color: Theme.of(context).buttonColor,
                                        borderRadius:
                                            new BorderRadius.circular(40.0)),
                                    child: new FittedBox(
                                      alignment: Alignment.center,
                                      child: new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Text(
                                          chap.number.toString(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.button,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        )
                        .toList()),
              ),
              isExpanded: book.isExpanded);
        }
      
        void _handlePress() {
          HapticFeedback.vibrate();
          
  }
}

class Verses extends StatelessWidget {
  final Chapter chapter;
  final Book book;
  final Function(DismissDirection) swipeAction;
  final bool addBackgrounds;
  final LongPressGestureRecognizer longPressRecognizer;


  Verses(this.chapter, this.book, this.swipeAction, this.addBackgrounds, [this.longPressRecognizer]);

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
                        style: new TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0)),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RichText(
                text: new TextSpan(
                    children: chapterText,
                    style: new TextStyle(color: Colors.black, fontSize: 20.0)),
              ),
            ),
          ],
        ),
      ),
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

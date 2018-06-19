import 'dart:async';

import 'package:bible_app/Model/Chapter.dart';
import 'package:bible_app/Model/Verse.dart';
import 'package:xml/xml.dart' as xml;
import 'package:bible_app/Model/Book.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BibleImporter {
  xml.XmlDocument xmlDocument;

  BibleImporter(String xmlFile)  {
    //var file = new File(filePath);
    //var xmlFile = filePath;
    xmlDocument = xml.parse(xmlFile);
  }

  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/ESV.xml');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();

      return body;
    } catch (e) {
      return e.toString();
    }
  }

  List<Book> getAllBooks() {
    var xmlBooks = xmlDocument.findAllElements("b");
    var books = new List<Book>();
    for (var item in xmlBooks) {
      var book = convertBookFromXml(item);
      books.add(book);
    }
    return books;
  }

  Book convertBookFromXml(xml.XmlElement item) {
    var book = new Book();
    book.name = item.getAttribute("n");
    book.chapters = getChapters(item);
    return book;
  }

  Book getBook(String name){
    var xmlBooks = xmlDocument.findAllElements("b");
    var xmlBook = xmlBooks.firstWhere((n) => n.getAttribute("n") == name);
    var book = convertBookFromXml(xmlBook);
    return book;
  } 

  Chapter getChapter(String bookName, int chapterNumber) {
    return this.getBook(bookName).chapters[chapterNumber - 1];
  }
      
 List<Chapter> getChapters(xml.XmlElement xmlBook) {
   var xmlChapters = xmlBook.findAllElements("c");
   List<Chapter> chapters = new List<Chapter>();
   for (var item in xmlChapters) {
     var chapter = new Chapter();
     chapter.number = int.parse(item.getAttribute("n"));
     chapter.verses = this.getVerses(item);
     chapters.add(chapter);
    }
    return chapters;
  }
     
  List<Verse> getVerses(xml.XmlElement xmlChapter) {
    var xmlVerses = xmlChapter.findAllElements("v");
    List<Verse> verses = new List<Verse>();
    for (var item in xmlVerses) {
      var verse = new Verse();
      verse.number = int.parse(item.getAttribute("n"));
      verse.text = item.text;
      verses.add(verse);    
    }
    return verses;
  }

  
 
}
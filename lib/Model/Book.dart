import 'Chapter.dart';  

class Book {
  String name;
  List<Chapter> chapters;
  bool isExpanded = false;

  Chapter getChapter(int chapterNumber) {
    if (chapterNumber < 0 || chapterNumber > chapters.length) {
      throw new ArgumentError("This chapter doesn't exist in this book");
    }

    return chapters[chapterNumber -1];
  }
}
import 'Verse.dart';    
class Chapter {
  List<Verse> verses;
  int number;

  Verse getVerse(int verseNumber) {
    if (verseNumber < 0 || verseNumber > verses.length) {
      throw new ArgumentError("This verse doesn't exist in this chapter");
    }

    return verses[verseNumber -1];
  }
}
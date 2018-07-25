import 'package:bible_app/Models/Book.dart';
import 'package:json_annotation/json_annotation.dart';

part 'AppState.g.dart';

@JsonSerializable()
class AppState extends Object with _$AppStateSerializerMixin {
  Book currentBook;
  int currentChapter;
  AppState() {
    currentBook = null;
    currentChapter = 0;
  }

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  bool isValid() {
    return currentBook != null &&
        currentChapter > 0 &&
        currentBook.name != null &&
        currentBook.name != "";
  }
}

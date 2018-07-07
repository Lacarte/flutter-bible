import 'Chapter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Book.g.dart';

@JsonSerializable()
class Book extends Object with _$BookSerializerMixin {
  String name;

  @JsonKey(ignore: true)
  List<Chapter> chapters;
  bool isExpanded = false;
  Book() {
    name = "";
    chapters = new List<Chapter>();
  }

  Chapter getChapter(int chapterNumber) {
    if (chapterNumber < 0 || chapterNumber > chapters.length) {
      throw new ArgumentError("This chapter doesn't exist in this book");
    }

    return chapters[chapterNumber - 1];
  }

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

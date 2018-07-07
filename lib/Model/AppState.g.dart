// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppState.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => new AppState()
  ..currentBook = json['currentBook'] == null
      ? null
      : new Book.fromJson(json['currentBook'] as Map<String, dynamic>)
  ..currentChapter = json['currentChapter'] as int;

abstract class _$AppStateSerializerMixin {
  Book get currentBook;
  int get currentChapter;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'currentBook': currentBook,
        'currentChapter': currentChapter
      };
}

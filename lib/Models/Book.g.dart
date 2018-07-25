// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => new Book()
  ..name = json['name'] as String
  ..isExpanded = json['isExpanded'] as bool;

abstract class _$BookSerializerMixin {
  String get name;
  bool get isExpanded;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'isExpanded': isExpanded};
}

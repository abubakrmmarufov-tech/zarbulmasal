import 'package:flutter/foundation.dart';
import 'source_ref.dart';

@immutable
class Poem {
  final String id;
  final String poetId;
  final String title;
  final String text;
  final String? script;
  final bool isExcerpt;
  final List<SourceRef> sourceRefs;

  const Poem({
    required this.id,
    required this.poetId,
    required this.title,
    required this.text,
    this.script,
    required this.isExcerpt,
    required this.sourceRefs,
  });

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'] as String,
      poetId: json['poetId'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      script: json['script'] as String?,
      isExcerpt: json['isExcerpt'] as bool? ?? false,
      sourceRefs:
          (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

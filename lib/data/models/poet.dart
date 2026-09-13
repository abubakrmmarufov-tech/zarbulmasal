import 'package:flutter/foundation.dart';
import 'source_ref.dart';

@immutable
class Poet {
  final String id;
  final String nameTj;
  final String? namePersian;
  final String? penName;
  final String? birthYear;
  final String? deathYear;
  final String? birthplace;
  final String? period;
  final String? biography;
  final List<SourceRef> sourceRefs;

  const Poet({
    required this.id,
    required this.nameTj,
    this.namePersian,
    this.penName,
    this.birthYear,
    this.deathYear,
    this.birthplace,
    this.period,
    this.biography,
    required this.sourceRefs,
  });

  factory Poet.fromJson(Map<String, dynamic> json) {
    return Poet(
      id: json['id'] as String,
      nameTj: json['nameTj'] as String,
      namePersian: json['namePersian'] as String?,
      penName: json['penName'] as String?,
      birthYear: json['birthYear'] as String?,
      deathYear: json['deathYear'] as String?,
      birthplace: json['birthplace'] as String?,
      period: json['period'] as String?,
      biography: json['biography'] as String?,
      sourceRefs:
          (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

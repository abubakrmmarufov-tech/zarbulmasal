// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void main() {
  print('--- Validating Literature JSON Files ---');

  // 1. Validate poets.json
  print('1. Validating poets.json...');
  final poetsFile = File('assets/data/literature/poets.json');
  assert(poetsFile.existsSync(), 'poets.json does not exist');
  final poetsList = jsonDecode(poetsFile.readAsStringSync()) as List<dynamic>;
  assert(poetsList.length >= 170, 'poets.json should contain at least 170 poets, found ${poetsList.length}');

  final authorIds = <String>{};

  for (var i = 0; i < poetsList.length; i++) {
    final map = poetsList[i] as Map<String, dynamic>;
    final author = LiteraryAuthor.fromJson(map);
    assert(author.id.isNotEmpty, 'Poet $i has empty id');
    authorIds.add(author.id);
    assert(author.canonicalName.isNotEmpty, 'Poet ${author.id} has empty canonicalName');
    assert(author.rights.reasoning.isNotEmpty, 'Poet ${author.id} rights reasoning should not be empty');
    assert(
      author.rights.status != RightsStatus.unknown,
      'Poet ${author.id} rights status should not be unknown',
    );
  }
  print('  ✓ poets.json contains ${poetsList.length} valid LiteraryAuthor entries');

  // 2. Validate works.json
  print('2. Validating works.json...');
  final worksFile = File('assets/data/literature/works.json');
  assert(worksFile.existsSync(), 'works.json does not exist');
  final worksList = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
  assert(worksList.length >= 1400, 'works.json should contain at least 1400 works, found ${worksList.length}');

  for (final item in worksList) {
    final map = item as Map<String, dynamic>;
    final work = LiteraryWork.fromJson(map);
    assert(work.id.isNotEmpty, 'Work has empty id');
    assert(work.authorId.isNotEmpty, 'Work ${work.id} has empty authorId');
    assert(authorIds.contains(work.authorId), 'Work ${work.id} points to unknown author: ${work.authorId}');
    assert(work.title.isNotEmpty, 'Work ${work.id} has empty title');
    assert(work.textTajik != null && work.textTajik!.isNotEmpty, 'Work ${work.id} has empty textTajik');
    assert(work.primarySource != null, 'Work ${work.id} is missing primarySource');
    assert(work.rights.reasoning.isNotEmpty, 'Work ${work.id} rights reasoning is empty');
    
    // Quarantine verification
    if (!work.verification.secondSourceChecked) {
      assert(work.verification.finalStatus == VerificationStatus.needsReview, 'Work ${work.id} has only 1 witness but is approved');
    }
  }
  print('  ✓ works.json contains ${worksList.length} valid LiteraryWork entries with correct references');

  print('\nALL LITERATURE JSON FILES VALIDATED SUCCESSFULLY!');
}

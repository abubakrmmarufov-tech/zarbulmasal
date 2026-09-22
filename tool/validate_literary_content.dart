// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() {
  print('Starting Literary Content Validation...');

  final poetsFile = File('assets/data/literature/poets.json');
  final worksFile = File('assets/data/literature/works.json');
  final sourcesFile = File('assets/data/literature/sources.json');
  final canonFile = File('assets/data/literature/school_canon.json');
  final oralFile = File('assets/data/literature/oral_heritage.json');

  if (!poetsFile.existsSync() ||
      !worksFile.existsSync() ||
      !sourcesFile.existsSync() ||
      !canonFile.existsSync() ||
      !oralFile.existsSync()) {
    print('Error: JSON data files missing in assets/data/literature/');
    exit(1);
  }

  final poets = jsonDecode(poetsFile.readAsStringSync()) as List;
  final works = jsonDecode(worksFile.readAsStringSync()) as List;
  final sources = jsonDecode(sourcesFile.readAsStringSync()) as List;
  jsonDecode(canonFile.readAsStringSync()) as List;
  final oralEntries = jsonDecode(oralFile.readAsStringSync()) as List;

  int approved = 0;
  int sourceAttested = 0;
  int primaryChecked = 0;
  int rejected = 0;
  int needsReview = 0;
  int publicDomain = 0;
  int excerptOnly = 0;
  int missingSecondSource = 0;
  int primaryCheckedMissingSecondSource = 0;
  int missingPage = 0;
  int missingRights = 0;
  int pendingMissingSecondSource = 0;
  int pendingMissingPage = 0;
  int pendingMissingTextAudit = 0;
  int pendingMissingScriptAudit = 0;
  int pendingIncompleteSource = 0;

  final poetIds = <String>{};
  final workIds = <String>{};
  final sourceIds = <String>{};
  final oralIds = <String>{};
  const recognizedEvidenceLevels = {
    'extracted',
    'sourceLocated',
    'primaryChecked',
    'secondWitnessLocated',
    'collated',
    'editoriallyApproved',
    'rejected',
    'needsReview',
  };

  // Validate sources
  for (final source in sources) {
    if (sourceIds.contains(source['id'])) {
      print("Violation: Duplicate source ID: ${source['id']}");
      exit(1);
    }
    sourceIds.add(source['id']);
  }

  // Validate oral heritage rights and distribution boundaries.
  for (final oral in oralEntries) {
    final id = oral['id'];
    if (id is! String || id.trim().isEmpty || !oralIds.add(id)) {
      print('Violation: Duplicate or missing oral heritage ID: $id');
      exit(1);
    }
    final rights = oral['rights'];
    if (rights is! Map || rights['status'] is! String) {
      print('Violation: Oral entry missing rights record: $id');
      exit(1);
    }
    final hasText =
        oral['text'] is String && (oral['text'] as String).trim().isNotEmpty;
    final hasPersianText =
        oral['textPersian'] is String &&
        (oral['textPersian'] as String).trim().isNotEmpty;
    if (rights['status'] == 'unknown' &&
        (rights['fullTextAllowed'] == true ||
            rights['excerptAllowed'] == true)) {
      print('Violation: Oral entry has inconsistent unknown rights: $id');
      exit(1);
    }
    if (rights['fullTextAllowed'] != true && (hasText || hasPersianText)) {
      print('Violation: Oral entry without full-text rights ships text: $id');
      exit(1);
    }
    if (rights['fullTextAllowed'] == true && !hasText) {
      print('Violation: Cleared oral entry is missing Tajik text: $id');
      exit(1);
    }
  }

  // Validate poets
  for (final poet in poets) {
    if (poetIds.contains(poet['id'])) {
      print("Violation: Duplicate poet ID: ${poet['id']}");
      exit(1);
    }
    poetIds.add(poet['id']);

    final rights = poet['rights'];
    if (rights == null) {
      missingRights++;
      print("Violation: Poet missing rights record: ${poet['id']}");
      exit(1);
    }
    if (rights['status'] == 'publicDomain') publicDomain++;
    if (rights['status'] == 'excerptOnly') excerptOnly++;
  }

  // Validate works
  for (final work in works) {
    if (workIds.contains(work['id'])) {
      print("Violation: Duplicate work ID: ${work['id']}");
      exit(1);
    }
    workIds.add(work['id']);

    if (!poetIds.contains(work['authorId'])) {
      print("Violation: Work references unknown authorId: ${work['authorId']}");
      exit(1);
    }

    final verification = work['verification'];
    final rights = work['rights'];
    final textStatus = work['textStatus'];

    final evidenceLevel = verification is Map
        ? verification['evidenceLevel']
        : null;
    if (evidenceLevel is! String ||
        !recognizedEvidenceLevels.contains(evidenceLevel)) {
      print('Violation: Work has unknown evidence level: ${work['id']}');
      exit(1);
    }

    if (verification is! Map ||
        verification['evidenceLevel'] is! String ||
        verification['evidenceLevel'].toString().trim().isEmpty) {
      print("Violation: Work has invalid verification record: ${work['id']}");
      exit(1);
    }

    if (rights == null) {
      missingRights++;
      print("Violation: Work missing rights record: ${work['id']}");
      exit(1);
    }

    if (rights is! Map ||
        rights['status'] is! String ||
        rights['reasoning'] is! String ||
        rights['reasoning'].toString().trim().isEmpty) {
      print("Violation: Work has incomplete rights record: ${work['id']}");
      exit(1);
    }
    if (rights['status'] == 'sourceAttested') sourceAttested++;

    final primary = work['primarySource'];
    if (primary is! Map ||
        primary['bookTitle'] is! String ||
        primary['bookTitle'].toString().trim().isEmpty ||
        primary['sourceType'] is! String ||
        primary['sourceType'].toString().trim().isEmpty) {
      print("Violation: Work has incomplete primary source: ${work['id']}");
      exit(1);
    }

    final hasPage = primary['pageStart'] is int;
    final hasSecondSource = work['secondarySource'] is Map;
    final hasPublisher =
        primary['publisher'] is String &&
        primary['publisher'].toString().trim().isNotEmpty;
    final hasCity =
        primary['city'] is String &&
        primary['city'].toString().trim().isNotEmpty;
    final isPending = evidenceLevel == 'needsReview';

    final hasTajikText =
        work['textTajik'] is String &&
        work['textTajik'].toString().trim().isNotEmpty;
    final hasPersianText =
        work['textPersian'] is String &&
        work['textPersian'].toString().trim().isNotEmpty;
    final hasGeneratedRepresentation =
        work['persianScriptRepresentation'] is String &&
        work['persianScriptRepresentation'].toString().trim().isNotEmpty;
    final hasIncipit =
        work['incipit'] is String &&
        work['incipit'].toString().trim().isNotEmpty;
    if (rights['fullTextAllowed'] != true &&
        (hasTajikText || hasPersianText || hasGeneratedRepresentation)) {
      print(
        'Violation: Work without full-text rights ships text content: ${work['id']}',
      );
      exit(1);
    }
    if (rights['excerptAllowed'] != true && hasIncipit) {
      print(
        'Violation: Work without excerpt rights ships an incipit: ${work['id']}',
      );
      exit(1);
    }

    final compositionDate = work['compositionDate'];
    final compositionContext = work['compositionContext'];
    final hasCompositionMetadata =
        (compositionDate is String && compositionDate.trim().isNotEmpty) ||
        (compositionContext is String && compositionContext.trim().isNotEmpty);
    if (hasCompositionMetadata &&
        (!hasPage || verification['pageVerified'] != true)) {
      print(
        'Violation: Composition metadata lacks a page-checked source: ${work['id']}',
      );
      exit(1);
    }

    if (isPending) {
      needsReview++;
      if (!hasPage) pendingMissingPage++;
      if (!hasSecondSource) pendingMissingSecondSource++;
      if (verification['textLineByLineChecked'] != true) {
        pendingMissingTextAudit++;
      }
      if (verification['scriptChecked'] != true) {
        pendingMissingScriptAudit++;
      }
      if (!hasPublisher || !hasCity) pendingIncompleteSource++;
    }

    if (evidenceLevel == 'primaryChecked') {
      primaryChecked++;
      if (!hasSecondSource) primaryCheckedMissingSecondSource++;
      if (!hasPage || verification['pageVerified'] != true) {
        print(
          'Violation: Primary-checked work is missing a documented page: ${work['id']}',
        );
        exit(1);
      }
      if (rights['fullTextAllowed'] == true &&
          rights['status'] != 'sourceAttested') {
        print(
          'Violation: Primary-checked work needs sourceAttested publication status: ${work['id']}',
        );
        exit(1);
      }
      if (rights['status'] == 'sourceAttested' &&
          (textStatus != 'verified' || !hasTajikText)) {
        print(
          'Violation: Source-attested work is missing verified Tajik text: ${work['id']}',
        );
        exit(1);
      }
    } else if (evidenceLevel == 'editoriallyApproved') {
      approved++;
      if (textStatus != 'verified') {
        print(
          "Violation: Approved work does not have verified textStatus: ${work['id']}",
        );
        exit(1);
      }
      if (work['primarySource'] == null) {
        print("Violation: Approved work missing primarySource: ${work['id']}");
        exit(1);
      }
      if (!hasPublisher || !hasCity) {
        print(
          "Violation: Approved work has incomplete source citation: ${work['id']}",
        );
        exit(1);
      }
      if (rights['status'] == 'unknown' || rights['status'] == 'blocked') {
        print(
          "Violation: Approved work has unknown/blocked rights: ${work['id']}",
        );
        exit(1);
      }

      if (!hasPage || verification['pageVerified'] != true) {
        print(
          'Violation: Approved work is missing a documented primary-source page: ${work['id']}',
        );
        exit(1);
      }
      if (!hasSecondSource) {
        missingSecondSource++;
      }
      if (verification['textLineByLineChecked'] != true ||
          verification['scriptChecked'] != true ||
          verification['secondSourceChecked'] != true) {
        print(
          "Violation: Approved work has incomplete verification checks: ${work['id']}",
        );
        exit(1);
      }
    } else if (evidenceLevel == 'rejected') {
      rejected++;
    }
  }

  print('''
Validation Summary:
-------------------
TOTAL AUTHORS: ${poets.length}
TOTAL WORKS: ${works.length}
EDITORIALLY APPROVED: $approved
SOURCE ATTESTED READABLE: $sourceAttested
PRIMARY CHECKED: $primaryChecked
REJECTED: $rejected
NEEDS REVIEW: $needsReview
PUBLIC DOMAIN AUTHORS: $publicDomain
EXCERPT ONLY AUTHORS: $excerptOnly
MISSING SECOND SOURCE: $missingSecondSource
PRIMARY CHECKED MISSING SECOND SOURCE: $primaryCheckedMissingSecondSource
MISSING PAGE NUMBER: $missingPage
MISSING RIGHTS EVIDENCE: $missingRights
PENDING MISSING SECOND SOURCE: $pendingMissingSecondSource
PENDING MISSING PAGE NUMBER: $pendingMissingPage
PENDING MISSING LINE AUDIT: $pendingMissingTextAudit
PENDING MISSING SCRIPT AUDIT: $pendingMissingScriptAudit
PENDING INCOMPLETE SOURCE DETAILS: $pendingIncompleteSource
''');

  print('Validation Passed.');
  exit(0);
}

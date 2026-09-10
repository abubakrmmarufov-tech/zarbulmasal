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
  final canon = jsonDecode(canonFile.readAsStringSync()) as List;
  final oral = jsonDecode(oralFile.readAsStringSync()) as List;

  int approved = 0;
  int rejected = 0;
  int needsReview = 0;
  int publicDomain = 0;
  int excerptOnly = 0;
  int missingSecondSource = 0;
  int missingPage = 0;
  int missingRights = 0;

  final poetIds = <String>{};
  final workIds = <String>{};
  final sourceIds = <String>{};

  // Validate sources
  for (final source in sources) {
    if (sourceIds.contains(source['id'])) {
      print("Violation: Duplicate source ID: ${source['id']}");
      exit(1);
    }
    sourceIds.add(source['id']);
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

    final verification = work['verification'] ?? {};
    final rights = work['rights'];
    final textStatus = work['textStatus'];

    if (rights == null) {
      missingRights++;
      print("Violation: Work missing rights record: ${work['id']}");
      exit(1);
    }

    if (verification['finalStatus'] == 'approved') {
      approved++;
      if (textStatus != 'verified') {
        print("Violation: Approved work does not have verified textStatus: ${work['id']}");
        exit(1);
      }
      if (work['primarySource'] == null) {
        print("Violation: Approved work missing primarySource: ${work['id']}");
        exit(1);
      }
      if (rights['status'] == 'unknown' || rights['status'] == 'blocked') {
        print("Violation: Approved work has unknown/blocked rights: ${work['id']}");
        exit(1);
      }
      
      final primary = work['primarySource'];
      if (primary['pageStart'] == null) {
        missingPage++;
      }
      if (work['secondarySource'] == null) {
        missingSecondSource++;
      }
    } else if (verification['finalStatus'] == 'rejected') {
      rejected++;
    } else {
      needsReview++;
    }
  }

  print('''
Validation Summary:
-------------------
TOTAL AUTHORS: ${poets.length}
TOTAL WORKS: ${works.length}
APPROVED: $approved
REJECTED: $rejected
NEEDS REVIEW: $needsReview
PUBLIC DOMAIN AUTHORS: $publicDomain
EXCERPT ONLY AUTHORS: $excerptOnly
MISSING SECOND SOURCE: $missingSecondSource
MISSING PAGE NUMBER: $missingPage
MISSING RIGHTS EVIDENCE: $missingRights
''');

  print('Validation Passed.');
  exit(0);
}

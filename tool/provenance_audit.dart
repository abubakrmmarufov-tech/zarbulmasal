import 'dart:convert';
import 'dart:io';

void main() {
  final worksFile = File('assets/data/literature/works.json');
  if (!worksFile.existsSync()) {
    print('Works file not found.');
    return;
  }

  final rawWorks = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
  int total = rawWorks.length;
  
  Map<String, int> verificationLevels = {};
  Map<String, int> rejectionReasons = {};
  
  for (final work in rawWorks) {
    if (work is! Map<String, dynamic>) continue;
    
    final v = work['verification'] as Map<String, dynamic>?;
    final level = v?['evidenceLevel'] as String? ?? 'extracted';
    verificationLevels[level] = (verificationLevels[level] ?? 0) + 1;
    
    if (level == 'needsReview' || level == 'rejected' || level == 'extracted') {
      final reason = v?['rejectionReason'] as String? ?? 'Awaiting primary source or audit';
      rejectionReasons[reason] = (rejectionReasons[reason] ?? 0) + 1;
    }
  }

  print('================ PROVENANCE AUDIT ================');
  print('Total Works: $total');
  print('\n--- By Verification Level ---');
  for (final entry in verificationLevels.entries) {
    print('${entry.key}: ${entry.value}');
  }
  
  print('\n--- Unverified/Pending Reasons ---');
  for (final entry in rejectionReasons.entries) {
    print('${entry.key}: ${entry.value}');
  }
  print('==================================================');
}

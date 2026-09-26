import '../models/proverb.dart';
import 'seed_proverbs_part1.dart';
import 'seed_proverbs_part2.dart';
import 'seed_proverbs_part3.dart';
import 'seed_proverbs_part4.dart';
import 'seed_proverbs_part5.dart';
import 'seed_proverbs_part6.dart';
import 'seed_proverbs_part7.dart';
import 'seed_proverbs_part8.dart';

// Legacy IDs 1-20 quarantined during the content audit.
// IDs 21-170: the original catalogue, checked against the printed page in
// Phase 9. IDs 171-206: proverbs the textbooks print, added in Phase 9.
const List<Proverb> seedProverbs = [
  ...seedProverbsPart1,
  ...seedProverbsPart2,
  ...seedProverbsPart3,
  ...seedProverbsPart4,
  ...seedProverbsPart5,
  ...seedProverbsPart6,
  ...seedProverbsPart7,
  ...seedProverbsPart8,
];

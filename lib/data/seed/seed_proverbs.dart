import '../models/proverb.dart';
import 'seed_proverbs_part1.dart';
import 'seed_proverbs_part2.dart';
import 'seed_proverbs_part3.dart';
import 'seed_proverbs_part4.dart';

// Legacy IDs 1-20 quarantined during the content audit.
// Production corpus contains 150 verified Tajik proverbs (IDs 21-170).
const List<Proverb> seedProverbs = [
  ...seedProverbsPart1,
  ...seedProverbsPart2,
  ...seedProverbsPart3,
  ...seedProverbsPart4,
];

import 'literary_work.dart';
import 'verification_record.dart';

/// The three states of the «Муҳр» seal.
///
/// - [pressed]: the text was editorially approved.
/// - [outline]: the text was checked against a printed page, but editorial
///   approval is still pending.
/// - [absent]: the text is under review.
enum ProvenanceSeal { pressed, outline, absent }

/// A single, derived verification state for a [LiteraryWork].
///
/// Every surface that talks about verification (the reader's status line,
/// the seal, the source record) reads this one value, so the header can never
/// claim more than the record underneath it. It is derived only from
/// `verification.evidenceLevel`, `verification.pageVerified`, the secondary
/// witness, and the recorded collation result — never from the legacy
/// `textStatus` flag, which does not say whether editorial checks are done.
class ProvenanceState {
  const ProvenanceState._({
    required this.seal,
    required this.hasCollatedSecondWitness,
  });

  /// Which seal to show.
  final ProvenanceSeal seal;

  /// Whether an independent second printed witness was compared with the
  /// primary text (a collation result is recorded for it).
  final bool hasCollatedSecondWitness;

  bool get isEditoriallyApproved => seal == ProvenanceSeal.pressed;

  static const Set<VerificationLevel> _pageCheckedLevels = {
    VerificationLevel.primaryChecked,
    VerificationLevel.secondWitnessLocated,
    VerificationLevel.collated,
  };

  factory ProvenanceState.of(LiteraryWork work) {
    final verification = work.verification;
    final hasCollatedSecondWitness =
        work.secondarySource != null &&
        (work.textMatchResult?.trim().isNotEmpty ?? false);

    final ProvenanceSeal seal;
    if (verification.evidenceLevel == VerificationLevel.editoriallyApproved) {
      seal = ProvenanceSeal.pressed;
    } else if (_pageCheckedLevels.contains(verification.evidenceLevel) &&
        verification.pageVerified) {
      seal = ProvenanceSeal.outline;
    } else {
      seal = ProvenanceSeal.absent;
    }

    return ProvenanceState._(
      seal: seal,
      hasCollatedSecondWitness: hasCollatedSecondWitness,
    );
  }

  /// Translation key for the one-sentence status shown in the reader header
  /// and repeated, word for word, at the top of the source record.
  String get statusKey => switch (seal) {
    ProvenanceSeal.pressed => 'prov_status_approved',
    ProvenanceSeal.outline =>
      hasCollatedSecondWitness
          ? 'prov_status_checked_two'
          : 'prov_status_checked_one',
    ProvenanceSeal.absent => 'prov_status_review',
  };
}

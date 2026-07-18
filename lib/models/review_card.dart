class ReviewCard {
  final String id;
  final String frontText;
  final String backText;
  final String reading;
  final String romaji;
  final String meaning;
  final String notes;
  final int srsLevel;
  final DateTime nextReview;
  final List<String> tags;
  final String type; // 'sentence' or 'vocabulary'

  ReviewCard({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.reading,
    required this.romaji,
    required this.meaning,
    required this.notes,
    required this.srsLevel,
    required this.nextReview,
    required this.tags,
    required this.type,
  });
}

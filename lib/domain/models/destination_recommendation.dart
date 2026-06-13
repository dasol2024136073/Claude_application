class DestinationRecommendation {
  final String destination; // 예: "오사카, 일본"
  final String country;
  final String reason;
  final int days;
  final String emoji;
  final String? photoUrl;

  const DestinationRecommendation({
    required this.destination,
    required this.country,
    required this.reason,
    required this.days,
    required this.emoji,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'country': country,
        'reason': reason,
        'days': days,
        'emoji': emoji,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

  factory DestinationRecommendation.fromJson(Map<String, dynamic> json) => DestinationRecommendation(
        destination: json['destination'] as String,
        country: json['country'] as String,
        reason: json['reason'] as String,
        days: json['days'] as int,
        emoji: json['emoji'] as String? ?? '🌍',
        photoUrl: json['photoUrl'] as String?,
      );

  DestinationRecommendation copyWith({String? photoUrl}) => DestinationRecommendation(
        destination: destination,
        country: country,
        reason: reason,
        days: days,
        emoji: emoji,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}

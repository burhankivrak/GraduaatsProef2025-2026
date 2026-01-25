class Episode {
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String overview;
  final String airDate;

  Episode({
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.airDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
    );
  }
}

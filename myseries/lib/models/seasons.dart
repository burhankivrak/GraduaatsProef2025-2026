import 'episodes.dart';

class Season {
  final int id;
  final int seasonNumber;
  final String name;
  final String overview;
  final int episodeCount;
  final String airDate;
  final String posterPath;
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.episodeCount,
    required this.airDate,
    required this.posterPath,
    required this.episodes,
  });

  String get fullPosterUrl =>
      'https://image.tmdb.org/t/p/w500$posterPath';

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      episodeCount: json['episode_count'] ?? 0,
      airDate: json['air_date'] ?? '',
      posterPath: json['poster_path'] ?? '',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

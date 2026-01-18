import 'seasons.dart';

class SeriesDetail {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String? firstAirDate;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final double voteAverage;
  final List<String> genres;
  final List<Season> seasons;

  SeriesDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    this.firstAirDate,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.voteAverage,
    required this.genres,
    required this.seasons,
  });

  factory SeriesDetail.fromJson(Map<String, dynamic> json) {
    return SeriesDetail(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      firstAirDate: json['first_air_date'],
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g['name'] as String)
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>?)
        ?.map((s) => Season.fromJson(s))
        .toList() ?? [],
    );
  }

  String get fullPosterUrl =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropUrl =>
      backdropPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';

  String get year {
    if (firstAirDate == null || firstAirDate!.isEmpty) return '—';
    return firstAirDate!.split('-').first;
  }
}

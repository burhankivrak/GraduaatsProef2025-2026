class Series {
  final int id;
  final String name;
  final String posterPath;
  final String? firstAirDate;

  Series({
    required this.id,
    required this.name,    required this.posterPath,
    this.firstAirDate,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      name: json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      firstAirDate: json['first_air_date'],
    );
  }

  String get fullPosterUrl {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
  String get year {
    if (firstAirDate == null || firstAirDate!.isEmpty) return '—';
    return firstAirDate!.split('-').first;
  }
}
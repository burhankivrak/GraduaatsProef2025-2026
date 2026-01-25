enum WatchStatusEnum {
  watching,
  toWatch,
  paused,
}

extension WatchStatus on WatchStatusEnum {
  String get value {
    switch (this) {
      case WatchStatusEnum.watching:
        return 'watching';
      case WatchStatusEnum.toWatch:
        return 'to_watch';
      case WatchStatusEnum.paused:
        return 'paused';
    }
  }

  static WatchStatusEnum fromString(String value) {
    switch (value) {
      case 'watching':
        return WatchStatusEnum.watching;
      case 'paused':
        return WatchStatusEnum.paused;
      default:
        return WatchStatusEnum.toWatch;
    }
  }
}

class WatchlistSeries {
  final int id;
  final String name;
  final String posterPath;
  final String? firstAirDate;
  final List<String> genres;
  final WatchStatusEnum status;
  final String? listName;
  final int? lastSeason;
  final int? lastEpisode;

  WatchlistSeries({
    required this.id,
    required this.name,
    required this.posterPath,
    this.firstAirDate,
    required this.genres,
    required this.status,
    this.listName,
    this.lastSeason,
    this.lastEpisode,
  });

  factory WatchlistSeries.fromMap(Map<String, dynamic> map) {
    return WatchlistSeries(
      id: map['id'],
      name: map['name'],
      posterPath: map['posterPath'],
      firstAirDate: map['firstAirDate'],
      genres: List<String>.from(map['genres'] ?? []),
      status: WatchStatus.fromString(map['status']),
      listName: map['listName'],
      lastSeason: map['lastSeason'],
      lastEpisode: map['lastEpisode'],
    );
  }
}


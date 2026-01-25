import 'package:flutter/material.dart';
import '../models/watchlist.dart';
import '../services/watchlist_service.dart';
import '../services/tmdb_service.dart';

class WatchlistCard extends StatefulWidget {
  final WatchlistSeries series;
  final VoidCallback onTap;

  const WatchlistCard({
    super.key,
    required this.series,
    required this.onTap,
  });

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard> {
  final WatchlistService _watchlistService = WatchlistService();
  final TmdbService _tmdbService = TmdbService();

  late int _season;
  late int _episode;

  int _maxSeasons = 1;
  int _maxEpisodes = 1;

  @override
  void initState() {
    super.initState();
    _season = widget.series.lastSeason ?? 1;
    _episode = widget.series.lastEpisode ?? 1;
    _loadSeriesDetails();
  }

  @override
  void didUpdateWidget(WatchlistCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.id != widget.series.id) {
      _season = widget.series.lastSeason ?? 1;
      _episode = widget.series.lastEpisode ?? 1;
      _maxSeasons = 1;
      _maxEpisodes = 1;
      _loadSeriesDetails();
      return;
    }

    if (oldWidget.series.lastSeason != widget.series.lastSeason ||
        oldWidget.series.lastEpisode != widget.series.lastEpisode) {
      setState(() {
        _season = widget.series.lastSeason ?? 1;
        _episode = widget.series.lastEpisode ?? 1;
      });
    }
  }

  Future<void> _loadSeriesDetails() async {
    try {
      final detail = await _tmdbService.getSeriesDetail(widget.series.id);
      if (!mounted) return;
      setState(() {
        _maxSeasons = detail.seasons.isNotEmpty ? detail.seasons.length : 1;
        _maxEpisodes = 1;
      });
      await _loadEpisodesForSeason(_season);
    } catch (e) {
      debugPrint('Error loading series details: $e');
    }
  }

  Future<void> _loadEpisodesForSeason(int seasonNumber) async {
    try {
      final episodes = await _tmdbService.getSeasonEpisodes(widget.series.id, seasonNumber);
      if (!mounted) return;
      setState(() {
        _maxEpisodes = episodes.isNotEmpty ? episodes.length : 1;
        if (_episode > _maxEpisodes) _episode = _maxEpisodes;
      });
    } catch (e) {
      debugPrint('Error loading season episodes: $e');
    }
  }

  Future<int> _fetchEpisodesCount(int seasonNumber) async {
    try {
      final episodes = await _tmdbService.getSeasonEpisodes(widget.series.id, seasonNumber);
      return episodes.isNotEmpty ? episodes.length : 1;
    } catch (e) {
      debugPrint('Error fetching episodes count: $e');
      return 1;
    }
  }

  void _showEpisodeEditor() {
    int tempSeason = _season.clamp(1, _maxSeasons);
    int tempEpisode = _episode.clamp(1, _maxEpisodes);
    int tempMaxEpisodes = _maxEpisodes;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E252D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Update Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Season selector
                  Text(
                    'Season: $tempSeason',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: tempSeason.toDouble(),
                    min: 1,
                    max: _maxSeasons.toDouble(),
                    divisions: _maxSeasons > 1 ? _maxSeasons - 1 : null,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.white24,
                    onChanged: (value) async {
                      final newSeason = value.toInt();
                      setModalState(() {
                        tempSeason = newSeason;
                        tempEpisode = 1;
                      });
                      final count = await _fetchEpisodesCount(newSeason);
                      if (mounted) {
                        setModalState(() {
                          tempMaxEpisodes = count;
                          if (tempEpisode > tempMaxEpisodes) {
                            tempEpisode = tempMaxEpisodes;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Episode: $tempEpisode',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: tempEpisode.toDouble(),
                    min: 1,
                    max: tempMaxEpisodes.toDouble(),
                    divisions: tempMaxEpisodes > 1 ? tempMaxEpisodes - 1 : null,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setModalState(() {
                        tempEpisode = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                          onPressed: () async {
                            await _watchlistService.updateLastWatched(
                              widget.series.id,
                              tempSeason,
                              tempEpisode,
                            );
                            if (mounted) {
                              setState(() {
                                _season = tempSeason;
                                _episode = tempEpisode;
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF313743),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Container(
              width: 100,
                height: 140,
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.series.posterPath.isNotEmpty
                    ? Image.network(
                        widget.series.posterPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF313743),
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF313743),
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(
                      widget.series.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.series.status == WatchStatusEnum.watching ||
                        widget.series.status == WatchStatusEnum.paused)
                      GestureDetector(
                        onTap: _showEpisodeEditor,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (widget.series.status == WatchStatusEnum.paused
                                    ? Colors.orange
                                    : Colors.blueAccent)
                                .withOpacity(0.2),
                            border: Border.all(
                              color: widget.series.status == WatchStatusEnum.paused
                                  ? Colors.orange
                                  : Colors.blueAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

  
                              Text(
                                'S$_season:E$_episode',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

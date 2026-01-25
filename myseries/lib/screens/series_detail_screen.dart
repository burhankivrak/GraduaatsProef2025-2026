import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/serie_detail.dart';
import '../models/series.dart';
import '../models/watchlist.dart';
import '../services/tmdb_service.dart';
import '../services/ratings_service.dart';
import '../services/watchlist_service.dart';

import 'season_episodes_screen.dart';
import 'trailer_player_screen.dart';

class SeriesDetailScreen extends StatefulWidget {
  final int seriesId;
  const SeriesDetailScreen({super.key, required this.seriesId});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  final WatchlistService _watchlistService = WatchlistService();

  SeriesDetail? _seriesDetail;
  bool _isLoading = true;

  List<String> _trailers = [];
  YoutubePlayerController? _youtubeController;

  WatchStatusEnum? _watchStatus;
  bool _showWatchlistMenu = false;

  @override
  void initState() {
    super.initState();
    _loadSeriesDetail();
    _loadWatchStatus();
  }

  Future<void> _loadWatchStatus() async {
    final status = await _watchlistService.getStatus(widget.seriesId);
    setState(() => _watchStatus = status);
  }

  Future<void> _showRatingEditor(int currentRating) async {
    int selected = currentRating;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E252D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        double sliderVal = selected.toDouble();
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Edit rating',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow[400]),
                    const SizedBox(width: 8),
                    Text(
                      '${sliderVal.toInt()}/10',
                      style: TextStyle(color: Colors.yellow[400], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(10, (i) {
                    final val = i + 1;
                    final filled = val <= sliderVal.toInt();
                    return GestureDetector(
                      onTap: () async {
                        final s = Series(
                          id: _seriesDetail!.id,
                          name: _seriesDetail!.name,
                          posterPath: _seriesDetail!.posterPath,
                          firstAirDate: _seriesDetail!.firstAirDate,
                        );
                        Navigator.pop(context);
                        if (val == currentRating) {
                          await RatingsService().removeRating(widget.seriesId);
                        } else {
                          await RatingsService().addRating(s, val);
                        }
                      },
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: filled ? Colors.yellow[400] : Colors.white54,
                        size: 28,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (currentRating > 0)
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await RatingsService().removeRating(widget.seriesId);
                        },
                        child: const Text('Remove', style: TextStyle(color: Colors.white70)),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _loadSeriesDetail() async {
    try {
      final detail = await _tmdbService.getSeriesDetail(widget.seriesId);
      final trailers = await _tmdbService.getSeriesTrailers(widget.seriesId);

      setState(() {
        _seriesDetail = detail;
        _trailers = trailers;
        _isLoading = false;
      });

      if (_trailers.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: _trailers.first,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading series detail: $e');
    }
  }

  Future<void> _setWatchStatus(WatchStatusEnum status) async {
    final existing = await _watchlistService.getWatchlist(widget.seriesId);
    final existingSeason = existing?['lastSeason'] as int?;
    final existingEpisode = existing?['lastEpisode'] as int?;
    final existingListName = existing?['listName'] as String?;

    int? lastSeason;
    int? lastEpisode;

    if (status == WatchStatusEnum.watching || status == WatchStatusEnum.paused) {
      lastSeason = existingSeason ?? 1;
      lastEpisode = existingEpisode ?? 1;
    } else {
      lastSeason = existingSeason;
      lastEpisode = existingEpisode;
    }

    final s = WatchlistSeries(
      id: _seriesDetail!.id,
      name: _seriesDetail!.name,
      posterPath: _seriesDetail!.fullPosterUrl,
      firstAirDate: _seriesDetail!.firstAirDate,
      genres: _seriesDetail!.genres,
      status: status,
      listName: existingListName,
      lastSeason: lastSeason,
      lastEpisode: lastEpisode,
    );

    await _watchlistService.addOrUpdateWatchlist(s);
    setState(() {
      _watchStatus = status;
      _showWatchlistMenu = false;
    });
  }

  Future<void> _removeFromWatchlist() async {
    await _watchlistService.remove(widget.seriesId);
    setState(() {
      _watchStatus = null;
      _showWatchlistMenu = false;
    });
  }

  void _playTrailer() {
    if (_youtubeController == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TrailerPlayerScreen(controller: _youtubeController!),
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      body: _isLoading || _seriesDetail == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                // Backdrop
                if (_seriesDetail!.backdropPath.isNotEmpty)
                  Image.network(
                    _seriesDetail!.fullBackdropUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 220,
                      color: const Color(0xFF1E252D),
                    ),
                  ),

                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF1E252D),
                        Color(0x801E252D),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 218,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 143, 143, 143).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Top buttons
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleButton(
                                Icons.arrow_back,
                                () => Navigator.pop(context),
                              ),
                              Column(
                                children: [
                                  _circleButton(
                                    Icons.bookmark,
                                    () => setState(() {
                                      _showWatchlistMenu =
                                          !_showWatchlistMenu;
                                    }),
                                    active: _watchStatus != null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Poster + title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Poster
                              Container(
                                width: 110,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _seriesDetail!.fullPosterUrl.isNotEmpty
                                      ? Image.network(
                                          _seriesDetail!.fullPosterUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: const Color(0xFF313743),
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white54,
                                              size: 40,
                                            ),
                                          ),
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

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _seriesDetail!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 16, color: Colors.yellow),
                                        const SizedBox(width: 6),
                                        Text(
                                          _seriesDetail!.voteAverage
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    StreamBuilder<int?>(
                                      stream: RatingsService()
                                          .rating(widget.seriesId),
                                      builder: (context, snap) {
                                        final userRating = snap.data ?? 0;
                                        return Row(
                                          children: [
                                            const Text(
                                              'Your rating:',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => _showRatingEditor(userRating),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star,
                                                        size: 14,
                                                        color: Colors.yellow[400]),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$userRating/10',
                                                      style: TextStyle(
                                                        color: Colors.yellow[400],
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Icon(Icons.edit,
                                                        size: 14,
                                                        color: Colors.white70),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_trailers.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _playTrailer,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play Trailer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(146, 20, 124, 188),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Info cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _infoCard(
                                  'Year',
                                  _seriesDetail!.year.toString(),
                                  Icons.calendar_today),
                              _infoCard(
                                  'Seasons',
                                  _seriesDetail!.numberOfSeasons.toString(),
                                  Icons.tv),
                              _infoCard(
                                  'Episodes',
                                  _seriesDetail!.numberOfEpisodes.toString(),
                                  Icons.play_circle_outline),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Overview
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _seriesDetail!.overview,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Seasons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seasons',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: _seriesDetail!.seasons.map((season) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          final eps =
                                              await _tmdbService
                                                  .getSeasonEpisodes(
                                                widget.seriesId,
                                                season.seasonNumber,
                                              );

                                          if (!mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SeasonEpisodesScreen(
                                                seriesId: widget.seriesId,
                                                seasonNumber:
                                                    season.seasonNumber,
                                                episodes: eps,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            log('Error loading season: $e');
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF313743),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: season.fullPosterUrl.isNotEmpty
                                                  ? Image.network(
                                                      season.fullPosterUrl,
                                                      width: 64,
                                                      height: 96,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Container(
                                                        width: 64,
                                                        height: 96,
                                                        color: const Color(0xFF313743),
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white54,
                                                          size: 28,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 64,
                                                      height: 96,
                                                      color: const Color(0xFF313743),
                                                      child: const Icon(
                                                        Icons.movie,
                                                        color: Colors.white54,
                                                        size: 28,
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    season.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${season.episodeCount} Episodes • '
                                                    '${DateTime.tryParse(season.airDate)?.year ?? '—'}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    season.overview,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_showWatchlistMenu)
                Positioned(
                  right: 12,
                  top: 70,
                  child: SafeArea(child: _watchlistMenu()),
                ),
              ],
            ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: active ? Colors.blueAccent : Colors.white,
        ),
      ),
    );
  }

  Widget _watchlistMenu() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF313743),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 180,
      child: Column(
        children: [
          _menuItem('Currently Watching', WatchStatusEnum.watching),
          _menuItem('To Watch', WatchStatusEnum.toWatch),
          _menuItem('Paused', WatchStatusEnum.paused),
          if (_watchStatus != null) ...[
            const Divider(color: Colors.white24),
            GestureDetector(
              onTap: _removeFromWatchlist,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Remove',
                        style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _menuItem(String label, WatchStatusEnum status) {
    final active = _watchStatus == status;
    return GestureDetector(
      onTap: () => _setWatchStatus(status),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            if (active)
              const Icon(Icons.check,
                  color: Colors.greenAccent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF313743),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

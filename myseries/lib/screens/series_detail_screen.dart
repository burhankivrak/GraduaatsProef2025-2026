import 'package:flutter/material.dart';
import '../models/serie_detail.dart';
import '../services/tmdb_service.dart';
import '../services/ratings_service.dart';
import '../models/series.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  SeriesDetail? _seriesDetail;
  bool _isLoading = true;

  List<String> _trailers = [];
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _loadSeriesDetail();
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

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _playTrailer() {
  if (_youtubeController == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TrailerPlayerScreen(
        controller: _youtubeController!,
      ),
    ),
  );
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
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                            ),
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
                                  child: Image.network(
                                    _seriesDetail!.fullPosterUrl,
                                    fit: BoxFit.cover,
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
                                        final eps =
                                            await _tmdbService
                                                .getSeasonEpisodes(
                                          widget.seriesId,
                                          season.seasonNumber,
                                        );

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
                                              child: Image.network(
                                                season.fullPosterUrl,
                                                width: 64,
                                                height: 96,
                                                fit: BoxFit.cover,
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
              ],
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

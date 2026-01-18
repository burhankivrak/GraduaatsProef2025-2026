import 'package:flutter/material.dart';
import '../models/serie_detail.dart';
import '../services/tmdb_service.dart';
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

                // Gradient overlay
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

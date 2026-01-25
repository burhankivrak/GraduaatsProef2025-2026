import 'package:flutter/material.dart';
import '../models/episodes.dart';
import '../services/watchlist_service.dart';
import '../widgets/episode_card.dart';

class SeasonEpisodesScreen extends StatefulWidget {
  final int seriesId;
  final int seasonNumber;
  final List<Episode> episodes;

  const SeasonEpisodesScreen({
    super.key,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodes,
  });

  @override
  State<SeasonEpisodesScreen> createState() => _SeasonEpisodesScreenState();
}

class _SeasonEpisodesScreenState extends State<SeasonEpisodesScreen> {
  final WatchlistService _watchlistService = WatchlistService();
  int? _currentSeason;
  int? _currentEpisode;

  @override
  void initState() {
    super.initState();
    _loadCurrentWatchStatus();
  }

  Future<void> _loadCurrentWatchStatus() async {
    final status = await _watchlistService.getStatus(widget.seriesId);
    if (status != null) {
      final doc = await _watchlistService.getWatchlist(widget.seriesId);
      setState(() {
        _currentSeason = doc?['lastSeason'] as int?;
        _currentEpisode = doc?['lastEpisode'] as int?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313743),
        title: Text('Season ${widget.seasonNumber} Episodes'),
        foregroundColor: Colors.white,
      ),
      body: widget.episodes.isEmpty
          ? const Center(
              child: Text(
                'Geen afleveringen gevonden',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                final ep = widget.episodes[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EpisodeCard(
                    episode: ep,
                    seriesId: widget.seriesId,
                    currentSeason: _currentSeason,
                    currentEpisode: _currentEpisode,
                  ),
                );
              },
            ),
    );
  }
}

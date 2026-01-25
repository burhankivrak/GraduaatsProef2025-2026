import 'package:flutter/material.dart';
import '../models/episodes.dart';

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final int seriesId;
  final int? currentSeason;
  final int? currentEpisode;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.seriesId,
    this.currentSeason,
    this.currentEpisode,
  });

  bool get _isCurrentEpisode {
    return currentSeason == episode.seasonNumber &&
        currentEpisode == episode.episodeNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isCurrentEpisode ? Colors.yellow.withOpacity(0.15) : const Color(0xFF313743),
        border: _isCurrentEpisode ? Border.all(color: Colors.yellow, width: 2) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Episode ${episode.episodeNumber}: ${episode.name}',
                  style: TextStyle(
                    color: _isCurrentEpisode ? Colors.yellow : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isCurrentEpisode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Watching',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            episode.overview,
            style: TextStyle(color: _isCurrentEpisode ? Colors.yellow.withOpacity(0.8) : Colors.white70),
          ),
        ],
      ),
    );
  }
}

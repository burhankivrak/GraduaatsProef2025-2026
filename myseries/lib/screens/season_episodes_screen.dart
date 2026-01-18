import 'package:flutter/material.dart';
import '../models/episodes.dart';
import '../widgets/episode_card.dart';

class SeasonEpisodesScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313743),
        title: Text('Season $seasonNumber Episodes'),
        foregroundColor: Colors.white,
      ),
      body: episodes.isEmpty
          ? const Center(
              child: Text(
                'Geen afleveringen gevonden',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final ep = episodes[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EpisodeCard(
                    episode: ep,
                  ),
                );
              },
            ),
    );
  }
}

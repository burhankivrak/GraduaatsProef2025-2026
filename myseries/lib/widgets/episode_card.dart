import 'package:flutter/material.dart';

import '../models/episodes.dart';

class EpisodeCard extends StatelessWidget {
  final Episode episode;


  const EpisodeCard({
    super.key,
    required this.episode,
  });

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String get formattedDate {
     if (episode.airDate.isEmpty) return '';

    try {
      final dt = DateTime.parse(episode.airDate);
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return episode.airDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF313743),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode number
          Text(
            'Episode ${episode.episodeNumber}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Title
          Text(
            episode.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Overview
          Text(
            episode.overview,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

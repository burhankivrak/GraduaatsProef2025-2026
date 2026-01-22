import 'package:flutter/material.dart';
import '../services/ratings_service.dart';
import '../widgets/rated_series_card.dart';
import '../models/rated_series.dart';
import 'series_detail_screen.dart';

class RatedScreen extends StatelessWidget {
  const RatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ratingsService = RatingsService();

    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: AppBar(
        title: const Text('Rated', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF313743),
        elevation: 0,
      ),
      body: StreamBuilder<List<RatedSeries>>(
        stream: ratingsService.getAllRated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading ratings', style: TextStyle(color: Colors.white)));
          }

          final rated = snapshot.data ?? [];

          if (rated.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 64, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Rated', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('You have not rated anything yet', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: rated.length,
            itemBuilder: (context, index) {
              final item = rated[index];
              return RatedSeriesCard(
                data: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SeriesDetailScreen(seriesId: item.series.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

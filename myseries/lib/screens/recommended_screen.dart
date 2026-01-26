import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../services/favorites_service.dart';
import '../models/series.dart';
import '../widgets/series_card.dart';
import 'series_detail_screen.dart';

class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  final TmdbService _tmdbService = TmdbService();
  final FavoritesService _favoritesService = FavoritesService();

  Future<List<Series>>? _recsFromFavFuture;

  @override
  void initState() {
    super.initState();
    _recsFromFavFuture = _loadFavBasedRecommendations();
  }

  Future<List<Series>> _loadFavBasedRecommendations() async {
    try {
      final favs = await _favoritesService.getAllFavorites().first;
      if (favs.isEmpty) return [];
      
      final favIds = favs.map((f) => f.id).toSet();
      final byId = <int, Series>{};
      final count = <int, int>{};

      for (final fav in favs) {
        try {
          final recs = await _tmdbService.getSeriesRecommendations(fav.id);
          for (final s in recs) {
            if (favIds.contains(s.id)) continue; 
            byId[s.id] = s; 
            count[s.id] = (count[s.id] ?? 0) + 1;
          }
        } catch (e) {
          log('Error fetching recommendations for favorite ${fav.id}: $e');
        }
      }

      final sortedIds = byId.keys.toList()
        ..sort((a, b) => (count[b] ?? 0).compareTo(count[a] ?? 0));

      final top = sortedIds.take(20).map((id) => byId[id]!).toList();
      return top;
    } catch (e) {
      log('Error loading TMDB recommendations from favorites: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313743),
        title: const Text(
          'Recommended Series',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Series>>(
        future: _recsFromFavFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white70, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading recommendations',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }
          
          final recs = snapshot.data ?? [];
          
          if (recs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, color: Colors.white70, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations available',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add favorites to get recommendations',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: recs.length,
            itemBuilder: (context, index) {
              final series = recs[index];
              return SeriesCard(
                data: series,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeriesDetailScreen(seriesId: series.id),
                    ),
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

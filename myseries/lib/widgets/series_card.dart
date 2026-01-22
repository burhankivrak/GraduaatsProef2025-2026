import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/series.dart';
import '../services/favorites_service.dart';

class SeriesCard extends StatefulWidget {
  final Series data;
  final VoidCallback onTap;

  const SeriesCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  final _favoritesService = FavoritesService();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const Map<int, String> genreMap = {
    10759: 'Action',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    50: 'Family',
    10751: 'Family',
    10762: 'Kids',
    9648: 'Mystery',
    10763: 'News',
    10764: 'Reality',
    10765: 'Sci-Fi',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War',
    37: 'Western',
  };

  String get _userId => _auth.currentUser?.uid ?? '';

  Stream<bool> _getFavoriteStatus() {
    if (_userId.isEmpty) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(widget.data.id.toString())
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> _toggleFavorite(bool currentStatus) async {
    try {
      if (currentStatus) {
        await _favoritesService.removeFromFavorites(widget.data.id);
      } else {
        await _favoritesService.addToFavorites(widget.data);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String _getGenreString() {
    return widget.data.genreIds
        .take(2)
        .map((id) => genreMap[id] ?? 'Other')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF313743),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            widget.data.posterPath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.data.fullPosterUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.tv, size: 100, color: Colors.white),
            const SizedBox(width: 12),
            // Info and Favorite Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.data.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StreamBuilder<bool>(
                        stream: _getFavoriteStatus(),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 24,
                            ),
                            onPressed: () => _toggleFavorite(isFavorite),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.data.year,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getGenreString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
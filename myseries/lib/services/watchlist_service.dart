import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/watchlist.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> addOrUpdateWatchlist(WatchlistSeries series) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('watchlist')
          .doc(series.id.toString())
          .set({
            'id': series.id,
            'name': series.name,
            'posterPath': series.posterPath,
            'firstAirDate': series.firstAirDate,
            'genres': series.genres,
            'status': series.status.value,
            'listName': series.listName,
            'lastSeason': series.lastSeason,
            'lastEpisode': series.lastEpisode,
            'addedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error adding/updating watchlist: $e');
    }
  }

  Future<void> remove(int seriesId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('watchlist')
          .doc(seriesId.toString())
          .delete();
    } catch (e) {
      throw Exception('Error removing from watchlist: $e');
    }
  }

  Future<WatchStatusEnum?> getStatus(int seriesId) async {
    try {
      if (_userId.isEmpty) return null;
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('watchlist')
          .doc(seriesId.toString())
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return WatchStatus.fromString(data['status']);
    } catch (e) {
      throw Exception('Error getting status: $e');
    }
  }

  Stream<List<WatchlistSeries>> watchByStatus(WatchStatusEnum status) {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('watchlist')
        .where('status', isEqualTo: status.value)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WatchlistSeries.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> updateLastWatched(int seriesId, int season, int episode) async {
    final doc = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('watchlist')
        .doc(seriesId.toString());

    await doc.update({
      'lastSeason': season,
      'lastEpisode': episode,
    });
  }

  Future<void> updateListName(int seriesId, String? listName) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('watchlist')
          .doc(seriesId.toString())
          .update({'listName': listName});
    } catch (e) {
      throw Exception('Error updating list name: $e');
    }
  }

  Future<Map<String, dynamic>?> getWatchlist(int seriesId) async {
    try {
      if (_userId.isEmpty) return null;
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('watchlist')
          .doc(seriesId.toString())
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/series.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> addToFavorites(Series series) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(series.id.toString())
          .set({
        'id': series.id,
        'name': series.name,
        'posterPath': series.posterPath,
        'firstAirDate': series.firstAirDate,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(int seriesId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(seriesId.toString())
          .delete();
    } catch (e) {
      throw Exception('Error removing from favorites: $e');
    }
  }

  Future<bool> isFavorite(int seriesId) async {
    try {
      if (_userId.isEmpty) return false;

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(seriesId.toString())
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Error checking favorite status: $e');
    }
  }

  Stream<List<Series>> getAllFavorites() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return Series(
              id: data['id'],
              name: data['name'],
              posterPath: data['posterPath'],
              firstAirDate: data['firstAirDate'],
            );
          })
          .toList();
    });
  }
}

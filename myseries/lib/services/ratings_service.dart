import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/series.dart';
import '../models/rated_series.dart';

class RatingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> addRating(Series series, int rating) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ratings')
          .doc(series.id.toString())
          .set({
        'id': series.id,
        'name': series.name,
        'posterPath': series.posterPath,
        'firstAirDate': series.firstAirDate,
        'rating': rating,
        'ratedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding rating: $e');
    }
  }

  Future<void> removeRating(int seriesId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ratings')
          .doc(seriesId.toString())
          .delete();
    } catch (e) {
      throw Exception('Error removing rating: $e');
    }
  }

  Stream<int?> rating(int seriesId) {
    if (_userId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('ratings')
        .doc(seriesId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      return (data?['rating'] as num?)?.toInt();
    });
  }

  Stream<List<RatedSeries>> getAllRated() {
    if (_userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('ratings')
        .orderBy('ratedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final s = Series(
          id: data['id'],
          name: data['name'] ?? '',
          posterPath: data['posterPath'] ?? '',
          firstAirDate: data['firstAirDate'],
        );
        final rating = (data['rating'] as num?)?.toInt() ?? 0;
        return RatedSeries(series: s, rating: rating);
      }).toList();
    });
  }
}

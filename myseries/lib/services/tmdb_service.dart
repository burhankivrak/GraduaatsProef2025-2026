import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myseries/models/episodes.dart';
import '../models/serie_detail.dart';
import '../models/series.dart';

class TmdbService {
  final String apiKey = '0302ca14356771d399eb4c1c781a9128'; 
  final String apiBase = 'https://api.themoviedb.org/3';

  Future<Map<String, dynamic>> getPopularSeriesPage({int page = 1}) async {
    final url = Uri.parse(
        '$apiBase/tv/popular?api_key=$apiKey&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return {
        'series': results.map((json) => Series.fromJson(json)).toList(),
        'total_pages': data['total_pages'],
      };
    } else {
      throw Exception('Failed to load popular series');
    }
  }

  Future<Map<String, dynamic>> searchSeries(String query) async {
    final url = Uri.parse(
        '$apiBase/search/tv?api_key=$apiKey&query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return {
        'series': results.map((json) => Series.fromJson(json)).toList(),
        'total_pages': data['total_pages'],
      };
    } else {
      throw Exception('Failed to search series');
    }
  }

  Future<SeriesDetail> getSeriesDetail(int id) async {
    final url = Uri.parse('$apiBase/tv/$id?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SeriesDetail.fromJson(data);
    } else {
      throw Exception('Failed to load series detail');
    }
  }

  Future<List<String>> getSeriesTrailers(int id) async {
    final url = Uri.parse('$apiBase/tv/$id/videos?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results
          .where((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer')
          .map<String>((v) => v['key'] as String)
          .toList();
    } else {
      throw Exception('Failed to load trailers');
    }
  }

  Future<List<Episode>> getSeasonEpisodes(int seriesId, int seasonNumber) async {
    final url = Uri.parse('$apiBase/tv/$seriesId/season/$seasonNumber?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List episodes = data['episodes'];
      return episodes.map((e) => Episode.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load episodes');
    }
  }
}

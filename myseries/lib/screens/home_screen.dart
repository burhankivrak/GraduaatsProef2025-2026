import 'dart:developer';

import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../models/series.dart';
import '../widgets/search_filter.dart';
import '../widgets/series_card.dart';
import 'series_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Series> _series = [];
  bool _isLoading = true;
  bool _isSearching = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadPopularSeries();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        _currentPage < _totalPages &&
        !_isLoading) {
      _loadMoreSeries();
    }
  }

  Future<void> _loadPopularSeries() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _currentPage = 1;
    });

    try {
      final result = await _tmdbService.getPopularSeriesPage(page: _currentPage);
      setState(() {
        _series = result['series'];
        _totalPages = result['total_pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      log('Error loading popular series: $e');
    }
  }

  Future<void> _loadMoreSeries() async {
    if (_currentPage >= _totalPages) return;

    _currentPage++;
    try {
      final result = await _tmdbService.getPopularSeriesPage(page: _currentPage);
      setState(() {
        _series.addAll(result['series']);
      });
    } catch (e) {
      log('Error loading more series: $e');
    }
  }

  Future<void> _searchSeries(String query) async {
    if (query.isEmpty) {
      _loadPopularSeries();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _currentPage = 1;
    });

    try {
      final result =
          await _tmdbService.searchSeries(query);
      setState(() {
        _series = result['series'];
        _totalPages = result['total_pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      log('Error searching series: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SearchFilter(
          isSearching: _isSearching,
          controller: _searchController,
          onChanged: _searchSeries,
          onToggleSearch: () {
            if (_isSearching) {
              _searchController.clear();
              _loadPopularSeries();
            } else {
              setState(() => _isSearching = true);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _series.isEmpty
              ? const Center(
                  child: Text('Geen series gevonden',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _series.length,
                  itemBuilder: (context, index) {
                    final series = _series[index];
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
                ),
    );
  }
}

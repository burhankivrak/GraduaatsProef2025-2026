import 'package:flutter/material.dart';
import '../models/watchlist.dart';
import '../services/watchlist_service.dart';
import 'series_detail_screen.dart';
import '../widgets/watchlist_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final WatchlistService _watchlistService = WatchlistService();
  WatchStatusEnum _activeStatus = WatchStatusEnum.watching;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E252D),
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF313743),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: StreamBuilder<List<WatchlistSeries>>(
              stream: _watchlistService.watchByStatus(_activeStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return _EmptyState(status: _activeStatus);
                }

                if (_activeStatus == WatchStatusEnum.watching) {
                  final Map<String, List<WatchlistSeries>> grouped = {};
                  for (final s in list) {
                    final key = (s.listName == null || s.listName!.isEmpty) ? 'Uncategorized' : s.listName!;
                    grouped.putIfAbsent(key, () => []).add(s);
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _showCreateList(list),
                          icon: const Icon(Icons.create_new_folder),
                          label: const Text('Create List'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      ...grouped.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ExpansionTile(
                          collapsedIconColor: Colors.white54,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF313743),
                          collapsedBackgroundColor: const Color(0xFF313743),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          title: Text(
                            entry.key,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          children: entry.value.map((item) {
                            return WatchlistCard(
                              series: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeriesDetailScreen(seriesId: item.id),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                      }),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return WatchlistCard(
                      series: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeriesDetailScreen(seriesId: item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFF313743),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tabButton('Watching', WatchStatusEnum.watching),
          _tabButton('To Watch', WatchStatusEnum.toWatch),
          _tabButton('Paused', WatchStatusEnum.paused),
        ],
      ),
    );
  }

  Widget _tabButton(String label, WatchStatusEnum status) {
    final bool active = _activeStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeStatus = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? Colors.blue : const Color(0xFF1E252D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

extension on _WatchlistScreenState {
  void _showCreateList(List<WatchlistSeries> items) {
    final controller = TextEditingController();
    final Map<int, bool> selection = { for (final s in items) s.id : false };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E252D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxListHeight = (constraints.maxHeight * 0.45).clamp(160, 360);
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create List',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'List name',
                            hintStyle: TextStyle(color: Colors.white38),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Assign series', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight.toDouble()),
                          child: ListView(
                            shrinkWrap: true,
                            children: items.map((s) {
                              return CheckboxListTile(
                                value: selection[s.id] ?? false,
                                onChanged: (val) => setModalState(() => selection[s.id] = val ?? false),
                                title: Text(s.name, style: const TextStyle(color: Colors.white)),
                                controlAffinity: ListTileControlAffinity.leading,
                                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                activeColor: Colors.blueAccent,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                                onPressed: () async {
                                  final name = controller.text.trim();
                                  if (name.isEmpty) return;
                                  for (final entry in selection.entries) {
                                    if (entry.value) {
                                      await WatchlistService().updateListName(entry.key, name);
                                    }
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                },
                                child: const Text('Save', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final WatchStatusEnum status;

  const _EmptyState({required this.status});

  String get _message {
    switch (status) {
      case WatchStatusEnum.watching:
        return 'Add series you are currently watching';
      case WatchStatusEnum.toWatch:
        return 'Add series you want to watch';
      case WatchStatusEnum.paused:
        return 'Add series you paused';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 72,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No series',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

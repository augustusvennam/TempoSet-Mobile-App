import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/storage_service.dart';

/// Manages song library state with search and sort functionality.
class SongProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  SortMode _sortMode = SortMode.recentlyAdded;
  bool _loading = true;

  List<Song> get songs => _filteredSongs;
  String get searchQuery => _searchQuery;
  SortMode get sortMode => _sortMode;
  bool get loading => _loading;

  Future<void> loadSongs() async {
    _loading = true;
    notifyListeners();

    _songs = await _storage.getAllSongs();
    _applyFilters();

    _loading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortMode(SortMode mode) {
    _sortMode = mode;
    _applyFilters();
    notifyListeners();
  }

  Future<void> addSong(Song song) async {
    await _storage.insertSong(song);
    _songs.insert(0, song);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateSong(Song song) async {
    await _storage.updateSong(song);
    final idx = _songs.indexWhere((s) => s.id == song.id);
    if (idx != -1) _songs[idx] = song;
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteSong(String id) async {
    await _storage.deleteSong(id);
    _songs.removeWhere((s) => s.id == id);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Song>.from(_songs);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.genre.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    switch (_sortMode) {
      case SortMode.bpmHighLow:
        result.sort((a, b) => b.bpm.compareTo(a.bpm));
      case SortMode.bpmLowHigh:
        result.sort((a, b) => a.bpm.compareTo(b.bpm));
      case SortMode.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortMode.titleAZ:
        result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.artistAZ:
        result.sort((a, b) =>
            a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
    }

    _filteredSongs = result;
  }
}

enum SortMode {
  bpmHighLow,
  bpmLowHigh,
  recentlyAdded,
  titleAZ,
  artistAZ,
}

extension SortModeLabel on SortMode {
  String get label {
    switch (this) {
      case SortMode.bpmHighLow:
        return 'BPM: High-Low';
      case SortMode.bpmLowHigh:
        return 'BPM: Low-High';
      case SortMode.recentlyAdded:
        return 'Recently Added';
      case SortMode.titleAZ:
        return 'Title A-Z';
      case SortMode.artistAZ:
        return 'Artist A-Z';
    }
  }
}

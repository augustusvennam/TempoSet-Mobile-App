import 'package:flutter/foundation.dart';
import '../models/setlist.dart';
import '../services/storage_service.dart';

/// Manages setlist state with search and CRUD operations.
class SetlistProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Setlist> _setlists = [];
  List<Setlist> _filteredSetlists = [];
  String _searchQuery = '';
  bool _loading = true;

  List<Setlist> get setlists => _filteredSetlists;
  String get searchQuery => _searchQuery;
  bool get loading => _loading;

  Future<void> loadSetlists() async {
    _loading = true;
    notifyListeners();

    _setlists = await _storage.getAllSetlists();
    _applyFilter();

    _loading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  Future<void> addSetlist(Setlist setlist) async {
    await _storage.insertSetlist(setlist);
    _setlists.insert(0, setlist);
    _applyFilter();
    notifyListeners();
  }

  Future<void> updateSetlist(Setlist setlist) async {
    await _storage.updateSetlist(setlist);
    final idx = _setlists.indexWhere((s) => s.id == setlist.id);
    if (idx != -1) _setlists[idx] = setlist;
    _applyFilter();
    notifyListeners();
  }

  Future<void> deleteSetlist(String id) async {
    await _storage.deleteSetlist(id);
    _setlists.removeWhere((s) => s.id == id);
    _applyFilter();
    notifyListeners();
  }

  Future<Setlist?> getSetlist(String id) async {
    return _storage.getSetlist(id);
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredSetlists = List<Setlist>.from(_setlists);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredSetlists = _setlists
          .where((s) => s.name.toLowerCase().contains(q))
          .toList();
    }
  }
}

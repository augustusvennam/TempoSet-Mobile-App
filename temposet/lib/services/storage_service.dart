import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/song.dart';
import '../models/setlist.dart';

/// SQLite-backed persistence for songs, setlists, and setlist items.
class StorageService {
  static Database? _database;
  static const String _dbName = 'temposet.db';
  static const int _dbVersion = 2;

  /// Returns the singleton database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE songs ADD COLUMN accent_enabled INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE songs ADD COLUMN subdivision INTEGER DEFAULT 1');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT,
        genre TEXT,
        bpm REAL NOT NULL,
        time_sig_beats INTEGER NOT NULL,
        time_sig_unit INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        accent_enabled INTEGER DEFAULT 1,
        subdivision INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE setlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT DEFAULT 'event_note',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE setlist_items (
        id TEXT PRIMARY KEY,
        setlist_id TEXT NOT NULL,
        song_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        override_bpm REAL,
        transition_type TEXT DEFAULT 'instant',
        FOREIGN KEY (setlist_id) REFERENCES setlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // Seed sample data
    await _seedData(db);
  }

  // ─────────────────────────── SONGS ───────────────────────────

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final maps = await db.query('songs', orderBy: 'updated_at DESC');
    return maps.map((m) => Song.fromJson(m)).toList();
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ? OR genre LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => Song.fromJson(m)).toList();
  }

  Future<Song?> getSong(String id) async {
    final db = await database;
    final maps = await db.query('songs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Song.fromJson(maps.first);
  }

  Future<void> insertSong(Song song) async {
    final db = await database;
    await db.insert('songs', song.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSong(Song song) async {
    final db = await database;
    song.updatedAt = DateTime.now();
    await db.update('songs', song.toJson(),
        where: 'id = ?', whereArgs: [song.id]);
  }

  Future<void> deleteSong(String id) async {
    final db = await database;
    await db.delete('songs', where: 'id = ?', whereArgs: [id]);
    // Also remove from any setlists
    await db.delete('setlist_items', where: 'song_id = ?', whereArgs: [id]);
  }

  // ─────────────────────────── SETLISTS ───────────────────────────

  Future<List<Setlist>> getAllSetlists() async {
    final db = await database;
    final maps = await db.query('setlists', orderBy: 'updated_at DESC');
    final setlists = <Setlist>[];
    for (final map in maps) {
      final setlist = Setlist.fromJson(map);
      setlist.items = await _getSetlistItems(db, setlist.id);
      setlists.add(setlist);
    }
    return setlists;
  }

  Future<Setlist?> getSetlist(String id) async {
    final db = await database;
    final maps = await db.query('setlists', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final setlist = Setlist.fromJson(maps.first);
    setlist.items = await _getSetlistItems(db, setlist.id);
    return setlist;
  }

  Future<void> insertSetlist(Setlist setlist) async {
    final db = await database;
    await db.insert('setlists', setlist.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final item in setlist.items) {
      await db.insert(
        'setlist_items',
        {...item.toJson(), 'setlist_id': setlist.id},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateSetlist(Setlist setlist) async {
    final db = await database;
    setlist.updatedAt = DateTime.now();
    await db.update('setlists', setlist.toJson(),
        where: 'id = ?', whereArgs: [setlist.id]);
    // Re-write items
    await db.delete('setlist_items',
        where: 'setlist_id = ?', whereArgs: [setlist.id]);
    for (final item in setlist.items) {
      await db.insert(
        'setlist_items',
        {...item.toJson(), 'setlist_id': setlist.id},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteSetlist(String id) async {
    final db = await database;
    await db.delete('setlists', where: 'id = ?', whereArgs: [id]);
    await db.delete('setlist_items',
        where: 'setlist_id = ?', whereArgs: [id]);
  }

  Future<List<SetlistItem>> _getSetlistItems(
      Database db, String setlistId) async {
    final maps = await db.query(
      'setlist_items',
      where: 'setlist_id = ?',
      whereArgs: [setlistId],
      orderBy: 'order_index ASC',
    );
    final items = <SetlistItem>[];
    for (final map in maps) {
      final song = await _getSongById(db, map['song_id'] as String);
      items.add(SetlistItem.fromJson(map, song: song));
    }
    return items;
  }

  Future<Song?> _getSongById(Database db, String id) async {
    final maps = await db.query('songs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Song.fromJson(maps.first);
  }

  // ─────────────────────────── SEED DATA ───────────────────────────

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Sample songs from the wireframe
    final songs = [
      {
        'id': 'song_1', 'title': 'Starlight', 'artist': 'Muse',
        'genre': 'Alternative Rock', 'bpm': 122.0,
        'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_2', 'title': 'Midnight City', 'artist': 'M83',
        'genre': 'Synth-pop', 'bpm': 105.0,
        'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_3', 'title': 'Blinding Lights', 'artist': 'The Weeknd',
        'genre': '80s Pop', 'bpm': 171.0,
        'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_4', 'title': 'Seven Nation Army',
        'artist': 'The White Stripes', 'genre': 'Garage Rock',
        'bpm': 124.0, 'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_5', 'title': 'Clocks', 'artist': 'Coldplay',
        'genre': 'Piano Rock', 'bpm': 131.0,
        'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_6', 'title': 'R U Mine?', 'artist': 'Arctic Monkeys',
        'genre': 'Indie Rock', 'bpm': 97.0,
        'time_sig_beats': 4, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_7', 'title': 'Take Five', 'artist': 'Dave Brubeck',
        'genre': 'Jazz', 'bpm': 176.0,
        'time_sig_beats': 5, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
      {
        'id': 'song_8', 'title': 'Money', 'artist': 'Pink Floyd',
        'genre': 'Progressive Rock', 'bpm': 120.0,
        'time_sig_beats': 7, 'time_sig_unit': 4,
        'notes': null, 'created_at': now, 'updated_at': now,
      },
    ];

    for (final song in songs) {
      await db.insert('songs', song);
    }

    // Sample setlists
    final setlists = [
      {
        'id': 'setlist_1', 'name': 'Friday Night Gig',
        'description': 'Weekly venue gig', 'icon': 'event_note',
        'created_at': now, 'updated_at': now,
      },
      {
        'id': 'setlist_2', 'name': 'Sunday Service',
        'description': 'Church worship set', 'icon': 'church',
        'created_at': now, 'updated_at': now,
      },
      {
        'id': 'setlist_3', 'name': 'Studio Session A',
        'description': 'Recording session', 'icon': 'preview',
        'created_at': now, 'updated_at': now,
      },
      {
        'id': 'setlist_4', 'name': 'Acoustic Lounge',
        'description': 'Chill acoustic set', 'icon': 'local_bar',
        'created_at': now, 'updated_at': now,
      },
    ];

    for (final setlist in setlists) {
      await db.insert('setlists', setlist);
    }

    // Add songs to setlists
    final setlistItems = [
      // Friday Night Gig — all 8 songs + repeat some for 12
      ...List.generate(8, (i) => {
            'id': 'si_1_$i', 'setlist_id': 'setlist_1',
            'song_id': 'song_${i + 1}', 'order_index': i,
            'override_bpm': null, 'transition_type': 'instant',
          }),
      ...List.generate(4, (i) => {
            'id': 'si_1_${i + 8}', 'setlist_id': 'setlist_1',
            'song_id': 'song_${i + 1}', 'order_index': i + 8,
            'override_bpm': null, 'transition_type': 'instant',
          }),
      // Sunday Service — 5 songs
      ...List.generate(5, (i) => {
            'id': 'si_2_$i', 'setlist_id': 'setlist_2',
            'song_id': 'song_${i + 1}', 'order_index': i,
            'override_bpm': null, 'transition_type': 'instant',
          }),
      // Studio Session A — 8 songs
      ...List.generate(8, (i) => {
            'id': 'si_3_$i', 'setlist_id': 'setlist_3',
            'song_id': 'song_${i + 1}', 'order_index': i,
            'override_bpm': null, 'transition_type': 'instant',
          }),
      // Acoustic Lounge — 6 songs (all unique ones)
      ...List.generate(6, (i) => {
            'id': 'si_4_$i', 'setlist_id': 'setlist_4',
            'song_id': 'song_${i + 1}', 'order_index': i,
            'override_bpm': null, 'transition_type': 'instant',
          }),
    ];

    for (final item in setlistItems) {
      await db.insert('setlist_items', item);
    }
  }
}

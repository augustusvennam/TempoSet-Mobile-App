import 'package:uuid/uuid.dart';
import 'time_signature.dart';

/// A song with tempo, artist, genre and time signature information.
class Song {
  final String id;
  String title;
  String artist;
  String genre;
  double bpm;
  TimeSignature timeSignature;
  String? notes;
  final DateTime createdAt;
  DateTime updatedAt;
  bool accentEnabled;
  int subdivision;

  Song({
    String? id,
    required this.title,
    this.artist = '',
    this.genre = '',
    required this.bpm,
    TimeSignature? timeSignature,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.accentEnabled = true,
    this.subdivision = 1,
  })  : id = id ?? const Uuid().v4(),
        timeSignature = timeSignature ?? TimeSignature.common,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Estimated duration in seconds for a typical song (≈ 4 minutes).
  int get estimatedDurationSeconds => 240;

  Song copyWith({
    String? title,
    String? artist,
    String? genre,
    double? bpm,
    TimeSignature? timeSignature,
    String? notes,
    bool? accentEnabled,
    int? subdivision,
  }) {
    return Song(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      notes: notes ?? this.notes,
      accentEnabled: accentEnabled ?? this.accentEnabled,
      subdivision: subdivision ?? this.subdivision,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'genre': genre,
        'bpm': bpm,
        'time_sig_beats': timeSignature.beatsPerBar,
        'time_sig_unit': timeSignature.beatUnit,
        'notes': notes,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'accent_enabled': accentEnabled ? 1 : 0,
        'subdivision': subdivision,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String? ?? '',
        genre: json['genre'] as String? ?? '',
        bpm: (json['bpm'] as num).toDouble(),
        timeSignature: TimeSignature(
          json['time_sig_beats'] as int,
          json['time_sig_unit'] as int,
        ),
        notes: json['notes'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
        accentEnabled: (json['accent_enabled'] as int?) == 0 ? false : true,
        subdivision: json['subdivision'] as int? ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

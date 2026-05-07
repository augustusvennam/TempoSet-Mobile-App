import 'package:uuid/uuid.dart';
import 'song.dart';

/// A setlist item — a reference to a song within a setlist, with optional overrides.
class SetlistItem {
  final String id;
  final String songId;
  int orderIndex;
  double? overrideBpm;
  String transitionType;

  // Populated from join query
  Song? song;

  SetlistItem({
    String? id,
    required this.songId,
    required this.orderIndex,
    this.overrideBpm,
    this.transitionType = 'instant',
    this.song,
  }) : id = id ?? const Uuid().v4();

  /// Returns the effective BPM (override or song default).
  double get effectiveBpm => overrideBpm ?? song?.bpm ?? 120;

  Map<String, dynamic> toJson() => {
        'id': id,
        'song_id': songId,
        'order_index': orderIndex,
        'override_bpm': overrideBpm,
        'transition_type': transitionType,
      };

  factory SetlistItem.fromJson(Map<String, dynamic> json, {Song? song}) =>
      SetlistItem(
        id: json['id'] as String,
        songId: json['song_id'] as String,
        orderIndex: json['order_index'] as int,
        overrideBpm: json['override_bpm'] != null
            ? (json['override_bpm'] as num).toDouble()
            : null,
        transitionType: json['transition_type'] as String? ?? 'instant',
        song: song,
      );
}

/// A setlist — an ordered collection of songs for a live performance.
class Setlist {
  final String id;
  String name;
  String? description;
  String icon;
  final DateTime createdAt;
  DateTime updatedAt;
  List<SetlistItem> items;

  Setlist({
    String? id,
    required this.name,
    this.description,
    this.icon = 'event_note',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SetlistItem>? items,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        items = items ?? [];

  /// Number of songs in this setlist.
  int get songCount => items.length;

  /// Estimated total duration in minutes (assumes ~4 min per song).
  int get totalDurationMinutes => (items.length * 4).clamp(0, 999);

  /// Convenience: list of songs (non-null).
  List<Song> get songs =>
      items.where((i) => i.song != null).map((i) => i.song!).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Setlist.fromJson(Map<String, dynamic> json,
          {List<SetlistItem>? items}) =>
      Setlist(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        icon: json['icon'] as String? ?? 'event_note',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
        items: items ?? [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Setlist && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

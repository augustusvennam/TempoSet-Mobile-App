/// Represents a musical time signature (e.g. 4/4, 3/4, 6/8).
class TimeSignature {
  final int beatsPerBar;
  final int beatUnit;

  const TimeSignature(this.beatsPerBar, this.beatUnit);

  /// Common time signatures.
  static const TimeSignature common = TimeSignature(4, 4);
  static const TimeSignature waltz = TimeSignature(3, 4);
  static const TimeSignature sixEight = TimeSignature(6, 8);
  static const TimeSignature fiveFour = TimeSignature(5, 4);
  static const TimeSignature sevenEight = TimeSignature(7, 8);
  static const TimeSignature sevenFour = TimeSignature(7, 4);

  static const List<TimeSignature> presets = [
    common,
    waltz,
    sixEight,
    fiveFour,
    sevenEight,
    sevenFour,
  ];

  @override
  String toString() => '$beatsPerBar/$beatUnit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSignature &&
          beatsPerBar == other.beatsPerBar &&
          beatUnit == other.beatUnit;

  @override
  int get hashCode => beatsPerBar.hashCode ^ beatUnit.hashCode;

  Map<String, dynamic> toJson() => {
        'beatsPerBar': beatsPerBar,
        'beatUnit': beatUnit,
      };

  factory TimeSignature.fromJson(Map<String, dynamic> json) => TimeSignature(
        json['beatsPerBar'] as int,
        json['beatUnit'] as int,
      );
}

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

import '../services/metronome_engine.dart';
import '../models/time_signature.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';

/// Standalone metronome screen (default tab).
class MetronomeScreen extends StatefulWidget {
  final MetronomeEngine metronome;

  const MetronomeScreen({super.key, required this.metronome});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int _currentBeat = 0;
  StreamSubscription<int>? _beatSub;

  bool _audioToggle = true;
  bool _accentToggle = true;

  // Tap tempo
  final List<DateTime> _tapTimes = [];
  static const int _maxTaps = 8;
  static const Duration _resetDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _audioToggle = widget.metronome.audioEnabled;
    _accentToggle = widget.metronome.accentEnabled;

    _beatSub = widget.metronome.beatStream.listen((beat) {
      if (mounted) {
        setState(() => _currentBeat = beat);
      }
    });
  }

  @override
  void dispose() {
    _beatSub?.cancel();
    super.dispose();
  }

  void _onTapTempo() {
    final now = DateTime.now();

    if (_tapTimes.isNotEmpty &&
        now.difference(_tapTimes.last) > _resetDuration) {
      _tapTimes.clear();
    }

    _tapTimes.add(now);
    if (_tapTimes.length > _maxTaps) _tapTimes.removeAt(0);

    if (_tapTimes.length >= 3) {
      double totalMs = 0;
      for (int i = 1; i < _tapTimes.length; i++) {
        totalMs +=
            _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds;
      }
      final avgMs = totalMs / (_tapTimes.length - 1);
      final bpm = (60000 / avgMs).clamp(20.0, 300.0);
      widget.metronome.setBPM(bpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.metronome,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Metronome', style: AppTypography.h1),
                      _buildTimeSignatureSelector(),
                    ],
                  ),
                ),

                const Spacer(),

                // TEMPO label
                Text(
                  'TEMPO',
                  style: AppTypography.caption.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Huge BPM display
                Text(
                  widget.metronome.bpm.round().toString(),
                  style: AppTypography.hugeBPM,
                ),
                Text('BPM', style: AppTypography.caption),

                const SizedBox(height: 32),

                // Beat indicators
                BeatVisualizer(
                  totalBeats:
                      widget.metronome.timeSignature.beatsPerBar,
                  currentBeat: _currentBeat,
                  isPlaying: widget.metronome.isPlaying,
                ),

                const SizedBox(height: 40),

                // Controls row (−, play/pause, +)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCircleButton(
                      icon: Icons.remove,
                      size: 64,
                      onTap: () => widget.metronome.decrementBPM(),
                    ),
                    const SizedBox(width: 24),
                    _buildPlayButton(),
                    const SizedBox(width: 24),
                    _buildCircleButton(
                      icon: Icons.add,
                      size: 64,
                      onTap: () => widget.metronome.incrementBPM(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Tap Tempo button
                _buildTapTempoButton(),

                const SizedBox(height: 32),

                // Feature toggles
                _buildFeatureToggles(),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSignatureSelector() {
    return GestureDetector(
      onTap: () {
        int tempBeats = widget.metronome.timeSignature.beatsPerBar;
        int tempUnit = widget.metronome.timeSignature.beatUnit;
        
        final List<int> beatUnits = [2, 4, 8, 16];

        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => StatefulBuilder(
            builder: (context, setSheetState) {
              return SizedBox(
                height: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Time Signature', style: AppTypography.h2),
                          TextButton(
                            onPressed: () {
                              widget.metronome.setTimeSignature(TimeSignature(tempBeats, tempUnit));
                              Navigator.pop(ctx);
                            },
                            child: const Text('Done', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          // Beats Per Bar
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: tempBeats - 1,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setSheetState(() => tempBeats = index + 1);
                              },
                              children: List.generate(32, (index) {
                                return Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Text(
                            '/',
                            style: AppTypography.h1.copyWith(color: AppColors.textSecondary),
                          ),
                          // Beat Unit
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: !beatUnits.contains(tempUnit) ? 1 : beatUnits.indexOf(tempUnit),
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setSheetState(() => tempUnit = beatUnits[index]);
                              },
                              children: beatUnits.map((val) {
                                return Center(
                                  child: Text(
                                    '$val',
                                    style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          widget.metronome.timeSignature.toString(),
          style: AppTypography.h3.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 32),
      ),
    );
  }

  Widget _buildPlayButton() {
    final isPlaying = widget.metronome.isPlaying;
    return GestureDetector(
      onTap: () => widget.metronome.toggle(),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: AppColors.backgroundDark,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildTapTempoButton() {
    return GestureDetector(
      onTap: _onTapTempo,
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app,
                color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Text(
              'TAP TEMPO',
              style: AppTypography.body.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureToggles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton(
          Icons.volume_up,
          'AUDIO',
          _audioToggle,
          () => setState(() {
            _audioToggle = !_audioToggle;
            widget.metronome.setAudioEnabled(_audioToggle);
          }),
        ),
        const SizedBox(width: 24),
        _buildToggleButton(
          Icons.looks_one,
          'ACCENT',
          _accentToggle,
          () => setState(() {
            _accentToggle = !_accentToggle;
            widget.metronome.setAccentEnabled(_accentToggle);
          }),
        ),
        const SizedBox(width: 24),
        _buildSubdivisionToggle(),
      ],
    );
  }

  Widget _buildSubdivisionToggle() {
    final sub = widget.metronome.subdivision;
    return GestureDetector(
      onTap: _showSubdivisionPicker,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                {1: '♩', 2: '♫', 3: '³♪', 4: '♬'}[sub]!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SUBDIV',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubdivisionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subdivisions', style: AppTypography.h2),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [1, 2, 3, 4].map((sub) {
                final isActive = sub == widget.metronome.subdivision;
                final labels = {
                  1: '♩',
                  2: '♫',
                  3: '³♪',
                  4: '♬'
                };
                return GestureDetector(
                  onTap: () {
                    widget.metronome.setSubdivision(sub);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isActive
                          ? null
                          : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      labels[sub]!,
                      style: AppTypography.h3.copyWith(
                        color: isActive ? AppColors.backgroundDark : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: active
                  ? null
                  : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              size: 26,
              color: active ? AppColors.backgroundDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

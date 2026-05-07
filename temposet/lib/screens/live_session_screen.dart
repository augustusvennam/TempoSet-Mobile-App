import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

import '../models/setlist.dart';
import '../services/metronome_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';

/// Live Session screen — setlist playback mode for live performances.
class LiveSessionScreen extends StatefulWidget {
  final Setlist setlist;

  const LiveSessionScreen({super.key, required this.setlist});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  late MetronomeEngine _metronome;
  late final ScrollController _scrollController;

  int _currentSongIndex = 0;
  int _currentBeat = 0;
  StreamSubscription<int>? _beatSub;

  bool _audioToggle = true;
  bool _accentToggle = true;

  // Tap tempo
  final List<DateTime> _tapTimes = [];

  @override
  void initState() {
    super.initState();
    _metronome = context.read<MetronomeEngine>();
    _scrollController = ScrollController();

    // Stop to prevent overlap
    _metronome.stop();

    _audioToggle = _metronome.audioEnabled;
    

    if (widget.setlist.items.isNotEmpty) {
      final firstItem = widget.setlist.items[0];
      _metronome.setBPM(firstItem.effectiveBpm);
      if (firstItem.song != null) {
        _metronome.setTimeSignature(firstItem.song!.timeSignature);
        _metronome.setAccentEnabled(firstItem.song!.accentEnabled);
        _metronome.setSubdivision(firstItem.song!.subdivision);
      }
    }
    _accentToggle = _metronome.accentEnabled;

    _beatSub = _metronome.beatStream.listen((beat) {
      if (mounted) {
        setState(() => _currentBeat = beat);
      }
    });
  }

  @override
  void dispose() {
    _beatSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectSong(int index) {
    if (index < 0 || index >= widget.setlist.items.length) return;
    setState(() => _currentSongIndex = index);

    final item = widget.setlist.items[index];
    _metronome.setBPM(item.effectiveBpm);
    if (item.song != null) {
      _metronome.setTimeSignature(item.song!.timeSignature);
      _metronome.setAccentEnabled(item.song!.accentEnabled);
      _metronome.setSubdivision(item.song!.subdivision);
    }
    setState(() {
      _accentToggle = _metronome.accentEnabled;
    });

    // Scroll to selected card
    _scrollController.animateTo(
      index * 192.0, // card width (180) + margin (12)
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onTapTempo() {
    final now = DateTime.now();

    if (_tapTimes.isNotEmpty &&
        now.difference(_tapTimes.last) > const Duration(seconds: 2)) {
      _tapTimes.clear();
    }

    _tapTimes.add(now);
    if (_tapTimes.length > 8) _tapTimes.removeAt(0);

    if (_tapTimes.length >= 3) {
      double totalMs = 0;
      for (int i = 1; i < _tapTimes.length; i++) {
        totalMs += _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds;
      }
      final avgMs = totalMs / (_tapTimes.length - 1);
      final bpm = (60000 / avgMs).clamp(20.0, 300.0);
      _metronome.setBPM(bpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _metronome,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 4),
                _buildSongCarousel(),

                // Flexible middle section to prevent overflow
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // TEMPO label + Huge BPM
                      Column(
                        children: [
                          Text(
                            'T E M P O',
                            style: AppTypography.caption.copyWith(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _metronome.bpm.round().toString(),
                                style: AppTypography.hugeBPM,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'BPM',
                                style: AppTypography.h3
                                    .copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _metronome.timeSignature.toString(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Beat visualizer
                      BeatVisualizer(
                        totalBeats: _metronome.timeSignature.beatsPerBar,
                        currentBeat: _currentBeat,
                        isPlaying: _metronome.isPlaying,
                      ),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                              Icons.remove, 60, () => _metronome.decrementBPM()),
                          const SizedBox(width: 20),
                          _buildPlayPauseButton(),
                          const SizedBox(width: 20),
                          _buildControlButton(
                              Icons.add, 60, () => _metronome.incrementBPM()),
                        ],
                      ),

                      // Tap tempo
                      _buildTapTempoButton(),

                      // Feature toggles — only Audio + Haptic (Flash removed)
                      _buildFeatureToggles(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: AppColors.textPrimary,
              ),
              const Spacer(),
            ],
          ),
          Column(
            children: [
              Text(
                'LIVE SESSION',
                style: AppTypography.sectionHeader.copyWith(fontSize: 14),
              ),
              Text(
                widget.setlist.name,
                style: AppTypography.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongCarousel() {
    final items = widget.setlist.items;
    if (items.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text('No songs in this setlist',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPCOMING SONGS',
                style: AppTypography.caption.copyWith(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_currentSongIndex + 1} / ${items.length}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isActive = index == _currentSongIndex;
              final isNext = index == _currentSongIndex + 1;

              return GestureDetector(
                onTap: () => _selectSong(index),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? null
                        : Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.2)),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: AppTypography.h1.copyWith(
                          color: isActive
                              ? AppColors.backgroundDark
                              : AppColors.textSecondary,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.song?.title ?? 'Unknown',
                        style: AppTypography.h3.copyWith(
                          color: isActive
                              ? AppColors.backgroundDark
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.speed,
                            size: 10,
                            color: isActive
                                ? AppColors.backgroundDark.withValues(alpha: 0.7)
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.effectiveBpm.round().toString(),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: isActive
                                  ? AppColors.backgroundDark.withValues(alpha: 0.9)
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            {1: '♩', 2: '♫', 3: '³♪', 4: '♬'}[item.song?.subdivision ?? 1]!,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              color: isActive
                                  ? AppColors.backgroundDark.withValues(alpha: 0.9)
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? 'ACTIVE' : isNext ? 'NEXT' : '',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? AppColors.backgroundDark
                              : AppColors.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
      IconData icon, double size, VoidCallback onTap) {
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
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: () => _metronome.toggle(),
      child: Container(
        width: 88,
        height: 88,
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
          _metronome.isPlaying ? Icons.pause : Icons.play_arrow,
          color: AppColors.backgroundDark,
          size: 44,
        ),
      ),
    );
  }

  Widget _buildTapTempoButton() {
    return GestureDetector(
      onTap: _onTapTempo,
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 56,
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
            const Icon(Icons.touch_app, color: Colors.black, size: 22),
            const SizedBox(width: 10),
            Text(
              'TAP TEMPO',
              style: AppTypography.body.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
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
            _metronome.setAudioEnabled(_audioToggle);
          }),
        ),
        const SizedBox(width: 24),
        _buildToggleButton(
          Icons.looks_one, // Using looks_one as a 'first beat/accent' icon
          'ACCENT',
          _accentToggle,
          () => setState(() {
            _accentToggle = !_accentToggle;
            _metronome.setAccentEnabled(_accentToggle);
          }),
        ),
        const SizedBox(width: 24),
        _buildSubdivisionToggle(),
      ],
    );
  }

  Widget _buildSubdivisionToggle() {
    final sub = _metronome.subdivision;
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
                final isActive = sub == _metronome.subdivision;
                final labels = {
                  1: '♩',
                  2: '♫',
                  3: '³♪',
                  4: '♬'
                };
                return GestureDetector(
                  onTap: () {
                    _metronome.setSubdivision(sub);
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
                  : Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              size: 26,
              color: active
                  ? AppColors.backgroundDark
                  : AppColors.textSecondary,
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

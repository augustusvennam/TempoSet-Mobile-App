import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Beat visualizer — animated bars showing current beat position.
class BeatVisualizer extends StatelessWidget {
  final int totalBeats;
  final int currentBeat;
  final bool isPlaying;

  const BeatVisualizer({
    super.key,
    required this.totalBeats,
    required this.currentBeat,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalBeats, (index) {
          final isActive = isPlaying && index == currentBeat;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              height: 8,
              margin: EdgeInsets.only(right: index < totalBeats - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: isActive
                    ? null
                    : Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A cyan pill badge (e.g. "12 Songs").
class PillBadge extends StatelessWidget {
  final String text;
  final bool outlined;

  const PillBadge({super.key, required this.text, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.primary,
        borderRadius: BorderRadius.circular(9999),
        border: outlined
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Text(
        text,
        style: AppTypography.pill.copyWith(
          color: outlined ? AppColors.primary : AppColors.backgroundDark,
        ),
      ),
    );
  }
}

/// Standard search bar matching Stitch design.
class AppSearchBar extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// Setlist card matching the wireframe design.
class SetlistCard extends StatelessWidget {
  final String title;
  final int songCount;
  final int durationMinutes;
  final IconData iconData;
  final VoidCallback? onTap;

  const SetlistCard({
    super.key,
    required this.title,
    required this.songCount,
    required this.durationMinutes,
    this.iconData = Icons.event_note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.h3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      PillBadge(text: '$songCount Songs'),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('$durationMinutes mins',
                          style: AppTypography.caption
                              .copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.primary.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

/// Song card matching the wireframe design.
class SongCard extends StatelessWidget {
  final String title;
  final String artist;
  final String genre;
  final double bpm;
  final int subdivision;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.artist,
    required this.genre,
    required this.bpm,
    this.subdivision = 1,
    this.onTap,
  });

  String _getSubdivisionLabel(int sub) {
    switch (sub) {
      case 1: return '♩';
      case 2: return '♫';
      case 3: return '³♪';
      case 4: return '♬';
      default: return '1/$sub';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            // Music note icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.h3,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(artist, style: AppTypography.bodySmall),
                  const SizedBox(height: 2),
                  Text('$genre • ${_getSubdivisionLabel(subdivision)}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.primary, fontSize: 14)),
                ],
              ),
            ),
            // BPM
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(bpm.round().toString(), style: AppTypography.cardBPM),
                const SizedBox(height: 2),
                Text('BPM',
                    style: AppTypography.caption.copyWith(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

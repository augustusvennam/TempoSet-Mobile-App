import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/time_signature.dart';
import '../providers/song_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';

/// Song Library screen — matches Stitch wireframe exactly.
class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongProvider>().loadSongs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSongEditor([Song? existingSong]) {
    final isEditing = existingSong != null;
    final titleC = TextEditingController(text: existingSong?.title ?? '');
    final artistC = TextEditingController(text: existingSong?.artist ?? '');
    final genreC = TextEditingController(text: existingSong?.genre ?? '');
    final bpmC = TextEditingController(text: existingSong?.bpm.round().toString() ?? '120');
    int tempBeats = existingSong?.timeSignature.beatsPerBar ?? 4;
    int tempUnit = existingSong?.timeSignature.beatUnit ?? 4;
    bool tempAccent = existingSong?.accentEnabled ?? true;
    int tempSubdivision = existingSong?.subdivision ?? 1;

    final List<int> beatUnits = [2, 4, 8];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEditing ? 'Edit Song' : 'Add Song', style: AppTypography.h2),
                        TextButton(
                          onPressed: () {
                            if (titleC.text.trim().isNotEmpty) {
                              final newSong = Song(
                                id: existingSong?.id,
                                title: titleC.text.trim(),
                                artist: artistC.text.trim(),
                                genre: genreC.text.trim(),
                                bpm: double.tryParse(bpmC.text) ?? 120,
                                timeSignature: TimeSignature(tempBeats, tempUnit),
                                accentEnabled: tempAccent,
                                subdivision: tempSubdivision,
                                createdAt: existingSong?.createdAt,
                              );
                              if (isEditing) {
                                context.read<SongProvider>().updateSong(newSong);
                              } else {
                                context.read<SongProvider>().addSong(newSong);
                              }
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Save', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: titleC,
                            autofocus: !isEditing,
                            style: AppTypography.body,
                            decoration: const InputDecoration(hintText: 'Song title'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: artistC,
                                  style: AppTypography.body,
                                  decoration: const InputDecoration(hintText: 'Artist'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: genreC,
                                  style: AppTypography.body,
                                  decoration: const InputDecoration(hintText: 'Genre'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: bpmC,
                            style: AppTypography.body,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'BPM'),
                          ),
                          const SizedBox(height: 24),
                          Text('Time Signature', style: AppTypography.h3),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: Row(
                              children: [
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: tempBeats - 1,
                                    ),
                                    itemExtent: 40,
                                    onSelectedItemChanged: (index) {
                                      setSheetState(() => tempBeats = index + 1);
                                    },
                                    children: List.generate(7, (index) {
                                      return Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Text('/', style: AppTypography.h2.copyWith(color: AppColors.textSecondary)),
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
                          const SizedBox(height: 24),
                          Text('Playback Options', style: AppTypography.h3),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildOptionToggle(
                                icon: Icons.looks_one,
                                label: 'ACCENT',
                                isActive: tempAccent,
                                onTap: () => setSheetState(() => tempAccent = !tempAccent),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Subdivisions', style: AppTypography.caption),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [1, 2, 3, 4].map((sub) {
                                        final active = tempSubdivision == sub;
                                        final subLabels = {1: '♩', 2: '♫', 3: '³♪', 4: '♬'};
                                        return GestureDetector(
                                          onTap: () => setSheetState(() => tempSubdivision = sub),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: active ? AppColors.primary : AppColors.surface,
                                              borderRadius: BorderRadius.circular(8),
                                              border: active
                                                  ? null
                                                  : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                            ),
                                            child: Text(subLabels[sub]!,
                                                style: TextStyle(
                                                    color: active ? AppColors.backgroundDark : AppColors.primary,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionToggle({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? AppColors.backgroundDark : AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            AppSearchBar(
              placeholder: 'Search title, artist or genre...',
              controller: _searchController,
              onChanged: (q) =>
                  context.read<SongProvider>().setSearchQuery(q),
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 8),
            Expanded(child: _buildSongList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Song Library', style: AppTypography.h1),
          GestureDetector(
            onTap: _showSongEditor,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add,
                  color: AppColors.backgroundDark, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: SortMode.values.map((mode) {
              final isActive = provider.sortMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.setSortMode(mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      border: isActive
                          ? null
                          : Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.backgroundDark
                                : AppColors.primary,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more,
                              size: 16,
                              color: AppColors.backgroundDark),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSongList() {
    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_music,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No songs yet',
                    style: AppTypography.h3
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showSongEditor,
                  child: Text('Tap + to add your first song',
                      style: AppTypography.caption),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: provider.songs.length,
          itemBuilder: (context, index) {
            final song = provider.songs[index];
            return Dismissible(
              key: Key(song.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: Text('Delete Song?', style: AppTypography.h2),
                    content: Text(
                        'Are you sure you want to delete "${song.title}"?',
                        style: AppTypography.body),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) => provider.deleteSong(song.id),
              child: GestureDetector(
                onTap: () => _showSongEditor(song),
                child: SongCard(
                  title: song.title,
                  artist: song.artist,
                  genre: song.genre,
                  bpm: song.bpm,
                  subdivision: song.subdivision,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

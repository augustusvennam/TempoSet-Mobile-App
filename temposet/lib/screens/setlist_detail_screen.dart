import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/setlist.dart';
import '../models/song.dart';
import '../models/time_signature.dart';
import '../providers/setlist_provider.dart';
import '../providers/song_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';
import 'live_session_screen.dart';

/// Setlist detail screen — view/edit songs within a setlist.
class SetlistDetailScreen extends StatefulWidget {
  final Setlist setlist;

  const SetlistDetailScreen({super.key, required this.setlist});

  @override
  State<SetlistDetailScreen> createState() => _SetlistDetailScreenState();
}

class _SetlistDetailScreenState extends State<SetlistDetailScreen> {
  late Setlist _setlist;

  @override
  void initState() {
    super.initState();
    _setlist = widget.setlist;
    _refreshSetlist();
  }

  Future<void> _refreshSetlist() async {
    final fresh =
        await context.read<SetlistProvider>().getSetlist(_setlist.id);
    if (fresh != null && mounted) {
      setState(() => _setlist = fresh);
    }
  }

  void _showAddSongDialog() {
    final songProvider = context.read<SongProvider>();
    if (songProvider.songs.isEmpty) {
      songProvider.loadSongs();
    }
    
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(builder: (context, setSheetState) {
            return Consumer<SongProvider>(
              builder: (context, provider, _) {
                final filteredSongs = provider.songs.where((s) {
                  if (searchQuery.isEmpty) return true;
                  final q = searchQuery.toLowerCase();
                  return s.title.toLowerCase().contains(q) ||
                      s.artist.toLowerCase().contains(q) ||
                      s.genre.toLowerCase().contains(q);
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text('Add Song', style: AppTypography.h2),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a song to add it to "${_setlist.name}"',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: AppSearchBar(
                              placeholder: 'Search songs...',
                              onChanged: (val) {
                                setSheetState(() => searchQuery = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: AppColors.primary),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showSongEditor();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredSongs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.library_music,
                                        size: 48,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3)),
                                    const SizedBox(height: 12),
                                    Text('No songs found',
                                        style: AppTypography.body.copyWith(
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filteredSongs.length,
                                itemBuilder: (context, index) {
                                  final song = filteredSongs[index];
                                  final alreadyInSetlist = _setlist.items
                                      .any((i) => i.songId == song.id);

                                  return GestureDetector(
                                    onTap: alreadyInSetlist
                                        ? null
                                        : () {
                                            _addSong(song);
                                            Navigator.pop(ctx);
                                          },
                                    child: Opacity(
                                      opacity: alreadyInSetlist ? 0.4 : 1.0,
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                  Icons.music_note,
                                                  color: AppColors.primary,
                                                  size: 22),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(song.title,
                                                      style:
                                                          AppTypography.body),
                                                  Text(
                                                    '${song.artist} • ${song.genre} • ${_getSubdivisionLabel(song.subdivision)}',
                                                    style:
                                                        AppTypography.caption,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  song.bpm.round().toString(),
                                                  style: AppTypography.h3
                                                      .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                Text('BPM',
                                                    style: AppTypography
                                                        .captionSmall),
                                              ],
                                            ),
                                            if (alreadyInSetlist) ...[
                                              const SizedBox(width: 8),
                                              const Icon(Icons.check_circle,
                                                  color: AppColors.success,
                                                  size: 20),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }

  String _getSubdivisionLabel(int sub) {
    switch (sub) {
      case 1: return '♩';
      case 2: return '♫';
      case 3: return '³♪';
      case 4: return '♬';
      default: return '1/$sub';
    }
  }

  Future<void> _addSong(Song song) async {
    final newItem = SetlistItem(
      songId: song.id,
      orderIndex: _setlist.items.length,
      song: song,
    );
    setState(() {
      _setlist.items.add(newItem);
    });
    await context.read<SetlistProvider>().updateSetlist(_setlist);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${song.title} added to setlist'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeSong(int index) async {
    final removedSong = _setlist.items[index].song;
    setState(() {
      _setlist.items.removeAt(index);
      // Reindex
      for (int i = 0; i < _setlist.items.length; i++) {
        _setlist.items[i].orderIndex = i;
      }
    });
    await context.read<SetlistProvider>().updateSetlist(_setlist);

    if (mounted && removedSong != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedSong.title} removed'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _reorderSongs(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _setlist.items.removeAt(oldIndex);
      _setlist.items.insert(newIndex, item);
      for (int i = 0; i < _setlist.items.length; i++) {
        _setlist.items[i].orderIndex = i;
      }
    });
    context.read<SetlistProvider>().updateSetlist(_setlist);
  }

  void _playSetlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSessionScreen(setlist: _setlist),
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
            _buildMetadataBar(),
            const SizedBox(height: 8),
            Expanded(
              child: _setlist.items.isEmpty
                  ? _buildEmptyState()
                  : _buildSongsList(),
            ),
            if (_setlist.items.isNotEmpty) _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              _setlist.name,
              style: AppTypography.h1.copyWith(fontSize: 22),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: _showAddSongDialog,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add,
                  color: AppColors.backgroundDark, size: 22),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMetadataBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          PillBadge(text: '${_setlist.items.length} Songs'),
          const SizedBox(width: 12),
          Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '${_setlist.totalDurationMinutes} mins',
            style: AppTypography.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music,
              size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No songs in this setlist',
              style:
                  AppTypography.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Tap + to add your first song',
              style: AppTypography.caption),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _showAddSongDialog,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Add Song',
                style: AppTypography.body.copyWith(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _setlist.items.length,
      onReorder: _reorderSongs,
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final item = _setlist.items[index];
        final song = item.song;

        return Dismissible(
          key: Key('dismiss_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 24),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Remove Song?', style: AppTypography.h2),
                content: Text(
                  'Remove "${song?.title ?? 'this song'}" from the setlist?',
                  style: AppTypography.body,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) => _removeSong(index),
          child: Container(
            key: Key('item_${item.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                // Song number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song?.title ?? 'Unknown',
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${song?.artist ?? ''} • ${song?.timeSignature.toString() ?? '4/4'}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                // BPM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.effectiveBpm.round().toString(),
                      style: AppTypography.h3
                          .copyWith(color: AppColors.primary, fontSize: 20),
                    ),
                    Text('BPM', style: AppTypography.captionSmall),
                  ],
                ),
                const SizedBox(width: 8),
                // Drag handle
                Icon(Icons.drag_handle,
                    color: AppColors.textTertiary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: GestureDetector(
        onTap: _playSetlist,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow,
                  color: AppColors.backgroundDark, size: 28),
              const SizedBox(width: 8),
              Text(
                'Play Setlist',
                style: AppTypography.h3.copyWith(
                  color: AppColors.backgroundDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                                _addSong(newSong);
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
                              GestureDetector(
                                onTap: () => setSheetState(() => tempAccent = !tempAccent),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: tempAccent ? AppColors.primary : AppColors.surface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.looks_one, color: tempAccent ? AppColors.backgroundDark : AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('ACCENT', style: AppTypography.caption),
                                  ],
                                ),
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
}

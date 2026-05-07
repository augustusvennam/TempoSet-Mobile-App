import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/setlist.dart';
import '../providers/setlist_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';
import 'setlist_detail_screen.dart';

/// Setlists management screen — matches Stitch wireframe exactly.
class SetlistsScreen extends StatefulWidget {
  const SetlistsScreen({super.key});

  @override
  State<SetlistsScreen> createState() => _SetlistsScreenState();
}

class _SetlistsScreenState extends State<SetlistsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SetlistProvider>().loadSetlists();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Map icon names to Material Icons.
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'event_note':
        return Icons.event_note;
      case 'church':
        return Icons.church;
      case 'preview':
        return Icons.preview;
      case 'local_bar':
        return Icons.local_bar;
      case 'music_note':
        return Icons.music_note;
      case 'star':
        return Icons.star;
      default:
        return Icons.event_note;
    }
  }

  void _showAddSetlistDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('New Setlist', style: AppTypography.h2),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: AppTypography.body,
          decoration: const InputDecoration(hintText: 'Setlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final setlist = Setlist(name: nameController.text.trim());
                context.read<SetlistProvider>().addSetlist(setlist);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
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
              placeholder: 'Search your setlists...',
              controller: _searchController,
              onChanged: (q) =>
                  context.read<SetlistProvider>().setSearchQuery(q),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildSetlistList()),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Setlists', style: AppTypography.h1),
              const SizedBox(height: 4),
              Text(
                'Organize your performances',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showAddSetlistDialog,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
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

  Widget _buildSetlistList() {
    return Consumer<SetlistProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.setlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_add,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No setlists yet',
                    style: AppTypography.h3
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Tap + to create your first setlist',
                    style: AppTypography.caption),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            ...provider.setlists.map((setlist) => Dismissible(
                  key: Key(setlist.id),
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
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Delete Setlist?',
                            style: AppTypography.h2),
                        content: Text(
                            'Are you sure you want to delete "${setlist.name}"?',
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
                  onDismissed: (_) => provider.deleteSetlist(setlist.id),
                  child: SetlistCard(
                    title: setlist.name,
                    songCount: setlist.songCount,
                    durationMinutes: setlist.totalDurationMinutes,
                    iconData: _getIcon(setlist.icon),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SetlistDetailScreen(setlist: setlist),
                        ),
                      ).then((_) {
                        // Refresh setlists when returning from detail
                        provider.loadSetlists();
                      });
                    },
                  ),
                )),
            // Help text
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Text(
                    'Swipe left on a setlist to delete or edit',
                    style: AppTypography.caption,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

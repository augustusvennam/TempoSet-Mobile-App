import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/setlist_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/song_provider.dart';
import 'screens/metronome_screen.dart';
import 'screens/setlists_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/songs_screen.dart';
import 'services/audio_service.dart';
import 'services/metronome_engine.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.navBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TempoSetApp());
}

class TempoSetApp extends StatefulWidget {
  const TempoSetApp({super.key});

  @override
  State<TempoSetApp> createState() => _TempoSetAppState();
}

class _TempoSetAppState extends State<TempoSetApp> {
  late final AudioService _audioService;
  late final MetronomeEngine _metronome;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _metronome = MetronomeEngine(_audioService);
    _audioService.initialize();
  }

  @override
  void dispose() {
    _metronome.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => SetlistProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: _metronome),
      ],
      child: MaterialApp(
        title: 'TempoSet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}

/// Main screen with bottom navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final metronome = context.read<MetronomeEngine>();
    
    final screens = [
      MetronomeScreen(metronome: metronome),
      const SongsScreen(),
      const SetlistsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.timer, 'METRONOME'),
              _buildNavItem(1, Icons.music_note, 'SONGS'),
              _buildNavItem(2, Icons.format_list_bulleted, 'SETLISTS'),
              _buildNavItem(3, Icons.settings, 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color:
                    isActive ? AppColors.primary : AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

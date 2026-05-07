import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Generates and plays metronome click sounds using flutter_soloud.
///
/// Uses file-based WAV playback for reliable, ultra-low-latency 
/// metronome audio across Android and iOS.
class AudioService {
  AudioSource? _clickSource;
  AudioSource? _accentSource;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize the SoLoud engine
    await SoLoud.instance.init();

    await _loadTone();
    _initialized = true;
  }

  Future<void> _loadTone() async {
    // Hardcoded tone settings for now
    final clickFreq = 800.0;
    final accentFreq = 1200.0;
    final clickMs = 30;
    final accentMs = 40;

    // Generate WAV files to cache directory
    final cacheDir = await getTemporaryDirectory();
    final clickPath = p.join(cacheDir.path, 'click.wav');
    final accentPath = p.join(cacheDir.path, 'accent.wav');

    final clickData = _generateClickWav(
      frequency: clickFreq,
      durationMs: clickMs,
      amplitude: 0.9,
    );
    final accentData = _generateClickWav(
      frequency: accentFreq,
      durationMs: accentMs,
      amplitude: 1.0,
    );

    await File(clickPath).writeAsBytes(clickData);
    await File(accentPath).writeAsBytes(accentData);

    // Dispose old sources if they exist
    if (_clickSource != null) SoLoud.instance.disposeSource(_clickSource!);
    if (_accentSource != null) SoLoud.instance.disposeSource(_accentSource!);

    // Pre-load the sources into SoLoud
    _clickSource = await SoLoud.instance.loadFile(clickPath);
    _accentSource = await SoLoud.instance.loadFile(accentPath);
  }

  /// Play a normal beat click.
  Future<void> playClick() async {
    if (!_initialized || _clickSource == null) return;
    try {
      SoLoud.instance.play(_clickSource!);
    } catch (_) {}
  }

  /// Play an accented downbeat click.
  Future<void> playAccent() async {
    if (!_initialized || _accentSource == null) return;
    try {
      SoLoud.instance.play(_accentSource!);
    } catch (_) {}
  }

  void dispose() {
    if (_clickSource != null) SoLoud.instance.disposeSource(_clickSource!);
    if (_accentSource != null) SoLoud.instance.disposeSource(_accentSource!);
    SoLoud.instance.deinit();
    _initialized = false;
  }

  /// Generate a simple WAV file with a sine wave click in memory.
  Uint8List _generateClickWav({
    required double frequency,
    required int durationMs,
    int sampleRate = 44100,
    double amplitude = 0.8,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final dataSize = numSamples * 2; // 16-bit mono
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    int offset = 0;

    // RIFF header
    void writeString(String s) {
      for (int i = 0; i < s.length; i++) {
        buffer.setUint8(offset++, s.codeUnitAt(i));
      }
    }

    void writeUint32(int value) {
      buffer.setUint32(offset, value, Endian.little);
      offset += 4;
    }

    void writeUint16(int value) {
      buffer.setUint16(offset, value, Endian.little);
      offset += 2;
    }

    writeString('RIFF');
    writeUint32(fileSize);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16); // chunk size
    writeUint16(1); // PCM
    writeUint16(1); // mono
    writeUint32(sampleRate);
    writeUint32(sampleRate * 2); // byte rate
    writeUint16(2); // block align
    writeUint16(16); // bits per sample
    writeString('data');
    writeUint32(dataSize);

    // Generate sine wave with exponential fade-out for punchier sound
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      // Exponential decay for snappier attack
      final envelope = exp(-5.0 * progress);
      final sample = (sin(2.0 * pi * frequency * t) * amplitude * envelope);
      final intSample = (sample * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}

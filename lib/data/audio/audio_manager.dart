import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager with WidgetsBindingObserver {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer  = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicOn   = true;
  bool _isSfxOn     = true;
  bool _initialized = false;
  bool _pausedByLifecycle = false;

  // ── Khởi tạo ──────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music_enabled') ?? true; // ✅ key riêng
    _isSfxOn   = prefs.getBool('sfx_enabled')   ?? true; // ✅ key riêng
  }

  // ── Lifecycle ─────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pausedByLifecycle = true;
        _bgPlayer.pause();
        break;
      case AppLifecycleState.resumed:
        if (_pausedByLifecycle && _isMusicOn) {
          _pausedByLifecycle = false;
          _bgPlayer.resume();
        }
        break;
      default:
        break;
    }
  }

  // ── Nhạc nền ──────────────────────────────────────────
  Future<void> playBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music_enabled') ?? true; // ✅

    if (!_isMusicOn) return;

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.5);
    await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicOn) return;
    await _bgPlayer.resume();
  }

  // ── Hiệu ứng âm thanh ─────────────────────────────────
  Future<void> playSfx(String file) async {
    final prefs = await SharedPreferences.getInstance();
    _isSfxOn = prefs.getBool('sfx_enabled') ?? true; // ✅ đọc realtime

    if (!_isSfxOn) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$file'));
    } catch (e) {
      debugPrint('SFX error: $e');
    }
  }

  Future<void> playCorrect()   async => playSfx('correct.mp3');
  Future<void> playWrong()     async => playSfx('wrong.mp3');
  Future<void> playClick()     async => playSfx('click.mp3');
  Future<void> playCountdown() async => playSfx('countdown.mp3');
  Future<void> playWin()       async => playSfx('win.mp3');
  Future<void> playLose()      async => playSfx('loss.mp3');

  Future<void> stopSfx() async {
    await _sfxPlayer.stop();
  }

  // ── Settings (tách riêng 2 hàm) ───────────────────────
  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicOn = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled); // ✅

    if (enabled) {
      await resumeBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _isSfxOn = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', enabled); // ✅

    if (!enabled) await stopSfx();
  }

  // Giữ lại để không breaking change chỗ nào đang dùng
  Future<void> setSoundEnabled(bool enabled) async {
    await setMusicEnabled(enabled);
    await setSfxEnabled(enabled);
  }

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn   => _isSfxOn;
  bool get isSoundOn => _isMusicOn; // giữ lại để tương thích

  // ── Dọn dẹp ───────────────────────────────────────────
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
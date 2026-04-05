import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer  = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Trạng thái in-memory — luôn sync với SharedPreferences
  bool _isMusicOn = true;
  bool _isSfxOn   = true;
  bool _initialized = false;

  // ── Khởi tạo: đọc setting đã lưu ─────────────────────
  // Gọi 1 lần duy nhất khi app start (trong main.dart hoặc HomeScreen)
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('sound_enabled') ?? true;
    _isSfxOn   = prefs.getBool('sound_enabled') ?? true;
  }

  // ── Nhạc nền ──────────────────────────────────────────

  Future<void> playBackgroundMusic() async {
    // Đọc lại setting trước khi play để chắc chắn
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('sound_enabled') ?? true;

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
  Future<void> playWin()     async => playSfx('win.mp3');
  Future<void> playLose() async => playSfx('loss.mp3');

  Future<void> stopSfx() async {
    await _sfxPlayer.stop();
  }

  // Đây là method được gọi từ Settings dialog
  Future<void> setSoundEnabled(bool enabled) async {
    _isMusicOn = enabled;
    _isSfxOn   = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    if (enabled) {
      await resumeBackgroundMusic();
    } else {
      await stopBackgroundMusic();
      await stopSfx();
    }
  }

  bool get isSoundOn => _isMusicOn;

  // ── Toggle (dùng nội bộ nếu cần) ─────────────────────
  Future<void> toggleMusic() async {
    await setSoundEnabled(!_isMusicOn);
  }

  // ── Dọn dẹp ───────────────────────────────────────────
  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
  
}
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/profile/widgets/mission_dialog.dart';
import 'package:dovui/pages/profile/widgets/profile_avatar_header.dart';
import 'package:dovui/pages/profile/widgets/profile_stat_card.dart';
import 'package:dovui/pages/settings/settings_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/profile/widgets/profile_shimmer.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _canCheckIn = true;
  bool _videoWatched = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final isSoundOn = prefs.getBool('sound_enabled') ?? true;
    await AudioManager().init();
    if (isSoundOn) {
      AudioManager().resumeBackgroundMusic();
    } else {
      AudioManager()
        ..stopBackgroundMusic()
        ..stopSfx();
    }
    AudioManager().playBackgroundMusic();
  }

  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool("isAdmin") ?? false;

    final lastCheckIn = prefs.getString('last_check_in');
    _canCheckIn = lastCheckIn == null || !_isSameDay(DateTime.parse(lastCheckIn));

    final lastVideo = prefs.getString('last_video_watch');
    _videoWatched = lastVideo != null && _isSameDay(DateTime.parse(lastVideo));

    if (mounted) setState(() {});
  }

  bool _isSameDay(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  String get _missionPercent {
    final done = [!_canCheckIn, _videoWatched].where((e) => e).length;
    return '${done * 50}%';
  }

  Color _avatarColorFromName(String name) {
    if (name.isEmpty) return Colors.grey;
    const colors = [
      Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFF43C6AC),
      Color(0xFFFF9A3C), Color(0xFF4FACFE), Color(0xFFA18CD1), Color(0xFFFDA085),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Future<void> _doCheckIn(String userId, int currentScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_check_in', DateTime.now().toIso8601String());
    await UserRepository().updateScore(userId, currentScore + 10);
    if (mounted) setState(() => _canCheckIn = false);
  }

  Future<void> _doWatchVideo(
    BuildContext context,
    String userId,
    int score,
    StateSetter setStateDialog,
  ) async {
    if (!RewardedAdManager().isAdLoaded) {
      _showSnackBar(context, '⏳ Quảng cáo chưa sẵn sàng, thử lại sau!', Colors.orange);
      return;
    }

    RewardedAdManager().showAd(
      onRewarded: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_video_watch', DateTime.now().toIso8601String());
        await UserRepository().updateScore(userId, score + 10);
        if (mounted) setState(() => _videoWatched = true);
        setStateDialog(() {});
        if (context.mounted) {
          _showSnackBar(context, '🎉 Cảm ơn bạn! +10 ⭐', const Color(0xFF6C63FF));
        }
      },
      onFailed: () {
        if (context.mounted) {
          _showSnackBar(context, '❌ Không tải được quảng cáo, thử lại sau!', Colors.red);
        }
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showMissionDialog(BuildContext context, String userId, int score) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          AudioManager().playClick();
          return MissionDialog(
            canCheckIn: _canCheckIn,
            videoWatched: _videoWatched,
            onCheckIn: () async {
              await _doCheckIn(userId, score);
              setStateDialog(() {});
              if (context.mounted) {
                _showSnackBar(context, '✅ Điểm danh thành công! +10 ⭐', const Color(0xFF43C6AC));
              }
            },
            onWatchVideo: () => _doWatchVideo(context, userId, score, setStateDialog),
            onClose: () {
              AudioManager().playBackgroundMusic();
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _openSettings() {
    AudioManager().playClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FF),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) return const ProfileShimmer();

            String name = "Admin";
            int score = 0;
            int rank = 0;
            String userId = '';

            if (state is UserRegistered) {
              name = state.user.name;
              score = state.user.score;
              rank = state.user.rank;
              userId = state.user.id;
            }

            final avatarColor = _avatarColorFromName(name);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                children: [
                  ProfileAvatarHeader(
                    name: name,
                    avatarColor: avatarColor,
                    onSettingsTap: _openSettings,
                  ),
                  const SizedBox(height: 70),
                  _buildNameSection(name, avatarColor),
                  const SizedBox(height: 30),
                  _buildStatsRow(context, userId, score, rank),
                  const SizedBox(height: 28),
                  _buildAchievementBanner(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RepaintBoundary(child: NativeAdWidget()),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameSection(String name, Color avatarColor) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1B4B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: ColorManager.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "@${name.toLowerCase()}",
            style: TextStyle(
              fontSize: 14,
              color: ColorManager.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, String userId, int score, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ProfileStatCard(
            value: _missionPercent,
            label: "Nhiệm vụ",
            icon: "📋",
            color: const Color(0xFF43C6AC),
            onTap: () => _showMissionDialog(context, userId, score),
          ),
          const SizedBox(width: 12),
          ProfileStatCard(
            value: "$score",
            label: "Điểm số",
            icon: "⭐",
            color: const Color(0xFFFFB347),
          ),
          const SizedBox(width: 12),
          ProfileStatCard(
            value: "#$rank",
            label: "Xếp hạng",
            icon: "🏆",
            color: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.15),
              const Color(0xFF43C6AC).withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Text("🎮", style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Người chơi tích cực",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tiếp tục chinh phục các thử thách!",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
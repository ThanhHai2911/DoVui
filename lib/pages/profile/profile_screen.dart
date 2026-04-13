import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
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
    _applySavedSoundSetting();
    AudioManager().init().then((_) {
      AudioManager().playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _applySavedSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final isSoundOn = prefs.getBool('sound_enabled') ?? true;
    if (isSoundOn) {
      AudioManager().resumeBackgroundMusic();
    } else {
      AudioManager().stopBackgroundMusic();
      AudioManager().stopSfx();
    }
  }

  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool("isAdmin") ?? false;

    final lastCheckIn = prefs.getString('last_check_in');
    if (lastCheckIn == null) {
      _canCheckIn = true;
    } else {
      final last = DateTime.parse(lastCheckIn);
      final now = DateTime.now();
      _canCheckIn = !(last.year == now.year &&
          last.month == now.month &&
          last.day == now.day);
    }

    final lastVideo = prefs.getString('last_video_watch');
    if (lastVideo == null) {
      _videoWatched = false;
    } else {
      final last = DateTime.parse(lastVideo);
      final now = DateTime.now();
      _videoWatched = last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
    }

    setState(() {});
  }

  String get _missionPercent {
    int done = 0;
    if (!_canCheckIn) done++;
    if (_videoWatched) done++;
    return '${done * 50}%';
  }

  Future<void> _doCheckIn(String userId, int currentScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_check_in', DateTime.now().toIso8601String());
    await UserRepository().updateScore(userId, currentScore + 10);
    setState(() => _canCheckIn = false);
  }

  Future<void> _doWatchVideo(
    BuildContext context,
    String userId,
    int score,
    StateSetter setStateDialog,
  ) async {
    if (!RewardedAdManager().isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Quảng cáo chưa sẵn sàng, thử lại sau!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    RewardedAdManager().showAd(
      onRewarded: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_video_watch', DateTime.now().toIso8601String());
        await UserRepository().updateScore(userId, score + 10);
        setState(() => _videoWatched = true);
        setStateDialog(() {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Cảm ơn bạn! +10 ⭐'),
              backgroundColor: Color(0xFF6C63FF),
            ),
          );
        }
      },
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Không tải được quảng cáo, thử lại sau!'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _showMissionDialog(BuildContext context, String userId, int score) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          AudioManager().playClick();
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🎯 Nhiệm vụ hàng ngày",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMissionRow(
                    icon: "📅",
                    title: "Điểm danh hàng ngày",
                    reward: "+10 ⭐",
                    color: const Color(0xFF43C6AC),
                    done: !_canCheckIn,
                    onTap: !_canCheckIn
                        ? null
                        : () async {
                            await _doCheckIn(userId, score);
                            setStateDialog(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Điểm danh thành công! +10 ⭐'),
                                  backgroundColor: Color(0xFF43C6AC),
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  _buildMissionRow(
                    icon: "🎬",
                    title: "Xem video nhận thưởng",
                    reward: "+10 ⭐",
                    color: const Color(0xFF6C63FF),
                    done: _videoWatched,
                    onTap: _videoWatched
                        ? null
                        : () => _doWatchVideo(context, userId, score, setStateDialog),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        AudioManager().playBackgroundMusic();
                        Navigator.pop(ctx);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Đóng",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSettings() {
    AudioManager().playClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Widget _buildMissionRow({
    required String icon,
    required String title,
    required String reward,
    required Color color,
    required bool done,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: done ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B)),
                ),
              ),
              done
                  ? const Text("✅ Hoàn thành",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(reward,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorByName(String name) {
    if (name.isEmpty) return Colors.grey;
    final code = name.codeUnitAt(0);
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF43C6AC),
      const Color(0xFFFF9A3C),
      const Color(0xFF4FACFE),
      const Color(0xFFA18CD1),
      const Color(0xFFFDA085),
    ];
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
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

            final avatarColor = _getColorByName(name);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                children: [
                  /// HEADER
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [avatarColor, avatarColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: SafeArea(
                          child: Stack(
                            children: [
                              Positioned(
                                top: -20, right: -20,
                                child: Container(width: 120, height: 120,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08))),
                              ),
                              Positioned(
                                top: 30, right: 50,
                                child: Container(width: 60, height: 60,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08))),
                              ),
                              Positioned(
                                bottom: 10, left: 20,
                                child: Container(width: 80, height: 80,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.06))),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text("Hồ Sơ",
                                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                                        color: Colors.white, letterSpacing: 1)),
                                ),
                              ),
                              // ── NÚT CÀI ĐẶT ──
                              Positioned(
                                top: 20, right: 16,
                                child: GestureDetector(
                                  onTap: _openSettings,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.settings, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -55, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: avatarColor.withOpacity(0.4),
                                    blurRadius: 20, spreadRadius: 2)
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: avatarColor,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "A",
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold, fontSize: 42),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  Text(name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: ColorManager.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("@${name.toLowerCase()}",
                      style: TextStyle(fontSize: 14, color: ColorManager.primaryColor,
                          fontWeight: FontWeight.w500)),
                  ),

                  const SizedBox(height: 30),

                  /// STATS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildStatCard(
                          value: _missionPercent, label: "Nhiệm vụ", icon: "📋",
                          color: const Color(0xFF43C6AC),
                          onTap: () => _showMissionDialog(context, userId, score),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(value: "$score", label: "Điểm số",
                            icon: "⭐", color: const Color(0xFFFFB347)),
                        const SizedBox(width: 12),
                        _buildStatCard(value: "#$rank", label: "Xếp hạng",
                            icon: "🏆", color: const Color(0xFF6C63FF)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ACHIEVEMENT BANNER
                  Padding(
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
                              const Text("Người chơi tích cực",
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 15, color: Color(0xFF1E1B4B))),
                              const SizedBox(height: 4),
                              Text("Tiếp tục chinh phục các thử thách!",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // const SizedBox(height: 28),

                  // // Native Ad
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: RepaintBoundary(child: NativeAdWidget()),
                  // ),

                  const SizedBox(height: 20),
                  // ── Nút đăng xuất đã chuyển sang SettingsScreen ──
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required String icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))
            ],
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
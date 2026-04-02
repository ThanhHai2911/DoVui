import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/user/login_screen.dart';
import 'package:dovui/pages/user/register_screen.dart';
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
  }

  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Admin
    _isAdmin = prefs.getBool("isAdmin") ?? false;

    // Check in
    final lastCheckIn = prefs.getString('last_check_in');
    if (lastCheckIn == null) {
      _canCheckIn = true;
    } else {
      final last = DateTime.parse(lastCheckIn);
      final now = DateTime.now();
      _canCheckIn =
          !(last.year == now.year &&
              last.month == now.month &&
              last.day == now.day);
    }

    // Video
    final lastVideo = prefs.getString('last_video_watch');
    if (lastVideo == null) {
      _videoWatched = false;
    } else {
      final last = DateTime.parse(lastVideo);
      final now = DateTime.now();
      _videoWatched =
          last.year == now.year &&
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

  void _showMissionDialog(BuildContext context, String userId, int score) {
    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
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

                      // Điểm danh
                      _buildMissionRow(
                        icon: "📅",
                        title: "Điểm danh hàng ngày",
                        reward: "+10 ⭐",
                        color: const Color(0xFF43C6AC),
                        done: !_canCheckIn,
                        onTap:
                            !_canCheckIn
                                ? null
                                : () async {
                                  await _doCheckIn(userId, score);
                                  setStateDialog(() {});
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '✅ Điểm danh thành công! +10 ⭐',
                                        ),
                                        backgroundColor: Color(0xFF43C6AC),
                                      ),
                                    );
                                  }
                                },
                      ),

                      const SizedBox(height: 12),

                      // Xem video
                      _buildMissionRow(
                        icon: "🎬",
                        title: "Xem video nhận thưởng",
                        reward: "+10 ⭐",
                        color: const Color(0xFF6C63FF),
                        done: false,
                        onTap: () {
                          Navigator.pop(ctx);
                          showGameDialog(
                            context: context,
                            icon: "🛠️",
                            iconColor: Colors.orange,
                            title: "Tính năng đang phát triển",
                            description:
                                "Chức năng xem video đang được cập nhật.\nVui lòng quay lại sau nhé!",
                            costIcon: "⭐",
                            costText: "Sắp ra mắt",
                            confirmText: "Đã hiểu",
                            confirmColor: Colors.orange,
                            showCancel: false,
                            onConfirm: () {},
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Đóng",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
              done
                  ? const Text(
                    "✅ Hoàn thành",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reward,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) return const ProfileShimmer();

          String name = "Admin";
          int score = 0;
          String correct = "0%";
          int rank = 0;
          String userId = '';

          if (state is UserRegistered) {
            name = state.user.name;
            score = state.user.score;
            rank = state.user.rank;
            userId = state.user.id;
            correct = "0%";
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
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              right: 50,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  "Hồ Sơ",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -55,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: avatarColor.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: avatarColor,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "A",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
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

                const SizedBox(height: 30),

                /// STATS — nhấn vào "Nhiệm vụ" mở dialog
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard(
                        value: _missionPercent,
                        label: "Nhiệm vụ",
                        icon: "📋",
                        color: const Color(0xFF43C6AC),
                        onTap: () => _showMissionDialog(context, userId, score),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        value: "$score",
                        label: "Điểm số",
                        icon: "⭐",
                        color: const Color(0xFFFFB347),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        value: "#$rank",
                        label: "Xếp hạng",
                        icon: "🏆",
                        color: const Color(0xFF6C63FF),
                      ),
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
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                      ),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// LOGOUT
                if (state is UserRegistered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap:
                          () => showGameDialog(
                            context: context,
                            icon: "👋",
                            iconColor: Colors.red,
                            title: "Đăng xuất?",
                            description:
                                "Bạn có chắc muốn thoát không?\nTiến trình của bạn sẽ được lưu lại.",
                            costIcon: "💾",
                            costText: "Dữ liệu được lưu",
                            confirmText: "Đăng xuất",
                            confirmColor: Colors.red,
                            onConfirm: () {
                              context.read<UserBloc>().add(LogoutUserEvent());
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Đăng xuất",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

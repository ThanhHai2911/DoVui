import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/profile/widgets/mission_dialog.dart';
import 'package:dovui/pages/profile/widgets/profile_avatar_header.dart';
import 'package:dovui/pages/profile/widgets/profile_stat_card.dart';
import 'package:dovui/pages/profile/widgets/vip_dialog.dart';
import 'package:dovui/pages/room/bloc/room_bloc.dart';
import 'package:dovui/pages/room/bloc/room_event.dart';
import 'package:dovui/pages/room/create_room_screen.dart';
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
  static const int _maxRoomsPerPeriod = 3;
  static const int _periodDays = 7;

Future<int> _getRoomCreationCount(String userId) async {
  if (userId.isEmpty) return 0;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  final raw = List<String>.from(doc.data()?['roomCreationDates'] ?? []);
  final cutoff = DateTime.now().subtract(const Duration(days: _periodDays));

  final recent = raw
      .map((s) => DateTime.tryParse(s))
      .whereType<DateTime>()
      .where((d) => d.isAfter(cutoff))
      .toList();

  // Dọn dẹp dữ liệu cũ luôn (write-back)
  if (recent.length != raw.length) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'roomCreationDates': recent.map((d) => d.toIso8601String()).toList(),
    });
  }

  return recent.length;
}

Future<void> _recordRoomCreation(String userId) async {
  if (userId.isEmpty) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    'roomCreationDates': FieldValue.arrayUnion([
      DateTime.now().toIso8601String(),
    ]),
  });
}

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
    _canCheckIn =
        lastCheckIn == null || !_isSameDay(DateTime.parse(lastCheckIn));

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
      Color(0xFF6C63FF),
      Color(0xFFFF6584),
      Color(0xFF43C6AC),
      Color(0xFFFF9A3C),
      Color(0xFF4FACFE),
      Color(0xFFA18CD1),
      Color(0xFFFDA085),
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

  void _navigateToCreateRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => RoomBloc()..add(LoadCategories()),
          child: const CreateRoomScreen(),
        ),
      ),
    );
  }

  void _onTapCreateRoom(BuildContext context, String userId, int score) async {
  AudioManager().playClick();

  if (AdsService().isVip) {
    _navigateToCreateRoom(context);
    return;
  }

  // ✅ Truyền userId vào
  final count = await _getRoomCreationCount(userId);

  if (!mounted) return;

  if (count >= _maxRoomsPerPeriod) {
    showGameDialog(
      context: context,
      icon: '🔒',
      iconColor: Colors.red,
      title: 'Hết lượt tạo phòng',
      description:
          'Bạn đã tạo $_maxRoomsPerPeriod phòng trong $_periodDays ngày qua.\n'
          'Nâng VIP để tạo phòng không giới hạn!',
      costIcon: '👑',
      costText: 'Nâng cấp VIP ngay!',
      confirmText: 'Mua VIP',
      confirmColor: Colors.amber.shade600,
      showCancel: true,
      onConfirm: () => _onTapBuyVip(context),
    );
    return;
  }

  showGameDialog(
    context: context,
    icon: '🎮',
    iconColor: Colors.amber,
    title: 'Tạo phòng chơi',
    description:
        'Xem 1 quảng cáo ngắn để tạo phòng \n chơi cùng bạn bè!\n'
        '(${_maxRoomsPerPeriod - count} lượt còn lại trong $_periodDays ngày)',
    costIcon: '🕹️',
    costText: 'Hãy tạo phòng ngay!',
    confirmText: 'Xem ngay',
    confirmColor: Colors.amber.shade600,
    showCancel: true,
    onConfirm: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRewardedAdForRoom(context, userId); // ✅ truyền userId
      });
    },
  );
}

  void _showRewardedAdForRoom(BuildContext context, String userId) {
  if (!RewardedAdManager().isAdLoaded) {
    _showSnackBar(context, '⏳ Quảng cáo chưa sẵn sàng, thử lại sau!', Colors.orange);
    return;
  }

  RewardedAdManager().showAd(
    onRewarded: () async {
      await _recordRoomCreation(userId); // ✅ lưu lên Firestore
      if (!mounted) return;
      _navigateToCreateRoom(context);
    },
    onFailed: () {
      if (!mounted) return;
      _showSnackBar(context, '❌ Không tải được quảng cáo, thử lại sau!', Colors.red);
    },
  );
}

  void _onTapBuyVip(BuildContext context) {
  AudioManager().playClick();
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => const VipDialog(),
  );
}

  void _openSettings() {
    AudioManager().playClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
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
            bool isVip = false;

            if (state is UserRegistered) {
              name = state.user.name;
              score = state.user.score;
              rank = state.user.rank;
              userId = state.user.id;
              isVip = state.user.isVip;

              AdsService().setVip(isVip);
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
                    isVip: state is UserRegistered ? state.user.isVip : false,
                  ),
                  const SizedBox(height: 70),
                  _buildNameSection(name, avatarColor),
                  const SizedBox(height: 30),
                  _buildStatsRow(context, userId, score, rank),
                  const SizedBox(height: 28),
                  _buildVipBanner(context, isVip: isVip),
                  const SizedBox(height: 28),
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

  Widget _buildVipBanner(BuildContext context, {required bool isVip}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: isVip ? null : () => _onTapBuyVip(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isVip
                  ? [const Color(0xFF43C6AC), const Color(0xFF6C63FF)]
                  : [const Color(0xFFFFB347), const Color(0xFFFF6584)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isVip ? const Color(0xFF43C6AC) : const Color(0xFFFFB347))
                    .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/vip.gif', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVip ? "Bạn là VIP 👑" : "Gói VIP",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVip
                          ? "Tận hưởng toàn bộ đặc quyền VIP ✨"
                          : "Không quảng cáo • Chơi không giới hạn",
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (!isVip)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                )
              else
                const Icon(Icons.verified, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
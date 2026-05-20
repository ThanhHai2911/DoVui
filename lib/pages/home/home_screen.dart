import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/firebase_quiz_repository.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/home/widgets/animated_section.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/profile/widgets/vip_dialog.dart';
import 'package:dovui/pages/room/bloc/room_bloc.dart';
import 'package:dovui/pages/room/bloc/room_event.dart';
import 'package:dovui/pages/room/create_room_screen.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/home/bloc/home_bloc.dart';
import 'package:dovui/pages/home/bloc/home_event.dart';
import 'package:dovui/pages/home/bloc/home_state.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/quiz_of_week.dart';
import 'widgets/categories_section.dart';
import 'widgets/home_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late AnimationController _floatCtrl;
  late Animation<double> _float;

  static const int _maxRoomsPerPeriod = 3;
  static const int _periodDays = 7;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();

    AudioManager().init().then((_) {
      AudioManager().playBackgroundMusic();
    });

    if (AdsService().isVip) return;
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ── Room Creation Logic ───────────────────────────────────────────────────

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
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

  void _onTapBuyVip(BuildContext context) {
    AudioManager().playClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const VipDialog(),
    );
  }

  void _showRewardedAdForRoom(BuildContext context, String userId) {
    if (!RewardedAdManager().isAdLoaded) {
      _showSnackBar(
          context, '⏳ Quảng cáo chưa sẵn sàng, thử lại sau!', Colors.orange);
      return;
    }
    RewardedAdManager().showAd(
      onRewarded: () async {
        await _recordRoomCreation(userId);
        if (!mounted) return;
        _navigateToCreateRoom(context);
      },
      onFailed: () {
        if (!mounted) return;
        _showSnackBar(
            context, '❌ Không tải được quảng cáo, thử lại sau!', Colors.red);
      },
    );
  }

  void _onTapCreateRoom(BuildContext context, String userId) async {
    AudioManager().playClick();

    if (AdsService().isVip) {
      _navigateToCreateRoom(context);
      return;
    }

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
          'Xem 1 quảng cáo ngắn để tạo phòng\nchơi cùng bạn bè!\n'
          '(${_maxRoomsPerPeriod - count} lượt còn lại trong $_periodDays ngày)',
      costIcon: '🕹️',
      costText: 'Hãy tạo phòng ngay!',
      confirmText: 'Xem ngay',
      confirmColor: Colors.amber.shade600,
      showCancel: true,
      onConfirm: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showRewardedAdForRoom(context, userId);
        });
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create: (_) => HomeBloc()..add(LoadHome()),
        child: Scaffold(
          backgroundColor: ColorManager.scaffoldBackground,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        top: -60 + _float.value,
                        left: -40,
                        child: _blob(200, const Color(0xFF6C63FF), 0.07),
                      ),
                      Positioned(
                        top: 260 - _float.value,
                        right: -50,
                        child: _blob(160, const Color(0xFFFF6584), 0.06),
                      ),
                      Positioned(
                        bottom: 120 + _float.value,
                        left: -40,
                        child: _blob(150, const Color(0xFF43C6AC), 0.06),
                      ),
                    ],
                  );
                },
              ),
              SafeArea(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) return const HomeShimmer();

                    if (state is HomeLoaded) {
                      final size = MediaQuery.sizeOf(context);
                      return FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              size.width * 0.06,
                              0,
                              size.width * 0.06,
                              70,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const HomeHeader(),
                                const SizedBox(height: 25),

                                // ── Streak Card ──
                                AnimatedSection(
                                  delay: 0,
                                  child: StreakCard(
                                    days: state.days,
                                    name: state.name,
                                    score: state.score,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // ── Tạo phòng chơi ──
                                AnimatedSection(
                                  delay: 120,
                                  child: QuizOfWeek(
                                    userId: state.userId,
                                    onTapCreateRoom: () => _onTapCreateRoom(
                                      context,
                                      state.userId,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // ── Categories ──
                                AnimatedSection(
                                  delay: 240,
                                  child: CategoriesSection(
                                    quizService: QuizService(
                                        FirebaseQuizRepository()),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                if (!state.isVip) ...[
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Quảng cáo",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E1B4B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const RepaintBoundary(
                                    child: NativeAdWidget(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
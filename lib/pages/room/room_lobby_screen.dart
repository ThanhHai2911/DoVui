import 'dart:async';
import 'package:dovui/data/models/room_model.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:dovui/pages/room/widgets/completion_dialog.dart';
import 'package:dovui/pages/room/widgets/confirm_leave_dialog.dart';
import 'package:dovui/pages/room/widgets/leaderboard_widget.dart';
import 'package:dovui/pages/room/widgets/playing_header.dart';
import 'package:dovui/pages/room/widgets/room_code_card.dart';
import 'package:dovui/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/room_bloc.dart';
import 'bloc/room_event.dart';
import 'bloc/room_state.dart';

class RoomLobbyScreen extends StatefulWidget {
  final String currentUserId;
  final String? initialRoomId;
  final bool justJoined;

  const RoomLobbyScreen({
    super.key,
    required this.currentUserId,
    this.initialRoomId,
    this.justJoined = false,
  });

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  Timer? _heartbeatTimer;
  StreamSubscription? _presenceSub;
  Map<String, int> _presenceMap = {};

  bool _myFinishedShowing = false;
  RoomStatus? _prevStatus;
  String? _prevRoomId;
  List<RoomPlayer>? _prevPlayers;
  bool _shouldStayInRoom = false;
  bool _completionDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _prevStatus = context.read<RoomBloc>().state.status;

    final roomId = widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;
    if (roomId != null) _startPresenceStream(roomId);

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {});
  }

  void _startPresenceStream(String roomId) {
    _presenceSub?.cancel();
    _presenceSub = RoomService.presenceStream(roomId).listen((map) {
      if (mounted && map != _presenceMap) setState(() => _presenceMap = map);
    });
  }

  @override
  void dispose() {
    _presenceSub?.cancel();
    _heartbeatTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _playersChanged(List<RoomPlayer>? prev, List<RoomPlayer>? curr) {
    if (prev == null || curr == null) return prev != curr;
    if (prev.length != curr.length) { _prevPlayers = curr; return true; }
    for (int i = 0; i < prev.length; i++) {
      if (i >= curr.length) { _prevPlayers = curr; return true; }
      final p = prev[i], c = curr[i];
      if (p.userId != c.userId || p.score != c.score || p.isFinished != c.isFinished || p.isHost != c.isHost) {
        _prevPlayers = curr;
        return true;
      }
    }
    return false;
  }

  Future<void> _onPlayerFinished(RoomModel room) async {
    if (_myFinishedShowing) return;
    if (context.read<RoomBloc>().state.status != RoomStatus.playing) return;

    _myFinishedShowing = true;
    _shouldStayInRoom = true;
    if (mounted) setState(() {});

    await RoomService.markPlayerFinished(room.roomId, widget.currentUserId);
    if (!mounted) return;
    _showCompletionDialog(room);
  }

  void _showCompletionDialog(RoomModel room) {
    if (_completionDialogOpen) return;
    final latestRoom = context.read<RoomBloc>().state.room ?? room;
    final currentPlayer = latestRoom.players.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => room.players.firstWhere(
        (p) => p.userId == widget.currentUserId,
        orElse: () => room.players.first,
      ),
    );

    _completionDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => CompletionDialog(
        score: currentPlayer.score,
        playerName: currentPlayer.displayName,
        onClose: () => Navigator.of(context).pop(),
      ),
    ).then((_) { if (mounted) _completionDialogOpen = false; });
  }

  void _closeCompletionDialogIfOpen() {
    if (!_completionDialogOpen) return;
    _completionDialogOpen = false;
    try { Navigator.of(context, rootNavigator: false).maybePop(); } catch (_) {}
  }

  Future<void> _onScoreUpdate(RoomModel room, int delta) async {
    try {
      await RoomService.updateScore(roomId: room.roomId, userId: widget.currentUserId, delta: delta);
    } catch (e) { debugPrint('Error updating score: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocConsumer<RoomBloc, RoomState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.room?.roomId != curr.room?.roomId ||
            _playersChanged(prev.room?.players, curr.room?.players),
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.isHost != curr.isHost ||
            prev.room?.roomId != curr.room?.roomId ||
            _playersChanged(prev.room?.players, curr.room?.players),
        listener: (context, state) {
          final skipNavigation = _shouldStayInRoom;

          if (state.room?.roomId != _prevRoomId) {
            _prevRoomId = state.room?.roomId;
            _prevPlayers = state.room?.players;
          }

          if (state.room != null && _presenceSub == null) {
            _startPresenceStream(state.room!.roomId);
          }

          if (!skipNavigation && state.status == RoomStatus.initial && _prevStatus != RoomStatus.initial) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phòng đã bị đóng'), backgroundColor: Color(0xFFE24B4A)),
            );
          }

          if (_prevStatus == RoomStatus.playing && state.status == RoomStatus.waiting) {
            _closeCompletionDialogIfOpen();
            _myFinishedShowing = false;
            _shouldStayInRoom = false;
          }

          _prevStatus = state.status;
        },
        builder: (context, state) {
          final room = state.room;

          if (room == null && _shouldStayInRoom) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang kết nối phòng...'),
                  ],
                ),
              ),
            );
          }

          if (room == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

          final isHost = state.isHost || room.players.any((p) => p.userId == widget.currentUserId && p.isHost);
          final playerMatch = room.players.where((p) => p.userId == widget.currentUserId);
          final myFinished = playerMatch.isEmpty ? false : playerMatch.first.isFinished;

          if (state.status == RoomStatus.playing) {
            if (myFinished || _myFinishedShowing) return _buildWaitingLobby(context, room, isHost);
            return _buildPlayingView(context, room);
          }

          return _buildWaitingLobby(context, room, isHost);
        },
      ),
    );
  }

  // ─── Waiting Lobby ────────────────────────────────────────────────────────

  Widget _buildWaitingLobby(BuildContext context, RoomModel room, bool isHost) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, room, isHost),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    RoomCodeCard(roomId: room.roomId, password: room.password, pulseAnim: _pulseAnim),
                    const SizedBox(height: 16),
                    LeaderboardWidget(players: room.players, currentUserId: widget.currentUserId),
                    const SizedBox(height: 20),
                    if (isHost) _buildStartButton(context, room),
                    if (!isHost) _buildWaitingMessage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Playing View ─────────────────────────────────────────────────────────

  Widget _buildPlayingView(BuildContext context, RoomModel room) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            PlayingHeader(room: room, currentUserId: widget.currentUserId),
            Expanded(
              child: QuizScreen(
                categoryId: room.categoryId,
                type: room.type,
                onScoreUpdate: (delta) {
                  final currentRoom = context.read<RoomBloc>().state.room;
                  if (currentRoom != null) _onScoreUpdate(currentRoom, delta);
                },
                onFinished: () {
                  final currentRoom = context.read<RoomBloc>().state.room;
                  if (currentRoom != null) _onPlayerFinished(currentRoom);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, RoomModel room, bool isHost) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _confirmLeave(context, room),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF1E1B4B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phòng chờ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                Text(room.categoryName, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFFAEEDA), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👑', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text('Chủ phòng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF633806))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, RoomModel room) {
    final canStart = room.players.length >= 2;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canStart
                ? () {
                    final bloc = context.read<RoomBloc>();
                    if (bloc.isClosed) return;
                    _myFinishedShowing = false;
                    _shouldStayInRoom = false;
                    bloc.add(StartGame());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              disabledBackgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              canStart ? 'Bắt đầu chơi 🚀' : 'Cần ít nhất 2 người trong phòng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: canStart ? Colors.white : Colors.grey.shade400),
            ),
          ),
        ),
        if (!canStart) ...[
          const SizedBox(height: 8),
          Text('${room.players.length}/2 người trong phòng', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ],
    );
  }

  Widget _buildWaitingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Text('⏳', style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text('Chờ chủ phòng bắt đầu...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF534AB7))),
          SizedBox(height: 4),
          Text('Bạn đã tham gia phòng thành công', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, RoomModel room) {
    final isHost = room.players.any((p) => p.userId == widget.currentUserId && p.isHost);
    showDialog(
      context: context,
      builder: (_) => ConfirmLeaveDialog(
        isHost: isHost,
        onConfirm: () async {
          Navigator.pop(context);
          await RoomService.leaveAndWipePlayer(room.roomId, widget.currentUserId);
          if (!mounted) return;
          _shouldStayInRoom = false;
          _myFinishedShowing = false;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeBottomNav(initialIndex: 2)),
            (route) => false,
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
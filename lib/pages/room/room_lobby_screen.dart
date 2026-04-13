import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/room_model.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:dovui/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _codeCopied = false;

  Timer? _heartbeatTimer;
  StreamSubscription? _presenceSub;
  Map<String, int> _presenceMap = {};

  // ── FIX: dùng 1 flag duy nhất, atomic ────────────────────────────────────
  bool _myFinished = false;
  bool _dialogOpen = false;   // guard tuyệt đối, không reset cho đến khi dialog đóng hẳn
  bool _justJoined = true;
  RoomStatus? _prevStatus;
  String? _prevRoomId;
  List<RoomPlayer>? _prevPlayers;

  @override
  void initState() {
    super.initState();
    _justJoined = widget.justJoined;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    final roomId =
        widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;
    if (roomId != null) {
      _startPresenceStream(roomId);
      _sendHeartbeatWithRoomId(roomId);
    }

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final id =
          widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;
      if (id != null) _sendHeartbeatWithRoomId(id);
    });
  }

  void _startPresenceStream(String roomId) {
    _presenceSub?.cancel();
    _presenceSub = RoomService.presenceStream(roomId).listen((map) {
      if (mounted && map != _presenceMap) {
        setState(() => _presenceMap = map);
      }
    });
  }

  Future<void> _sendHeartbeatWithRoomId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    RoomService.updatePresence(roomId, userId);
  }

  Future<void> _setOffline(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    await RoomService.removePresence(roomId, userId);
  }

  @override
  void dispose() {
    final roomId =
        widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;
    if (roomId != null) _setOffline(roomId);
    _presenceSub?.cancel();
    _heartbeatTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _isOnline(RoomPlayer player) {
    final lastSeen = _presenceMap[player.userId];
    if (lastSeen == null) return false;
    return DateTime.now().millisecondsSinceEpoch - lastSeen < 10000;
  }

  bool _playersChanged(List<RoomPlayer>? prev, List<RoomPlayer>? curr) {
    if (prev == null || curr == null) return prev != curr;
    if (prev.length != curr.length) {
      _prevPlayers = curr;
      return true;
    }
    bool changed = false;
    for (int i = 0; i < prev.length; i++) {
      if (i >= curr.length) { changed = true; break; }
      final p = prev[i]; final c = curr[i];
      if (p.userId != c.userId || p.score != c.score ||
          p.isFinished != c.isFinished || p.isHost != c.isHost) {
        changed = true; break;
      }
    }
    if (changed) _prevPlayers = curr;
    return changed;
  }

  // ─── FIX: _onPlayerFinished với guard tuyệt đối ──────────────────────────
  Future<void> _onPlayerFinished(RoomModel room) async {
    // Guard: chỉ chạy 1 lần duy nhất, ngay cả khi widget rebuild nhiều lần
    if (_myFinished || _dialogOpen) return;

    final currentStatus = context.read<RoomBloc>().state.status;
    if (currentStatus != RoomStatus.playing) return;

    // Đặt cờ TRƯỚC mọi thứ (sync, không await)
    setState(() {
      _myFinished = true;
      _dialogOpen = true;
    });

    debugPrint('[Lobby] onPlayerFinished → marking & showing dialog');

    // Cập nhật Firestore
    await RoomService.markPlayerFinished(room.roomId, widget.currentUserId);

    // Kiểm tra allFinished sau khi mark xong — FIX: gọi finishGame
    final updatedDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(room.roomId)
        .get();
    if (updatedDoc.exists) {
      final updatedRoom = RoomModel.fromMap(updatedDoc.data()!);
      final allFinished = updatedRoom.players.every((p) => p.isFinished);
      if (allFinished) {
        debugPrint('[Lobby] All players finished → calling finishGame');
        await RoomService.finishGame(
          roomId: room.roomId,
          players: updatedRoom.players,
        );
      }
    }

    // Hiển thị dialog nếu vẫn đang trong playing state
    if (!mounted) {
      _dialogOpen = false;
      return;
    }
    final stillPlaying =
        context.read<RoomBloc>().state.status == RoomStatus.playing;
    if (stillPlaying) {
      _showCompletionDialog(room);
    } else {
      _dialogOpen = false;
    }
  }

  // ─── FIX: Dialog mới — nền trắng, sinh động, game style ─────────────────
  void _showCompletionDialog(RoomModel room) {
    final currentPlayer = room.players.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => room.players.first,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => _CompletionDialog(
        score: currentPlayer.score,
        playerName: currentPlayer.displayName,
      ),
    );

    // Auto close sau 3s
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        try {
          if (Navigator.of(context, rootNavigator: false).canPop()) {
            Navigator.of(context, rootNavigator: false).pop();
          }
        } catch (_) {}
        // _dialogOpen sẽ được reset khi game chuyển sang waiting (listener)
      }
    });
  }

  Future<void> _onScoreUpdate(RoomModel room, int delta) async {
    try {
      await RoomService.updateScore(
        roomId: room.roomId,
        userId: widget.currentUserId,
        delta: delta,
      );
    } catch (e) {
      debugPrint('Error updating score: $e');
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocConsumer<RoomBloc, RoomState>(
        listenWhen: (prev, curr) {
          final statusChanged = prev.status != curr.status;
          final roomIdChanged = prev.room?.roomId != curr.room?.roomId;
          final playersChanged = _playersChanged(
            prev.room?.players,
            curr.room?.players,
          );
          return statusChanged || roomIdChanged || playersChanged;
        },
        buildWhen: (prev, curr) {
          final statusChanged = prev.status != curr.status;
          final isHostChanged = prev.isHost != curr.isHost;
          final roomIdChanged = prev.room?.roomId != curr.room?.roomId;
          final playersChanged = _playersChanged(
            prev.room?.players,
            curr.room?.players,
          );
          return statusChanged || isHostChanged || roomIdChanged || playersChanged;
        },
        listener: (context, state) {
          if (state.room?.roomId != _prevRoomId) {
            _prevRoomId = state.room?.roomId;
            _prevPlayers = state.room?.players;
          }

          if (state.room != null && _presenceSub == null) {
            _startPresenceStream(state.room!.roomId);
            _sendHeartbeatWithRoomId(state.room!.roomId);
          }

          if (state.status == RoomStatus.initial &&
              _prevStatus != RoomStatus.initial) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phòng đã bị đóng'),
                backgroundColor: Color(0xFFE24B4A),
              ),
            );
          }

          // playing → waiting: reset TẤT CẢ flags
          final transitionToWaiting =
              _prevStatus == RoomStatus.playing &&
              state.status == RoomStatus.waiting;

          if (transitionToWaiting) {
            debugPrint('[Lobby] playing→waiting: reset all finished flags');
            // Đóng dialog nếu đang mở
            if (_dialogOpen) {
              try {
                if (Navigator.of(context, rootNavigator: false).canPop()) {
                  Navigator.of(context, rootNavigator: false).pop();
                }
              } catch (_) {}
            }
            setState(() {
              _myFinished = false;
              _dialogOpen = false;
            });
          }

          // initial/waiting → playing: reset để chơi round mới
          final transitionToPlaying =
              (_prevStatus == RoomStatus.initial ||
                  _prevStatus == RoomStatus.waiting) &&
              state.status == RoomStatus.playing;

          if (transitionToPlaying) {
            setState(() {
              _myFinished = false;
              _dialogOpen = false;
              _justJoined = false;
            });
          }

          _prevStatus = state.status;
        },
        builder: (context, state) {
          final room = state.room;
          if (room == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isHost = state.isHost ||
              room.players.any(
                (p) => p.userId == widget.currentUserId && p.isHost,
              );

          if (state.status == RoomStatus.playing) {
            if (_myFinished || _justJoined) {
              return _buildWaitingLobby(context, room, isHost);
            }
            return _buildPlayingView(context, room);
          }

          return _buildWaitingLobby(context, room, isHost);
        },
      ),
    );
  }

  // ─── Waiting lobby ────────────────────────────────────────────────────────

  Widget _buildWaitingLobby(
      BuildContext context, RoomModel room, bool isHost) {
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
                    _buildRoomCodeCard(room),
                    const SizedBox(height: 16),
                    _buildLeaderboard(room),
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

  // ─── Playing view ─────────────────────────────────────────────────────────

  Widget _buildPlayingView(BuildContext context, RoomModel room) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildPlayingHeader(room),
            Expanded(child: _buildInlineQuiz(context, room)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingHeader(RoomModel room) {
    final sorted = [...room.players]..sort((a, b) => b.score.compareTo(a.score));
    final remaining = room.players.where((p) => !p.isFinished).length;
    final allDone = room.players.every((p) => p.isFinished);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              room.roomId,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sorted.map((p) {
                  final isMe = p.userId == widget.currentUserId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.isFinished
                            ? const Color(0xFFE8F5E9)
                            : isMe
                                ? const Color(0xFFEEEDFE)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: isMe
                            ? Border.all(color: const Color(0xFF6C63FF))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.isFinished)
                            const Text('✓ ',
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF2E7D32))),
                          Text(
                            '${p.displayName.split(' ').last}: ${p.score}⭐',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isMe
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isMe
                                  ? const Color(0xFF534AB7)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: allDone
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              allDone ? '✅ Xong!' : '⏳ $remaining còn lại',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: allDone
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineQuiz(BuildContext context, RoomModel room) {
    return QuizScreen(
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
    );
  }

  // ─── Waiting lobby widgets ────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, RoomModel room, bool isHost) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _confirmLeave(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Color(0xFF1E1B4B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phòng chờ',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B)),
                ),
                Text(room.categoryName,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isHost)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👑', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text('Chủ phòng',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF633806))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeCard(RoomModel room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Mã phòng',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _pulseAnim,
            child: Text(
              room.roomId,
              style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _codeActionBtn(
                icon: _codeCopied ? Icons.check_rounded : Icons.copy_rounded,
                label: _codeCopied ? 'Đã sao chép' : 'Sao chép',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: room.roomId));
                  setState(() => _codeCopied = true);
                  Future.delayed(const Duration(seconds: 2),
                      () => setState(() => _codeCopied = false));
                },
              ),
              if (room.password.isNotEmpty) ...[
                const SizedBox(width: 12),
                _codeActionBtn(
                  icon: Icons.lock_rounded,
                  label: '🔒 Có mật khẩu',
                  onTap: null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _codeActionBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(RoomModel room) {
    final sorted = [...room.players]..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🏆 Bảng xếp hạng',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${room.players.length}/8',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF534AB7))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F7FF),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    const SizedBox(width: 10),
                    const SizedBox(width: 38),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Người chơi',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('Điểm',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ...sorted.asMap().entries.map((entry) {
                final rank = entry.key;
                final player = entry.value;
                final isMe = player.userId == widget.currentUserId;
                final isLast =
                    rank == sorted.length - 1 && room.players.length >= 4;
                return _buildPlayerRow(
                  rank: rank,
                  player: player,
                  isMe: isMe,
                  isLast: isLast,
                );
              }),
              ...List.generate(
                (4 - room.players.length).clamp(0, 4),
                (i) => _buildEmptySlot(
                    isLast: i == (4 - room.players.length - 1).clamp(0, 3)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow({
    required int rank,
    required RoomPlayer player,
    required bool isMe,
    required bool isLast,
  }) {
    final rankEmojis = ['🥇', '🥈', '🥉'];
    final rankLabel = rank < 3 ? rankEmojis[rank] : '${rank + 1}';
    final initials = player.displayName.isNotEmpty
        ? player.displayName
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    final avatarColors = [
      [const Color(0xFFEEEDFE), const Color(0xFF534AB7)],
      [const Color(0xFFE1F5EE), const Color(0xFF085041)],
      [const Color(0xFFFAEEDA), const Color(0xFF633806)],
      [const Color(0xFFFBEAF0), const Color(0xFF72243E)],
      [const Color(0xFFE6F1FB), const Color(0xFF0C447C)],
    ];
    final colors = avatarColors[rank % avatarColors.length];
    final online = _isOnline(player);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF8F7FF) : Colors.white,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : null,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
          left: isMe
              ? const BorderSide(color: Color(0xFF6C63FF), width: 3)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text(rankLabel,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 10),
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: colors[0], shape: BoxShape.circle),
                child: Center(
                  child: Text(initials,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors[1])),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: online
                        ? const Color(0xFF1D9E75)
                        : Colors.grey.shade400,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe
                            ? '${player.displayName} (Tôi)'
                            : player.displayName,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isMe ? FontWeight.bold : FontWeight.w500,
                            color: const Color(0xFF1E1B4B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 4),
                      const Text('👑', style: TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  online ? 'Trực tuyến' : 'Ngoại tuyến',
                  style: TextStyle(
                      fontSize: 10,
                      color: online
                          ? const Color(0xFF1D9E75)
                          : Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: rank == 0
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                  : null,
              color: rank == 0 ? null : const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${player.score} ⭐',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rank == 0 ? Colors.white : const Color(0xFF534AB7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot({required bool isLast}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 28),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.add_rounded,
                size: 18, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 10),
          Text('Đang chờ người chơi...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, RoomModel room) {
    final onlineCount = room.players.where((p) => _isOnline(p)).length;
    final canStart = onlineCount >= 2;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canStart
                ? () {
                    final bloc = context.read<RoomBloc>();
                    if (bloc.isClosed) return;
                    bloc.add(StartGame());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              disabledBackgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              canStart
                  ? 'Bắt đầu chơi 🚀'
                  : 'Cần ít nhất 2 người trực tuyến',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canStart ? Colors.white : Colors.grey.shade400),
            ),
          ),
        ),
        if (!canStart) ...[
          const SizedBox(height: 8),
          Text('$onlineCount/2 người trực tuyến',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
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
        border:
            Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Text('⏳', style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text('Chờ chủ phòng bắt đầu...',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF534AB7))),
          SizedBox(height: 4),
          Text('Bạn đã tham gia phòng thành công',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rời phòng?'),
        content: const Text('Bạn có chắc muốn rời phòng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Huỷ',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final roomId =
                  context.read<RoomBloc>().state.room?.roomId;
              if (roomId != null) await _setOffline(roomId);
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const HomeBottomNav(initialIndex: 2)),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Thoát',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Completion Dialog — white bg, game-style, animated ──────────────────────

class _CompletionDialog extends StatefulWidget {
  final int score;
  final String playerName;

  const _CompletionDialog({required this.score, required this.playerName});

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _starCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _starScaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _scaleAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));
    _starScaleAnim =
        CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut)
            .drive(Tween(begin: 0.0, end: 1.0));
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: 1.08));
    _shimmerAnim = _shimmerCtrl;

    _enterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300),
        () => _starCtrl.forward());
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _starCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header strip ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C6FFF), Color(0xFFB09FFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        // Trophy icon with glow
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏆',
                                  style: TextStyle(fontSize: 38)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hoàn thành!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Xuất sắc lắm, ${widget.playerName.split(' ').last}!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Score section ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        'Điểm số của bạn',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Animated score badge
                      ScaleTransition(
                        scale: _starScaleAnim,
                        child: AnimatedBuilder(
                          animation: _shimmerAnim,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFF8E1),
                                    const Color(0xFFFFF3CD),
                                    const Color(0xFFFFF8E1),
                                  ],
                                  stops: [
                                    0.0,
                                    _shimmerAnim.value,
                                    1.0,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFFD54F),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F)
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⭐',
                                      style: TextStyle(fontSize: 32)),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${widget.score}',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFE65100),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'điểm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFBF360C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Waiting indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EFFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Chờ người chơi khác...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF534AB7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stars row ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: _buildStarRating(widget.score),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(int score) {
    // Hiển thị 5 sao dựa vào điểm (mỗi sao = 2 điểm)
    final filled = (score / 2).round().clamp(0, 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return AnimatedBuilder(
          animation: _starCtrl,
          builder: (context, _) {
            final delay = i * 0.12;
            final progress =
                ((_starCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            final curve =
                Curves.elasticOut.transform(progress.clamp(0.0, 1.0));
            return Transform.scale(
              scale: curve,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  i < filled ? '⭐' : '☆',
                  style: TextStyle(
                    fontSize: 24,
                    color: i < filled ? null : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
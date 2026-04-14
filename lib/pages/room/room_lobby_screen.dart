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

  bool _myFinishedShowing = false;
  RoomStatus? _prevStatus;
  String? _prevRoomId;
  List<RoomPlayer>? _prevPlayers;
  bool _shouldStayInRoom = false; // Flag để giữ người chơi ở phòng sau khi finish

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ✅ Init _prevStatus từ state hiện tại ngay lập tức
    _prevStatus = context.read<RoomBloc>().state.status;

    final roomId =
        widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;
    if (roomId != null) {
      _startPresenceStream(roomId);
    }

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // heartbeat placeholder
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

  @override
  void dispose() {
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
      if (i >= curr.length) {
        changed = true;
        break;
      }
      final p = prev[i];
      final c = curr[i];
      if (p.userId != c.userId ||
          p.score != c.score ||
          p.isFinished != c.isFinished ||
          p.isHost != c.isHost) {
        changed = true;
        break;
      }
    }
    if (changed) _prevPlayers = curr;
    return changed;
  }

  Future<void> _onPlayerFinished(RoomModel room) async {
    if (_myFinishedShowing) return;

    final currentStatus = context.read<RoomBloc>().state.status;
    if (currentStatus != RoomStatus.playing) return;

    // ✅ Set flag SYNCHRONOUSLY trước mọi await
    // Để builder render waitingLobby ngay lập tức, không chờ Firestore
    _myFinishedShowing = true;
    _shouldStayInRoom = true; // Giữ flag này để không pop về home
    if (mounted) setState(() {});

    debugPrint('[Lobby] onPlayerFinished → marking player as finished');

    // ✅ Chỉ mark finished, KHÔNG gọi finishGame ở đây
    // RoomBloc._onRoomUpdated đã tự detect allFinished và gọi finishGame
    await RoomService.markPlayerFinished(room.roomId, widget.currentUserId);

    if (!mounted) return;

    // Show dialog chờ người khác - tự đóng khi BLoC emit waiting
    _showCompletionDialog(room);
  }

  void _showCompletionDialog(RoomModel room) {
    // Lấy điểm mới nhất từ BLoC state
    final latestRoom = context.read<RoomBloc>().state.room ?? room;
    final currentPlayer = latestRoom.players.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => room.players.firstWhere(
        (p) => p.userId == widget.currentUserId,
        orElse: () => room.players.first,
      ),
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

    // Tự đóng sau 3 giây nếu BLoC chưa kịp trigger
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        try {
          if (Navigator.of(context, rootNavigator: false).canPop()) {
            Navigator.of(context, rootNavigator: false).pop();
          }
        } catch (_) {}
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
          return statusChanged ||
              isHostChanged ||
              roomIdChanged ||
              playersChanged;
        },
        listener: (context, state) {
          // ✅ Nếu tôi vừa finish game, LUÔN LUÔN ở lại phòng - bỏ qua mọi logic khác
          if (_shouldStayInRoom) {
            debugPrint('[Lobby] _shouldStayInRoom=true → staying in room, ignoring status changes');
            // Luôn update _prevStatus để theo dõi
            if (state.status != _prevStatus) {
              _prevStatus = state.status;
            }
            return;
          }

          if (state.room?.roomId != _prevRoomId) {
            _prevRoomId = state.room?.roomId;
            _prevPlayers = state.room?.players;
          }

          if (state.room != null && _presenceSub == null) {
            _startPresenceStream(state.room!.roomId);
          }

          // ✅ Chỉ pop về home khi phòng bị đóng bởi người khác (host thoát)
          debugPrint('[Lobby] listener: status=${state.status}, _shouldStayInRoom=$_shouldStayInRoom, room=${state.room != null}');
          
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

          // ✅ playing → waiting: BLoC đã gọi finishGame xong, về lobby
          final transitionToWaiting = _prevStatus == RoomStatus.playing &&
              state.status == RoomStatus.waiting;

          if (transitionToWaiting) {
            debugPrint('[Lobby] playing→waiting: đóng dialog & reset flags');
            // Đóng completion dialog nếu đang mở
            try {
              if (Navigator.of(context, rootNavigator: false).canPop()) {
                Navigator.of(context, rootNavigator: false).pop();
              }
            } catch (_) {}
            // Reset flag để sẵn sàng cho ván mới (nhưng giữ _shouldStayInRoom)
            _myFinishedShowing = false;
          }

          // ✅ Luôn update _prevStatus ở CUỐI listener
          _prevStatus = state.status;
        },
        builder: (context, state) {
          final room = state.room;
          
          // ✅ Nếu room = null nhưng _shouldStayInRoom = true, show loading
          // vì có thể stream tạm thời null nhưng chúng ta sẽ ở lại
          if (room == null && _shouldStayInRoom) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang kết nối phòng...')
                  ],
                ),
              ),
            );
          }
          
          if (room == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isHost = state.isHost ||
              room.players.any(
                (p) => p.userId == widget.currentUserId && p.isHost,
              );

          // Kiểm tra từ Firestore state xem mình đã finish chưa
          final playerMatch =
              room.players.where((p) => p.userId == widget.currentUserId);
          final myFinished =
              playerMatch.isEmpty ? false : playerMatch.first.isFinished;

          if (state.status == RoomStatus.playing) {
            // Nếu đã finish (Firestore hoặc local flag) → show waiting lobby
            if (myFinished || _myFinishedShowing) {
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
    final sorted = [...room.players]
      ..sort((a, b) => b.score.compareTo(a.score));
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
                                    fontSize: 10,
                                    color: Color(0xFF2E7D32))),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            onTap: () => _confirmLeave(context, room),
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
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
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
                icon: _codeCopied
                    ? Icons.check_rounded
                    : Icons.copy_rounded,
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
    final sorted = [...room.players]
      ..sort((a, b) => b.score.compareTo(a.score));

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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
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
                final isLast = rank == sorted.length - 1 &&
                    room.players.length >= 4;
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
                    isLast: i ==
                        (4 - room.players.length - 1).clamp(0, 3)),
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
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(color: colors[0], shape: BoxShape.circle),
            child: Center(
              child: Text(initials,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors[1])),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
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
                  color: rank == 0
                      ? Colors.white
                      : const Color(0xFF534AB7)),
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
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400)),
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
                    // Reset flags khi bắt đầu ván mới
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              canStart
                  ? 'Bắt đầu chơi 🚀'
                  : 'Cần ít nhất 2 người trong phòng',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      canStart ? Colors.white : Colors.grey.shade400),
            ),
          ),
        ),
        if (!canStart) ...[
          const SizedBox(height: 8),
          Text(
            '${room.players.length}/2 người trong phòng',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
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
        border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.2)),
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

  void _confirmLeave(BuildContext context, RoomModel room) {
    final isHost = room.players.any(
      (p) => p.userId == widget.currentUserId && p.isHost,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => _ConfirmLeaveDialog(
        isHost: isHost,
        onConfirm: () async {
          Navigator.pop(dialogContext);
          final roomId = room.roomId;
          await RoomService.leaveAndWipePlayer(
              roomId, widget.currentUserId);
          if (!mounted) return;
          // Reset flags khi thoát phòng
          _shouldStayInRoom = false;
          _myFinishedShowing = false;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const HomeBottomNav(initialIndex: 2)),
            (route) => false,
          );
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

// ─── Confirm Leave Dialog ────────────────────────────────────────────────────

class _ConfirmLeaveDialog extends StatefulWidget {
  final bool isHost;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmLeaveDialog({
    required this.isHost,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ConfirmLeaveDialog> createState() => _ConfirmLeaveDialogState();
}

class _ConfirmLeaveDialogState extends State<_ConfirmLeaveDialog>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    _shakeAnim = Tween<Offset>(begin: const Offset(-0.02, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeCtrl.forward(from: 0);
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SlideTransition(
            position: _shakeAnim,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE24B4A).withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan icon
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isHost
                            ? [const Color(0xFFE24B4A), const Color(0xFFE67B7B)]
                            : [const Color(0xFFF59E0B), const Color(0xFFF5B840)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.isHost ? '👑' : '👋',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rời phòng?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.isHost
                                ? const Color(0xFFFFF3F3)
                                : const Color(0xFFFFF8F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.isHost
                                  ? const Color(0xFFE24B4A).withOpacity(0.2)
                                  : const Color(0xFFF59E0B).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isHost ? '⚠️' : 'ℹ️',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.isHost
                                      ? 'Bạn là chủ phòng. Thoát sẽ xóa phòng và dữ liệu tất cả người chơi!'
                                      : 'Bạn sẽ mất toàn bộ điểm số và thông tin trong phòng này.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isHost
                                        ? const Color(0xFFB71C1C)
                                        : const Color(0xFFB8860B),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                widget.onCancel();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                foregroundColor: const Color(0xFF757575),
                              ),
                              child: const Text(
                                'Huỷ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                widget.onConfirm();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isHost
                                    ? const Color(0xFFE24B4A)
                                    : const Color(0xFFF59E0B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                widget.isHost ? 'Thoát phòng' : 'Rời khỏi',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Completion Dialog ────────────────────────────────────────────────────────

class _CompletionDialog extends StatefulWidget {
  final int score;
  final String playerName;

  const _CompletionDialog(
      {required this.score, required this.playerName});

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

    _scaleAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut)
            .drive(Tween(begin: 0.5, end: 1.0));
    _fadeAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
            .drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut).drive(
            Tween(begin: const Offset(0, 0.3), end: Offset.zero));
    _starScaleAnim =
        CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut)
            .drive(Tween(begin: 0.0, end: 1.0));
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
            .drive(Tween(begin: 1.0, end: 1.08));
    _shimmerAnim = _shimmerCtrl;

    _enterCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 300), () => _starCtrl.forward());
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
                                  colors: const [
                                    Color(0xFFFFF8E1),
                                    Color(0xFFFFF3CD),
                                    Color(0xFFFFF8E1),
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
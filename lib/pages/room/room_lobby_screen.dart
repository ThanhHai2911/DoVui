import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:dovui/data/models/room_model.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:dovui/pages/room/widgets/chat_overlay.dart';
import 'package:dovui/pages/room/widgets/completion_dialog.dart';
import 'package:dovui/pages/room/widgets/confirm_leave_dialog.dart';
import 'package:dovui/pages/room/widgets/playing_header.dart';
import 'package:dovui/pages/room/widgets/room_code_card.dart';
import 'package:dovui/services/room_service.dart';
import 'package:dovui/services/voice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/room_bloc.dart';
import 'bloc/room_event.dart';
import 'bloc/room_state.dart';
import 'widgets/room_avatar_palettes.dart';
import 'widgets/room_top_bar.dart';
import 'widgets/room_players_row.dart';
import 'widgets/room_bottom_bar.dart';
import 'widgets/room_start_button.dart';
import 'widgets/room_waiting_message.dart';

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
  late VoiceService _voiceService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _heartbeatTimer;
  StreamSubscription? _presenceSub;
  Map<String, int> _presenceMap = {};
  bool _myFinishedShowing = false;
  RoomStatus? _prevStatus;
  String? _prevRoomId;
  List<RoomPlayer>? _prevPlayers;
  bool _shouldStayInRoom = false;
  bool _completionDialogOpen = false;
  bool _isChatOpen = true;
  List<String> _knownPlayerIds = [];

  @override
  void initState() {
    super.initState();

    _voiceService = VoiceService();

    _voiceService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    final initialRoom = context.read<RoomBloc>().state.room;
    if (initialRoom != null) {
      _knownPlayerIds = initialRoom.players.map((p) => p.userId).toList();
    }

    // connect voice
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      await _connectVoice();
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _prevStatus = context.read<RoomBloc>().state.status;

    final roomId =
        widget.initialRoomId ?? context.read<RoomBloc>().state.room?.roomId;

    if (roomId != null) {
      _startPresenceStream(roomId);
    }

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {});
  }

  Future<void> _connectVoice() async {
    try {
      final mic = await Permission.microphone.request();

      if (!mic.isGranted) {
        debugPrint('MIC PERMISSION DENIED');
        return;
      }

      final room = context.read<RoomBloc>().state.room;

      if (room == null) return;

      final myPlayer = room.players.firstWhere(
        (p) => p.userId == widget.currentUserId,
      );

      await _voiceService.connect(
        roomId: room.roomId,
        userId: widget.currentUserId,
        displayName: myPlayer.displayName,
      );
      if (!mounted) return;

      debugPrint('VOICE CONNECTED');
    } catch (e) {
      debugPrint('VOICE ERROR: $e');
    }
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
    _voiceService.disconnect();
    _voiceService.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  bool _playersChanged(List<RoomPlayer>? prev, List<RoomPlayer>? curr) {
    if (prev == null || curr == null) return prev != curr;
    if (prev.length != curr.length) {
      _prevPlayers = curr;
      return true;
    }
    for (int i = 0; i < prev.length; i++) {
      if (i >= curr.length) {
        _prevPlayers = curr;
        return true;
      }
      final p = prev[i], c = curr[i];
      if (p.userId != c.userId ||
          p.score != c.score ||
          p.isFinished != c.isFinished ||
          p.isHost != c.isHost) {
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
      orElse:
          () => room.players.firstWhere(
            (p) => p.userId == widget.currentUserId,
            orElse: () => room.players.first,
          ),
    );
    _completionDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (_) => CompletionDialog(
            score: currentPlayer.score,
            playerName: currentPlayer.displayName,
            onClose: () => Navigator.of(context).pop(),
          ),
    ).then((_) {
      if (mounted) _completionDialogOpen = false;
    });
  }

  void _closeCompletionDialogIfOpen() {
    if (!_completionDialogOpen) return;
    _completionDialogOpen = false;
    try {
      Navigator.of(context, rootNavigator: false).maybePop();
    } catch (_) {}
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocConsumer<RoomBloc, RoomState>(
        listenWhen:
            (prev, curr) =>
                prev.status != curr.status ||
                prev.room?.roomId != curr.room?.roomId ||
                _playersChanged(prev.room?.players, curr.room?.players),
        buildWhen:
            (prev, curr) =>
                prev.status != curr.status ||
                prev.isHost != curr.isHost ||
                prev.room?.roomId != curr.room?.roomId ||
                _playersChanged(prev.room?.players, curr.room?.players),
        listener: (context, state) {
          if (state.room != null) {
            final currentIds =
                state.room!.players.map((p) => p.userId).toList();

            if (_knownPlayerIds.isNotEmpty) {
              final newOthers =
                  currentIds
                      .where(
                        (id) =>
                            !_knownPlayerIds.contains(id) &&
                            id != widget.currentUserId,
                      )
                      .toList();
              if (newOthers.isNotEmpty) {
                _audioPlayer.play(AssetSource('audio/notification.mp3'));
              }
            }
            _knownPlayerIds = currentIds;
          }
          final skipNavigation = _shouldStayInRoom;
          if (state.room?.roomId != _prevRoomId) {
            _prevRoomId = state.room?.roomId;
            _prevPlayers = state.room?.players;
          }
          if (state.room != null && _presenceSub == null) {
            _startPresenceStream(state.room!.roomId);
          }
          if (!skipNavigation &&
              state.status == RoomStatus.initial &&
              _prevStatus != RoomStatus.initial) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phòng đã bị đóng'),
                backgroundColor: Color(0xFFE24B4A),
              ),
            );
          }
          if (_prevStatus == RoomStatus.playing &&
              state.status == RoomStatus.waiting) {
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
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text('Đang kết nối phòng...'),
                  ],
                ),
              ),
            );
          }

          if (room == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              ),
            );
          }

          final isHost =
              state.isHost ||
              room.players.any(
                (p) => p.userId == widget.currentUserId && p.isHost,
              );
          final playerMatch = room.players.where(
            (p) => p.userId == widget.currentUserId,
          );
          final myFinished =
              playerMatch.isEmpty ? false : playerMatch.first.isFinished;

          if (state.status == RoomStatus.playing) {
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

  // ─── Waiting Lobby ────────────────────────────────────────────────────────

  Widget _buildWaitingLobby(BuildContext context, RoomModel room, bool isHost) {
    final myPlayer = room.players.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => room.players.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                RoomTopBar(room: room, isHost: isHost),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        RoomCodeCard(
                          roomId: room.roomId,
                          password: room.password,
                          pulseAnim: _pulseAnim,
                        ),
                        const SizedBox(height: 20),
                        RoomPlayersRow(
                          room: room,
                          currentUserId: widget.currentUserId,
                          presenceMap: _presenceMap,
                        ),
                        const SizedBox(height: 20),
                        if (_isChatOpen) ...[
                          ChatOverlay(
                            roomId: room.roomId,
                            currentUserId: widget.currentUserId,
                            displayName: myPlayer.displayName,
                            voiceService: _voiceService,
                            collapsible: false,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (isHost)
                          RoomStartButton(
                            room: room,
                            onStart: () {
                              final bloc = context.read<RoomBloc>();
                              if (bloc.isClosed) return;
                              _myFinishedShowing = false;
                              _shouldStayInRoom = false;
                              bloc.add(StartGame());
                            },
                          ),
                        const SizedBox(height: 30),
                        if (!isHost) const RoomWaitingMessage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: RoomBottomBar(
                isMicOn: _voiceService.isMicOn,
                isSpeakerOn: _voiceService.isSpeakerOn,
                isChatOpen: _isChatOpen,

                onMicToggle: () async {
                  await _voiceService.toggleMic();
                },

                onSpeakerToggle: () {
                  _voiceService.toggleSpeaker();
                },

                onChatToggle: () {
                  setState(() {
                    _isChatOpen = !_isChatOpen;
                  });
                },

                onLeave: () => _confirmLeave(context, room),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Playing View ─────────────────────────────────────────────────────────

  Widget _buildPlayingView(BuildContext context, RoomModel room) {
    final myPlayer = room.players.firstWhere(
      (p) => p.userId == widget.currentUserId,
      orElse: () => room.players.first,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            PlayingHeader(room: room, currentUserId: widget.currentUserId),
            Expanded(
              child: QuizScreen(
                categoryId: room.categoryId,
                type: room.type,
                roomId: room.roomId,
                displayName: myPlayer.displayName,
                voiceService: _voiceService,
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

  // ─── Confirm Leave ────────────────────────────────────────────────────────

  void _confirmLeave(BuildContext context, RoomModel room) {
    final isHost = room.players.any(
      (p) => p.userId == widget.currentUserId && p.isHost,
    );
    showDialog(
      context: context,
      builder:
          (_) => ConfirmLeaveDialog(
            isHost: isHost,
            onConfirm: () async {
              Navigator.pop(context);
              await RoomService.leaveAndWipePlayer(
                room.roomId,
                widget.currentUserId,
              );
              if (!mounted) return;
              _shouldStayInRoom = false;
              _myFinishedShowing = false;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeBottomNav(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }
}

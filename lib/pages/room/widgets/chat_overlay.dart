import 'dart:async';
import 'package:dovui/services/chat_service.dart';
import 'package:flutter/material.dart';

const _kAvatarPalettes = [
  [Color(0xFFEEEDFE), Color(0xFF534AB7)],
  [Color(0xFFE1F5EE), Color(0xFF0F6E56)],
  [Color(0xFFFAEEDA), Color(0xFF7C4A0A)],
  [Color(0xFFFBEAF0), Color(0xFF8B2550)],
  [Color(0xFFE6F1FB), Color(0xFF185FA5)],
  [Color(0xFFEAF3DE), Color(0xFF3B6D11)],
];

class ChatOverlay extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String displayName;
  final bool collapsible;
  final dynamic voiceService;
  final VoidCallback? onInputTap;

  const ChatOverlay({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.displayName,
    this.collapsible = false,
    required this.voiceService,
    this.onInputTap,
  });

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  StreamSubscription<List<ChatMessage>>? _sub;
  List<ChatMessage> _messages = [];

  bool _isOpen = true;
  // Mic mặc định TẮT khi vào phòng
  bool get _isMuted => !(widget.voiceService?.isSpeakerOn ?? true);
  bool get _isMicOff => !(widget.voiceService?.isMicOn ?? false);
  int _unread = 0;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    if (widget.collapsible) _isOpen = false;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    if (_isOpen) _slideCtrl.value = 1.0;

    _sub = ChatService.messagesStream(widget.roomId).listen((msgs) {
      if (!mounted) return;
      final newCount = msgs.length - _messages.length;
      setState(() {
        _messages = msgs;
        if (!_isOpen && newCount > 0) _unread += newCount;
      });
      if (_isOpen) _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleMic() async {
    await widget.voiceService?.toggleMic();

    if (mounted) {
      setState(() {});
    }
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _unread = 0;
        _slideCtrl.forward();
        _scrollToBottom();
      } else {
        _slideCtrl.reverse();
      }
    });
  }

  Future<void> _toggleMute() async {
    await widget.voiceService?.toggleSpeaker();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await ChatService.sendMessage(
      roomId: widget.roomId,
      userId: widget.currentUserId,
      displayName: widget.displayName,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!widget.collapsible || _isOpen)
          SlideTransition(
            position: _slideAnim,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  // ── Header ────────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        const Text(
                          'Trò chuyện',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        if (_unread > 0)
                          Text(
                            '$_unread tin mới',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey.shade100),

                  // ── Message list ──────────────────────────────────────────────
                  SizedBox(
                    height: 220,
                    child:
                        _messages
                                .isEmpty // ← đổi messages → _messages
                            ? Center(
                              child: Text(
                                'Chưa có tin nhắn nào 👋',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              itemCount:
                                  _messages
                                      .length, // ← đổi messages → _messages
                              itemBuilder: (_, i) {
                                final msg =
                                    _messages[i]; // ← đổi messages → _messages
                                final isMe = msg.userId == widget.currentUserId;
                                return _MessageBubble(
                                  msg: msg,
                                  isMe: isMe,
                                  paletteIndex: i % _kAvatarPalettes.length,
                                );
                              },
                            ),
                  ),

                  Divider(height: 1, color: Colors.grey.shade100),

                  // ── Input ─────────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onTap: widget.onInputTap,
                            onTapAlwaysCalled: true,
                            controller: _ctrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Nhắn cho cả phòng...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _send(),
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _send,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7B6EF6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: Colors.white,
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
      ],
    );
  }
}

// ── Nút tròn điều khiển ─────────────────────────────────────────────────────

class _ControlBtn extends StatelessWidget {
  final IconData? icon;
  final Widget? child;

  final Color color;
  final int? badge;
  final VoidCallback onTap;
  final String tooltip;

  const _ControlBtn({
    super.key,
    this.icon,
    this.child,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: color.withOpacity(0.3)),
              ),

              alignment: Alignment.center,

              child: child ?? Icon(icon, size: 20, color: color),
            ),

            if (badge != null && badge! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE24B4A),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge! > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Khung chat nội dung ─────────────────────────────────────────────────────

class _ChatBox extends StatelessWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final ScrollController scrollCtrl;
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final bool showMuteInHeader;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final VoidCallback onMic;
  final bool isMicOff;

  const _ChatBox({
    required this.messages,
    required this.currentUserId,
    required this.scrollCtrl,
    required this.ctrl,
    required this.onSend,
    required this.showMuteInHeader,
    required this.isMuted,
    required this.onToggleMute,
    required this.onMic,
    required this.isMicOff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 32,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có tin nhắn nào 👋',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final msg = messages[i];
                        final isMe = msg.userId == currentUserId;
                        return _MessageBubble(
                          msg: msg,
                          isMe: isMe,
                          paletteIndex: i % _kAvatarPalettes.length,
                        );
                      },
                    ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Nhắn cho cả phòng...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => onSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9B6BFF), Color(0xFFFF6FA3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bubble tin nhắn ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  final int paletteIndex;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.paletteIndex,
  });

  String get _initials {
    final name = msg.displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _kAvatarPalettes[paletteIndex];
    final bgColor = palette[0];
    final textColor = palette[1];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      msg.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    // Badge "Chủ phòng" nếu cần thêm isHost vào ChatMessage
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  msg.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 10),
              child: Text(
                _formatTime(msg.sentAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),

          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 15),
              child: Text(
                _formatTime(msg.sentAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

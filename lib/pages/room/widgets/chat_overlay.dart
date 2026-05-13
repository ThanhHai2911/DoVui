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

  const ChatOverlay({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.displayName,
    this.collapsible = false, 
    required this.voiceService,
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
  bool _isMuted = false;
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

  void _toggleMute() => setState(() => _isMuted = !_isMuted);


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
        if (widget.collapsible)
          Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      /// MIC
      _ControlBtn(
        child: _isMicOff
            ? Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '🎤',
                    style: TextStyle(fontSize: 24),
                  ),

                  Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              )
            : const Text(
                '🎤',
                style: TextStyle(fontSize: 24),
              ),

        color:
            _isMicOff ? Colors.grey : const Color(0xFF6C63FF),

        onTap: _toggleMic,

        tooltip: _isMicOff
            ? 'Bật micro'
            : 'Tắt micro',
      ),

      const SizedBox(width: 8),

      /// SPEAKER
      _ControlBtn(
        child: Text(
          _isMuted ? '🔇' : '🔊',
          style: const TextStyle(fontSize: 24),
        ),

        color:
            _isMuted ? Colors.grey : const Color(0xFF6C63FF),

        onTap: _toggleMute,

        tooltip:
            _isMuted ? 'Bật âm thanh' : 'Tắt âm thanh',
      ),

      const SizedBox(width: 8),

      /// CHAT
      _ControlBtn(
        child: Text(
          _isOpen ? '💬' : '💬',
          style: const TextStyle(fontSize: 24),
        ),

        color: const Color(0xFF6C63FF),

        badge: (!_isOpen && _unread > 0)
            ? _unread
            : null,

        onTap: _toggleChat,

        tooltip: _isOpen ? 'Ẩn chat' : 'Mở chat',
      ),
    ],
  ),
),

        if (!widget.collapsible || _isOpen)
          SlideTransition(
            position: _slideAnim,
            child: _ChatBox(
              messages: _messages,
              currentUserId: widget.currentUserId,
              scrollCtrl: _scrollCtrl,
              ctrl: _ctrl,
              onSend: _send,
              showMuteInHeader: !widget.collapsible,
              isMuted: _isMuted,
              isMicOff: _isMicOff,
              onToggleMute: _toggleMute,
              onMic: _toggleMic,
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
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),

              alignment: Alignment.center,

              child:
                  child ??
                  Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
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
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text('💬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHAT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B4B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Online indicator
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'online',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                            ),
                            onSubmitted: (_) => onSend(),
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 22,
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
          if (!isMe) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border:
                    isMe
                        ? Border.all(color: const Color(0xFF6C63FF), width: 2.5)
                        : Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color:
                        isMe
                            ? const Color(0xFF6C63FF).withOpacity(0.25)
                            : Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
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

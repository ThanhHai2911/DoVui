import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/room_bloc.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';
import '../room_lobby_screen.dart';
import '../../../services/room_service.dart';

class JoinRoomSheet extends StatefulWidget {
  final String currentUserId;
  const JoinRoomSheet({super.key, required this.currentUserId});

  @override
  State<JoinRoomSheet> createState() => _JoinRoomSheetState();
}

class _JoinRoomSheetState extends State<JoinRoomSheet> {
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codeFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _navigating = false;
  RoomStatus? _prevStatus;
  String? _prevErrorMessage;

  // Inline error per field
  String? _codeError;
  String? _passError;
  String? _generalError;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _codeFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _codeError = null;
      _passError = null;
      _generalError = null;
    });
  }

  /// Map error message từ bloc → đúng field
  void _applyError(String message) {
    setState(() {
      _codeError = null;
      _passError = null;
      _generalError = null;

      final lower = message.toLowerCase();
      if (lower.contains('mật khẩu') || lower.contains('password')) {
        _passError = message;
        _passFocus.requestFocus();
      } else if (lower.contains('phòng') ||
          lower.contains('tìm thấy') ||
          lower.contains('đầy')) {
        _codeError = message;
        _codeFocus.requestFocus();
      } else {
        _generalError = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listenWhen: (prev, curr) {
        final transitionToWaiting =
            prev.status != RoomStatus.waiting &&
            curr.status == RoomStatus.waiting &&
            curr.room != null;

        final isNewError =
            curr.status == RoomStatus.error &&
            curr.errorMessage != null &&
            curr.errorMessage != _prevErrorMessage;

        return transitionToWaiting || isNewError;
      },
      buildWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        final transitionToWaiting =
            _prevStatus != RoomStatus.waiting &&
            state.status == RoomStatus.waiting;

        if (transitionToWaiting && !_navigating && state.room != null) {
          _navigating = true;
          _updatePresenceAndNavigate(context, state);
        }

        if (state.status == RoomStatus.error &&
            state.errorMessage != null &&
            state.errorMessage != _prevErrorMessage) {
          _prevErrorMessage = state.errorMessage;
          _applyError(state.errorMessage!);
        }

        _prevStatus = state.status;
      },
      builder: (context, state) => _buildContent(state),
    );
  }

  Widget _buildContent(RoomState state) {
    final isLoading = state.status == RoomStatus.loading;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vào phòng bạn bè',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nhập mã phòng 6 ký tự do bạn bè chia sẻ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          _buildCodeInput(),
          const SizedBox(height: 14),
          _buildPassInput(),
          if (_generalError != null) ...[
            const SizedBox(height: 10),
            _buildInlineError(_generalError!, icon: Icons.wifi_off_rounded),
          ],
          const SizedBox(height: 24),
          _buildJoinButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    final hasError = _codeError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mã phòng',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? const Color(0xFFE24B4A) : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeCtrl,
          focusNode: _codeFocus,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) {
            if (_codeError != null) setState(() => _codeError = null);
          },
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: Color(0xFF1E1B4B),
          ),
          decoration: InputDecoration(
            hintText: 'XXXXXX',
            hintStyle: TextStyle(
              fontSize: 22,
              letterSpacing: 6,
              color: Colors.grey.shade300,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(
              Icons.meeting_room_outlined,
              color: hasError ? const Color(0xFFE24B4A) : const Color(0xFF6C63FF),
              size: 20,
            ),
            filled: true,
            fillColor: hasError ? const Color(0xFFFFF0F0) : const Color(0xFFF8F7FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFE24B4A), width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFE24B4A) : const Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            _UpperCaseFormatter(),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasError
              ? _buildInlineError(_codeError!, icon: Icons.error_outline_rounded)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPassInput() {
    final hasError = _passError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mật khẩu (nếu có)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? const Color(0xFFE24B4A) : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passCtrl,
          focusNode: _passFocus,
          onChanged: (_) {
            if (_passError != null) setState(() => _passError = null);
          },
          decoration: InputDecoration(
            hintText: 'Để trống nếu không có',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: hasError ? const Color(0xFFE24B4A) : Colors.grey.shade400,
              size: 18,
            ),
            filled: true,
            fillColor: hasError ? const Color(0xFFFFF0F0) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFE24B4A), width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFE24B4A) : const Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasError
              ? _buildInlineError(_passError!, icon: Icons.lock_outline_rounded)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildInlineError(String message, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE24B4A)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE24B4A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                final code = _codeCtrl.text.trim().toUpperCase();
                if (code.length != 6) {
                  setState(() {
                    _codeError = 'Mã phòng phải đủ 6 ký tự';
                    _passError = null;
                    _generalError = null;
                  });
                  _codeFocus.requestFocus();
                  return;
                }
                _clearErrors();
                _prevErrorMessage = null;
                context.read<RoomBloc>().add(
                      JoinRoom(
                        roomId: code,
                        password: _passCtrl.text.trim(),
                      ),
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Vào phòng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _updatePresenceAndNavigate(
    BuildContext context,
    RoomState state,
  ) async {
    final bloc = context.read<RoomBloc>();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? widget.currentUserId;
    final isPlaying = state.room?.status == 'playing';

    RoomService.updatePresence(state.room!.roomId, userId).then((_) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: RoomLobbyScreen(
              currentUserId: widget.currentUserId,
              initialRoomId: state.room!.roomId,
              justJoined: isPlaying,
            ),
          ),
        ),
      ).then((_) => _navigating = false);
    });
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
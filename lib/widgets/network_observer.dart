import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Pure Dart Internet Checker ───────────────────────────────────────────────
class _InternetChecker {
  static const _host = '8.8.8.8';
  static const _port = 53;
  static const _timeout = Duration(seconds: 5);

  static Future<bool> hasConnection() async {
    try {
      final socket = await Socket.connect(_host, _port, timeout: _timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Stream<bool> periodicCheck({
    Duration interval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      yield await hasConnection();
      await Future.delayed(interval);
    }
  }
}

// ─── NetworkObserver Widget ───────────────────────────────────────────────────
class NetworkObserver extends StatefulWidget {
  final Widget child;
  const NetworkObserver({super.key, required this.child});

  @override
  State<NetworkObserver> createState() => _NetworkObserverState();
}

class _NetworkObserverState extends State<NetworkObserver> {
  StreamSubscription<bool>? _sub;
  bool _dialogShowing = false;
  bool? _lastStatus;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _sub = _InternetChecker.periodicCheck(
      interval: const Duration(seconds: 5),
    ).listen((hasInternet) {
      if (!mounted) return;
      if (_lastStatus == hasInternet) return;
      _lastStatus = hasInternet;
      if (!hasInternet && !_dialogShowing) {
        _showNoNetworkDialog();
      }
    });
  }

  Future<void> _showNoNetworkDialog() async {
    if (!mounted) return;
    setState(() => _dialogShowing = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const _NoNetworkDialog(),
    );
    if (mounted) setState(() => _dialogShowing = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─── Dialog ──────────────────────────────────────────────────────────────────
class _NoNetworkDialog extends StatefulWidget {
  const _NoNetworkDialog();

  @override
  State<_NoNetworkDialog> createState() => _NoNetworkDialogState();
}

enum _Phase { noConnection, retrying, failed }

class _NoNetworkDialogState extends State<_NoNetworkDialog>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.noConnection;
  Timer? _autoRetryTimer;
  int _countdown = 30;

  late AnimationController _pulseCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _pulse;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();

    _pulse = Tween(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 30;
    _autoRetryTimer?.cancel();
    _autoRetryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        _retry();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    _autoRetryTimer?.cancel();
    if (!mounted) return;
    setState(() => _phase = _Phase.retrying);
    final ok = await _InternetChecker.hasConnection();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _phase = _Phase.failed);
    }
  }

  void _exitApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SlideTransition(
        position: _slide,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1040), Color(0xFF0B1D3A)],
              ),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 48,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                const SizedBox(height: 18),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildMessage(),
                const SizedBox(height: 24),
                _buildButtons(),
                const SizedBox(height: 18),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.55),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: _phase == _Phase.retrying
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.wifi_off_rounded, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _buildTitle() {
    final text = switch (_phase) {
      _Phase.retrying     => 'Đang kiểm tra...',
      _Phase.failed       => 'Không có mạng',
      _Phase.noConnection => 'Mất kết nối',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildMessage() {
    final text = switch (_phase) {
      _Phase.retrying     => 'Đang thử kết nối lại...',
      _Phase.failed       => 'Không tìm thấy kết nối mạng.\nVui lòng thử lại sau.',
      _Phase.noConnection => 'Kiểm tra đường truyền mạng của bạn.\nTự động thử lại sau ${_countdown}s...',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 13,
        height: 1.6,
      ),
    );
  }

  Widget _buildButtons() {
    if (_phase == _Phase.retrying) return const SizedBox.shrink();

    if (_phase == _Phase.noConnection) {
      return _GradientButton(
        label: 'Kiểm tra ngay',
        icon: Icons.refresh_rounded,
        onTap: _retry,
      );
    }

    return Column(
      children: [
        _GradientButton(label: 'Thoát ứng dụng', icon: Icons.exit_to_app, onTap: _exitApp),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      '💙  Cảm ơn bạn đã tin tưởng sử dụng ứng dụng',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.28),
        fontSize: 11,
        height: 1.5,
      ),
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 7),
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
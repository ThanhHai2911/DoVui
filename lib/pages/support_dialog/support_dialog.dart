import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/contact_input_field.dart';
import 'widgets/faq_tile.dart' hide SupportBanner;
import 'widgets/send_support_button.dart';
import 'widgets/support_banner.dart';

class SupportDialog extends StatefulWidget {
  const SupportDialog({super.key});

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  static const String _adminEmail = 'thanhhai291120@gmail.com';
  static const int _maxImages = 3; // Giới hạn số ảnh

  // ── Chọn ảnh từ thư viện ──────────────────────────────────────────────────
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // Nén ảnh để giảm dung lượng
        limit: _maxImages - _selectedImages.length,
      );
      if (images.isEmpty) return;

      setState(() {
        final remaining = _maxImages - _selectedImages.length;
        _selectedImages.addAll(images.take(remaining));
      });
    } catch (e) {
      _showSnack('Không thể chọn ảnh: $e', isError: true);
    }
  }

  // ── Chụp ảnh từ camera ────────────────────────────────────────────────────
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo == null) return;
      if (_selectedImages.length >= _maxImages) {
        _showSnack('Tối đa $_maxImages ảnh', isError: true);
        return;
      }
      setState(() => _selectedImages.add(photo));
    } catch (e) {
      _showSnack('Không thể chụp ảnh: $e', isError: true);
    }
  }

  // ── Hiển thị bottom sheet chọn nguồn ảnh ─────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
    );
  }

  // ── Xoá ảnh đã chọn ───────────────────────────────────────────────────────
  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _sendEmail() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showSnack('Vui lòng nhập nội dung cần hỗ trợ', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      // ── Lớp 1: flutter_email_sender (mở thẳng app email, có đính kèm ảnh) ──
      bool sent = false;
      try {
        final Email email = Email(
          recipients: [_adminEmail], // ← sửa cc thành to
          subject: 'Hỗ trợ người dùng app Đố Vui',
          body: text,
          attachmentPaths: _selectedImages.map((x) => x.path).toList(),
          isHTML: false,
        );
        await FlutterEmailSender.send(email);
        debugPrint('✅ FlutterEmailSender.send() thành công');
        sent = true;
      } on PlatformException catch (e) {
        debugPrint('flutter_email_sender lỗi: ${e.code} - ${e.message}');
        debugPrint('❌ Code: ${e.code}');
        debugPrint('❌ Message: ${e.message}');
        debugPrint('❌ Details: ${e.details}');
        // Tiếp tục sang lớp 2
      }

      if (sent) {
        _onSendSuccess();
        return;
      }

      // ── Lớp 2: share_plus (share sheet, chọn Gmail/Mail để gửi kèm ảnh) ──
      if (_selectedImages.isNotEmpty) {
        final files = _selectedImages.map((x) => XFile(x.path)).toList();
        final result = await Share.shareXFiles(
          files,
          subject: 'Hỗ trợ người dùng app Đố Vui',
          text: 'Gửi đến: $_adminEmail\n\n$text',
        );
        if (result.status != ShareResultStatus.dismissed) {
          _onSendSuccess();
          return;
        }
        // User bấm dismiss → thử lớp 3
      }

      // ── Lớp 3: mailto URI (không có ảnh nhưng mở thẳng app email) ──────────
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: _adminEmail,
        queryParameters: {
          'subject': 'Hỗ trợ người dùng app Đố Vui',
          'body':
              _selectedImages.isNotEmpty
                  ? '$text\n\n(Lưu ý: ảnh đính kèm không gửi được tự động, vui lòng đính kèm thủ công)'
                  : text,
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        _onSendSuccess();
      } else {
        // Không có app email nào → hướng dẫn thủ công
        _showNoEmailAppDialog();
      }
    } catch (e) {
      debugPrint('_sendEmail lỗi: $e');
      _showSnack('Có lỗi xảy ra, vui lòng thử lại', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _onSendSuccess() {
    _controller.clear();
    setState(() => _selectedImages.clear());
    _showSnack('Đã mở ứng dụng email thành công!');
  }

  void _showNoEmailAppDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Không tìm thấy app email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vui lòng liên hệ trực tiếp:'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: _adminEmail));
                    Navigator.pop(context);
                    _showSnack('Đã sao chép email!');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            _adminEmail,
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Color(0xFF6C63FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Widget danh sách ảnh đã chọn ─────────────────────────────────────────
  Widget _buildImagePreviews() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount:
            _selectedImages.length +
            (_selectedImages.length < _maxImages ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          // Nút thêm ảnh
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: Color(0xFF6C63FF),
                  size: 28,
                ),
              ),
            );
          }

          // Thumbnail ảnh đã chọn
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_selectedImages[index].path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hỗ trợ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SupportBanner(),

            const SizedBox(height: 28),

            // FAQ Section
            const Text(
              'Câu hỏi thường gặp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            const FaqTile(
              icon: Icons.save_alt_rounded,
              question: 'Làm sao để lưu tiến trình?',
              answer: 'Tiến trình sẽ tự động lưu khi bạn đăng nhập tài khoản.',
            ),
            const SizedBox(height: 8),
            const FaqTile(
              icon: Icons.block_rounded,
              question: 'Tại sao vẫn thấy quảng cáo sau khi lên VIP?',
              answer:
                  'Admin sẽ cập nhật lại trạng thái VIP cho bạn sớm nhất có thể. Vui lòng liên hệ hỗ trợ nếu cần thiết.',
            ),

            const SizedBox(height: 28),

            // Contact Section
            const Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gửi đến: $_adminEmail',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EBD)),
            ),
            const SizedBox(height: 14),

            ContactInputField(controller: _controller),

            const SizedBox(height: 12),

            // ── Khu vực đính kèm ảnh ──────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 15,
                  color: Color(0xFF9E9EBD),
                ),
                const SizedBox(width: 4),
                Text(
                  'Đính kèm ảnh (tối đa $_maxImages)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9EBD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nếu chưa có ảnh nào → hiện nút thêm lớn
            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thêm ảnh chụp màn hình / minh chứng',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF6C63FF).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildImagePreviews(),

            const SizedBox(height: 16),

            SendSupportButton(isSending: _isSending, onPressed: _sendEmail),

            // Ghi chú khi có ảnh
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '📎 Ảnh sẽ được đính kèm qua share sheet của thiết bị',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E9EBD)),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

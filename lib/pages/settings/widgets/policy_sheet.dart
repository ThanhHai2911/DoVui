import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Privacy policy bottom sheet.
class PolicySheet extends StatelessWidget {
  const PolicySheet({super.key});

  static const _policyUrl =
      'https://thanhhai2911.github.io/Dovui_Privacy-Policy/privacy-policy.html';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Chính sách ứng dụng',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade200),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _WebLink(url: _policyUrl),
                  const SizedBox(height: 12),
                  _body('Có hiệu lực từ ngày: 11 tháng 4, 2026'),
                  _h2('1. Giới thiệu'),
                  _body('Chào mừng bạn đến với Đố Vui - Quiz App. Chính sách này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ thông tin khi bạn dùng ứng dụng.'),
                  _h2('2. Thông tin chúng tôi thu thập'),
                  _h3('a. Thông tin cá nhân'),
                  _bullets(['Địa chỉ email (qua Firebase Authentication)', 'User ID (UID)']),
                  _h3('b. Dữ liệu sử dụng'),
                  _bullets(['Tiến trình & điểm số trò chơi', 'Thông tin thiết bị (loại máy, phiên bản HĐH)', 'Nhật ký sự cố, hiệu suất']),
                  _h3('c. Dữ liệu quảng cáo'),
                  _bullets(['Advertising ID', 'Định danh thiết bị', 'Tương tác với quảng cáo']),
                  _h2('3. Cách chúng tôi sử dụng thông tin'),
                  _bullets(['Cung cấp & duy trì ứng dụng', 'Xác thực người dùng', 'Lưu tiến trình & điểm số', 'Cải thiện hiệu suất & trải nghiệm', 'Hiển thị quảng cáo']),
                  _h2('4. Dịch vụ bên thứ ba'),
                  _bullets(['Google Firebase (Authentication, Firestore, Analytics)', 'Google AdMob (Quảng cáo)']),
                  _h2('5. Chia sẻ dữ liệu'),
                  _body('Chúng tôi không bán dữ liệu cá nhân của bạn.'),
                  _h2('6. Bảo mật dữ liệu'),
                  _body('Chúng tôi áp dụng các biện pháp hợp lý để bảo vệ dữ liệu của bạn.'),
                  _h2('7. Quyền của người dùng'),
                  _bullets(['Truy cập dữ liệu của bạn', 'Yêu cầu chỉnh sửa']),
                  _h3('Yêu cầu xóa dữ liệu'),
                  _body('Bạn có thể yêu cầu xóa dữ liệu bằng cách liên hệ qua email bên dưới.'),
                  _h2('8. Quyền riêng tư của trẻ em'),
                  _body('Ứng dụng không dành cho trẻ em dưới 13 tuổi.'),
                  _h2('9. Thay đổi chính sách'),
                  _body('Chúng tôi có thể cập nhật chính sách này theo thời gian.'),
                  _h2('10. Liên hệ'),
                  _body('Email: thanhhai291120@gmail.com'),
                  _body('Developer: Thanh Hải'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _h2(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
      );

  Widget _h3(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
      );

  Widget _body(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6)),
      );

  Widget _bullets(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                      Expanded(child: Text(e, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5))),
                    ],
                  ),
                ))
            .toList(),
      );
}

class _WebLink extends StatelessWidget {
  final String url;
  const _WebLink({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEDFE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF534AB7).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF534AB7)),
            SizedBox(width: 6),
            Text('Xem trang web chính thức', style: TextStyle(fontSize: 13, color: Color(0xFF534AB7))),
          ],
        ),
      ),
    );
  }
}
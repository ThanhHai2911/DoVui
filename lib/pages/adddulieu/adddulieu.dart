import 'package:cloud_firestore/cloud_firestore.dart';

class MillionaireDataSetup {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> run() async {
    try {
      print("🔥 Bắt đầu upload dữ liệu Ai Là Triệu Phú");

      // ── Category ──────────────────────────────────────
      final catRef = _db.collection("categories").doc("tritue");
      await catRef.set({
        "name": "Trí Tuệ",
        "image": "https://res.cloudinary.com/dejxoaud5/image/upload/v1775292018/tritue_nfnye8.png",
        "type": "level",
        "order": 6,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Category 'tritue' đã tạo");

      // ── 30 màn × 15 câu ──────────────────────────────
      for (int manIdx = 0; manIdx < _allMans.length; manIdx++) {
        final manNum = manIdx + 1;
        final manId  = "man_$manNum";
        final manRef = catRef.collection("mans").doc(manId);

        await manRef.set({
          "name": "Màn $manNum",
          "order": manNum,
          "type":  "direct",
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final questions = _allMans[manIdx];
        for (int qIdx = 0; qIdx < questions.length; qIdx++) {
          final q = questions[qIdx];
          await manRef
              .collection("questions")
              .doc("question${qIdx + 1}")
              .set({
            "question":     q["question"],
            "answers":      q["answers"],
            "correctIndex": q["correctIndex"],
            "order":        qIdx + 1,
            "updatedAt":    FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        print("✅ $manId — ${questions.length} câu hỏi");
      }

      print("🎉 Hoàn tất! 30 màn × 15 câu đã upload.");
    } catch (e) {
      print("❌ Lỗi: $e");
    }
  }

  // ════════════════════════════════════════════════════
  //  DỮ LIỆU — 30 màn × 15 câu
  //  Mỗi câu: question, answers (4 lựa chọn), correctIndex
  // ════════════════════════════════════════════════════

  static const List<List<Map<String, dynamic>>> _allMans = [
    // ══════════════════════════════
    //  MÀN 1 — Địa lý Việt Nam
    // ══════════════════════════════
    [
      {"question": "Thủ đô của Việt Nam là thành phố nào?", "answers": ["Hà Nội", "Đà Nẵng", "Hải Phòng", "Huế"], "correctIndex": 0},
      {"question": "Việt Nam có bao nhiêu tỉnh thành trực thuộc Trung ương?", "answers": ["58", "61", "63", "65"], "correctIndex": 2},
      {"question": "Sông nào dài nhất Việt Nam?", "answers": ["Sông Hồng", "Sông Mê Kông", "Sông Đà", "Sông Mã"], "correctIndex": 1},
      {"question": "Đỉnh núi cao nhất Việt Nam tên là gì?", "answers": ["Phan Xi Păng", "Ngọc Linh", "Pu Si Lung", "Bạch Mã"], "correctIndex": 0},
      {"question": "Thành phố nào được mệnh danh là 'Thành phố biển'?", "answers": ["Nha Trang", "Đà Nẵng", "Vũng Tàu", "Phan Thiết"], "correctIndex": 1},
      {"question": "Vịnh Hạ Long thuộc tỉnh nào?", "answers": ["Hải Phòng", "Quảng Ninh", "Ninh Bình", "Nam Định"], "correctIndex": 1},
      {"question": "Tỉnh nào có diện tích lớn nhất Việt Nam?", "answers": ["Sơn La", "Nghệ An", "Gia Lai", "Đắk Lắk"], "correctIndex": 1},
      {"question": "Cố đô Huế thuộc tỉnh thành nào?", "answers": ["Quảng Nam", "Thừa Thiên Huế", "Quảng Trị", "Quảng Bình"], "correctIndex": 1},
      {"question": "Đồng bằng sông Cửu Long có bao nhiêu tỉnh thành?", "answers": ["11", "12", "13", "14"], "correctIndex": 2},
      {"question": "Biển Đông nằm về phía nào của Việt Nam?", "answers": ["Tây", "Bắc", "Đông", "Nam"], "correctIndex": 2},
      {"question": "Thành phố Hồ Chí Minh trước kia có tên gọi là gì?", "answers": ["Biên Hòa", "Sài Gòn", "Gia Định", "Chợ Lớn"], "correctIndex": 1},
      {"question": "Dãy Trường Sơn chạy dọc theo hướng nào?", "answers": ["Đông - Tây", "Bắc - Nam", "Tây Bắc - Đông Nam", "Đông Bắc - Tây Nam"], "correctIndex": 1},
      {"question": "Tỉnh nào có đường biên giới dài nhất với Lào?", "answers": ["Nghệ An", "Hà Tĩnh", "Quảng Bình", "Quảng Trị"], "correctIndex": 0},
      {"question": "Hồ nào lớn nhất Việt Nam?", "answers": ["Hồ Ba Bể", "Hồ Tây", "Hồ Xuân Hương", "Hồ Dầu Tiếng"], "correctIndex": 3},
      {"question": "Tỉnh nào giáp với 3 nước: Trung Quốc, Lào, Myanma?", "answers": ["Điện Biên", "Lai Châu", "Lào Cai", "Hà Giang"], "correctIndex": 0},
    ],

    // ══════════════════════════════
    //  MÀN 2 — Lịch sử Việt Nam
    // ══════════════════════════════
    [
      {"question": "Nhà nước Văn Lang được thành lập bởi vua nào?", "answers": ["Hùng Vương", "An Dương Vương", "Triệu Đà", "Lý Nam Đế"], "correctIndex": 0},
      {"question": "Năm 938, trận thủy chiến nào đánh bại quân Nam Hán?", "answers": ["Trận Như Nguyệt", "Trận Bạch Đằng", "Trận Chi Lăng", "Trận Đống Đa"], "correctIndex": 1},
      {"question": "Ai là người thành lập nhà Lý?", "answers": ["Lý Bí", "Lý Thái Tổ", "Lý Thái Tông", "Lý Nhân Tông"], "correctIndex": 1},
      {"question": "Chiến thắng Điện Biên Phủ diễn ra năm nào?", "answers": ["1950", "1952", "1954", "1956"], "correctIndex": 2},
      {"question": "Nguyễn Trãi viết tác phẩm nào kêu gọi đánh giặc Minh?", "answers": ["Nam Quốc Sơn Hà", "Bình Ngô Đại Cáo", "Hịch Tướng Sĩ", "Chiếu Dời Đô"], "correctIndex": 1},
      {"question": "Nhà Trần ba lần đánh bại quân xâm lược nào?", "answers": ["Tống", "Minh", "Nguyên Mông", "Thanh"], "correctIndex": 2},
      {"question": "Vị vua nào dời đô từ Hoa Lư về Thăng Long?", "answers": ["Đinh Tiên Hoàng", "Lê Đại Hành", "Lý Thái Tổ", "Trần Thái Tông"], "correctIndex": 2},
      {"question": "Cuộc khởi nghĩa Hai Bà Trưng nổ ra vào năm nào?", "answers": ["Năm 40", "Năm 43", "Năm 111", "Năm 248"], "correctIndex": 0},
      {"question": "Ai là Đại tướng chỉ huy trận Điện Biên Phủ?", "answers": ["Nguyễn Chí Thanh", "Văn Tiến Dũng", "Võ Nguyên Giáp", "Lê Duẩn"], "correctIndex": 2},
      {"question": "Hiệp định Genève ký kết năm nào?", "answers": ["1953", "1954", "1955", "1956"], "correctIndex": 1},
      {"question": "Vương triều nào tồn tại lâu nhất trong lịch sử phong kiến Việt Nam?", "answers": ["Nhà Lý", "Nhà Trần", "Nhà Lê", "Nhà Nguyễn"], "correctIndex": 2},
      {"question": "Quân Tây Sơn đánh tan 29 vạn quân Thanh năm nào?", "answers": ["1785", "1787", "1789", "1791"], "correctIndex": 2},
      {"question": "Ai là người sáng lập ra Đảng Cộng sản Việt Nam?", "answers": ["Trần Phú", "Lê Duẩn", "Nguyễn Ái Quốc", "Phạm Văn Đồng"], "correctIndex": 2},
      {"question": "Cách mạng Tháng Tám thành công năm nào?", "answers": ["1943", "1944", "1945", "1946"], "correctIndex": 2},
      {"question": "Ngày Giải phóng miền Nam thống nhất đất nước là ngày nào?", "answers": ["30/3/1975", "30/4/1975", "1/5/1975", "2/9/1975"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 3 — Khoa học tự nhiên
    // ══════════════════════════════
    [
      {"question": "Nguyên tố nào có ký hiệu hóa học là 'Au'?", "answers": ["Bạc", "Đồng", "Vàng", "Bạch kim"], "correctIndex": 2},
      {"question": "Tốc độ ánh sáng trong chân không xấp xỉ bao nhiêu km/s?", "answers": ["150.000", "300.000", "600.000", "1.000.000"], "correctIndex": 1},
      {"question": "Hành tinh nào lớn nhất trong Hệ Mặt Trời?", "answers": ["Sao Thổ", "Sao Hải Vương", "Sao Mộc", "Sao Thiên Vương"], "correctIndex": 2},
      {"question": "Công thức hóa học của nước là gì?", "answers": ["H2O2", "HO", "H2O", "H3O"], "correctIndex": 2},
      {"question": "Bảng tuần hoàn có bao nhiêu nguyên tố hóa học?", "answers": ["108", "114", "118", "120"], "correctIndex": 2},
      {"question": "Lực hấp dẫn của Trái Đất xấp xỉ bao nhiêu m/s²?", "answers": ["8,8", "9,8", "10,8", "11,8"], "correctIndex": 1},
      {"question": "Quang hợp diễn ra ở bộ phận nào của cây?", "answers": ["Rễ", "Thân", "Lá", "Hoa"], "correctIndex": 2},
      {"question": "Nguyên tử khối của Carbon (C) là bao nhiêu?", "answers": ["6", "12", "14", "16"], "correctIndex": 1},
      {"question": "Nhiệt độ sôi của nước ở điều kiện tiêu chuẩn là bao nhiêu độ C?", "answers": ["90", "95", "100", "105"], "correctIndex": 2},
      {"question": "DNA là viết tắt của cụm từ gì?", "answers": ["Deoxyribonucleic Acid", "Deoxyribose Nucleic Acid", "Deoxy Nucleic Acid", "Dinucleic Acid"], "correctIndex": 0},
      {"question": "Hành tinh nào gần Mặt Trời nhất?", "answers": ["Kim Tinh", "Sao Hỏa", "Trái Đất", "Sao Thủy"], "correctIndex": 3},
      {"question": "Ánh sáng trắng khi qua lăng kính tách thành bao nhiêu màu?", "answers": ["5", "6", "7", "8"], "correctIndex": 2},
      {"question": "Loại tế bào nào không có nhân?", "answers": ["Tế bào động vật", "Tế bào thực vật", "Tế bào nấm", "Tế bào vi khuẩn"], "correctIndex": 3},
      {"question": "Công thức tính lực F = m × a là định luật mấy của Newton?", "answers": ["Định luật 1", "Định luật 2", "Định luật 3", "Không phải định luật Newton"], "correctIndex": 1},
      {"question": "Nhiệt độ tuyệt đối bằng 0 Kelvin tương đương bao nhiêu độ C?", "answers": ["-173°C", "-233°C", "-273°C", "-373°C"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 4 — Toán học
    // ══════════════════════════════
    [
      {"question": "Số Pi (π) xấp xỉ bằng bao nhiêu?", "answers": ["3,14159", "3,14169", "3,14179", "3,14189"], "correctIndex": 0},
      {"question": "Tam giác có tổng 3 góc bằng bao nhiêu độ?", "answers": ["90°", "180°", "270°", "360°"], "correctIndex": 1},
      {"question": "Căn bậc hai của 144 bằng bao nhiêu?", "answers": ["10", "11", "12", "13"], "correctIndex": 2},
      {"question": "Số nguyên tố nhỏ nhất là số nào?", "answers": ["0", "1", "2", "3"], "correctIndex": 2},
      {"question": "2^10 bằng bao nhiêu?", "answers": ["512", "1024", "2048", "256"], "correctIndex": 1},
      {"question": "Diện tích hình tròn bán kính r được tính bằng công thức nào?", "answers": ["2πr", "πr²", "2πr²", "πr"], "correctIndex": 1},
      {"question": "log₁₀(1000) bằng bao nhiêu?", "answers": ["2", "3", "4", "10"], "correctIndex": 1},
      {"question": "Tổng các số từ 1 đến 100 bằng bao nhiêu?", "answers": ["4950", "5000", "5050", "5100"], "correctIndex": 2},
      {"question": "Đạo hàm của hàm số f(x) = x³ là gì?", "answers": ["x²", "2x²", "3x²", "3x"], "correctIndex": 2},
      {"question": "Hình lăng trụ tam giác có bao nhiêu mặt?", "answers": ["3", "4", "5", "6"], "correctIndex": 2},
      {"question": "Dãy số Fibonacci bắt đầu bằng 1, 1, 2, 3, 5... số tiếp theo là?", "answers": ["7", "8", "9", "10"], "correctIndex": 1},
      {"question": "Nghiệm của phương trình x² - 5x + 6 = 0 là?", "answers": ["x=1 và x=6", "x=2 và x=3", "x=-2 và x=-3", "x=1 và x=5"], "correctIndex": 1},
      {"question": "Một góc nhọn có số đo nằm trong khoảng nào?", "answers": ["0° < x < 90°", "0° < x < 180°", "90° < x < 180°", "0° < x ≤ 90°"], "correctIndex": 0},
      {"question": "Tích phân ∫x dx bằng gì?", "answers": ["x²", "x²/2 + C", "2x + C", "x + C"], "correctIndex": 1},
      {"question": "Nếu A ∩ B = ∅ thì A và B gọi là hai tập hợp gì?", "answers": ["Tập con", "Tập rỗng", "Xung khắc", "Giao nhau"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 5 — Văn học
    // ══════════════════════════════
    [
      {"question": "Ai là tác giả của 'Truyện Kiều'?", "answers": ["Hồ Xuân Hương", "Nguyễn Du", "Nguyễn Trãi", "Lê Quý Đôn"], "correctIndex": 1},
      {"question": "Tác phẩm 'Tắt Đèn' do ai sáng tác?", "answers": ["Nam Cao", "Ngô Tất Tố", "Vũ Trọng Phụng", "Nguyễn Công Hoan"], "correctIndex": 1},
      {"question": "Nhân vật Chí Phèo xuất hiện trong tác phẩm của ai?", "answers": ["Thạch Lam", "Nam Cao", "Tô Hoài", "Kim Lân"], "correctIndex": 1},
      {"question": "Tác phẩm 'Dế Mèn Phiêu Lưu Ký' do ai viết?", "answers": ["Tô Hoài", "Trần Đăng Khoa", "Xuân Diệu", "Nguyên Hồng"], "correctIndex": 0},
      {"question": "'Bình Ngô Đại Cáo' được viết bằng chữ gì?", "answers": ["Chữ Nôm", "Chữ Quốc ngữ", "Chữ Hán", "Chữ Pháp"], "correctIndex": 2},
      {"question": "Tác phẩm nào của Nguyễn Ái Quốc viết bằng tiếng Pháp?", "answers": ["Nhật ký trong tù", "Con rồng tre", "Vi hành", "Đường Kách mệnh"], "correctIndex": 2},
      {"question": "Ai là tác giả của 'Nhật ký trong tù'?", "answers": ["Tố Hữu", "Hồ Chí Minh", "Chế Lan Viên", "Xuân Diệu"], "correctIndex": 1},
      {"question": "Truyện ngắn 'Làng' của ai?", "answers": ["Kim Lân", "Nguyễn Thành Long", "Nguyễn Minh Châu", "Nguyễn Quang Sáng"], "correctIndex": 0},
      {"question": "Tác phẩm 'Số Đỏ' thuộc thể loại gì?", "answers": ["Truyện ngắn", "Tiểu thuyết", "Truyện vừa", "Bút ký"], "correctIndex": 1},
      {"question": "Ai được mệnh danh là 'Ông hoàng thơ tình' Việt Nam?", "answers": ["Chế Lan Viên", "Huy Cận", "Xuân Diệu", "Hàn Mặc Tử"], "correctIndex": 2},
      {"question": "Thể thơ lục bát có cấu trúc câu thơ như thế nào?", "answers": ["5-7", "6-8", "7-7", "4-4"], "correctIndex": 1},
      {"question": "Truyện 'Chiếc lược ngà' của ai?", "answers": ["Nguyễn Quang Sáng", "Nguyễn Thi", "Anh Đức", "Phan Tứ"], "correctIndex": 0},
      {"question": "Tác phẩm nào kể về nhân vật Lão Hạc?", "answers": ["Chí Phèo", "Lão Hạc", "Sống mòn", "Đời thừa"], "correctIndex": 1},
      {"question": "Ai viết 'Đoạn trường tân thanh' (Truyện Kiều)?", "answers": ["Đặng Trần Côn", "Nguyễn Du", "Đoàn Thị Điểm", "Bà Huyện Thanh Quan"], "correctIndex": 1},
      {"question": "Bài thơ 'Đây thôn Vĩ Dạ' của ai?", "answers": ["Xuân Diệu", "Huy Cận", "Hàn Mặc Tử", "Chế Lan Viên"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 6 — Địa lý thế giới
    // ══════════════════════════════
    [
      {"question": "Quốc gia nào có diện tích lớn nhất thế giới?", "answers": ["Canada", "Trung Quốc", "Nga", "Mỹ"], "correctIndex": 2},
      {"question": "Thủ đô của Nhật Bản là gì?", "answers": ["Osaka", "Kyoto", "Tokyo", "Nagoya"], "correctIndex": 2},
      {"question": "Sông nào dài nhất thế giới?", "answers": ["Amazon", "Sông Nin", "Sông Dương Tử", "Mississippi"], "correctIndex": 1},
      {"question": "Châu lục nào có diện tích lớn nhất?", "answers": ["Châu Phi", "Châu Mỹ", "Châu Á", "Châu Âu"], "correctIndex": 2},
      {"question": "Đỉnh núi cao nhất thế giới tên là gì?", "answers": ["K2", "Lhotse", "Everest", "Kangchenjunga"], "correctIndex": 2},
      {"question": "Quốc gia nào có dân số đông nhất thế giới?", "answers": ["Trung Quốc", "Ấn Độ", "Mỹ", "Indonesia"], "correctIndex": 1},
      {"question": "Đại dương nào lớn nhất thế giới?", "answers": ["Đại Tây Dương", "Ấn Độ Dương", "Thái Bình Dương", "Bắc Băng Dương"], "correctIndex": 2},
      {"question": "Thủ đô của Brazil là gì?", "answers": ["Rio de Janeiro", "São Paulo", "Brasília", "Salvador"], "correctIndex": 2},
      {"question": "Quốc gia nào nhỏ nhất thế giới?", "answers": ["Monaco", "San Marino", "Vatican", "Liechtenstein"], "correctIndex": 2},
      {"question": "Thủ đô của Úc là gì?", "answers": ["Sydney", "Melbourne", "Brisbane", "Canberra"], "correctIndex": 3},
      {"question": "Sa mạc nào lớn nhất thế giới?", "answers": ["Sahara", "Arabian", "Gobi", "Antarctica"], "correctIndex": 3},
      {"question": "Núi lửa Vesuvius nổi tiếng thuộc quốc gia nào?", "answers": ["Hy Lạp", "Tây Ban Nha", "Ý", "Pháp"], "correctIndex": 2},
      {"question": "Thủ đô của Canada là gì?", "answers": ["Toronto", "Vancouver", "Montreal", "Ottawa"], "correctIndex": 3},
      {"question": "Quốc gia nào nằm ở cả châu Âu và châu Á?", "answers": ["Nga", "Kazakhstan", "Thổ Nhĩ Kỳ", "Tất cả đều đúng"], "correctIndex": 3},
      {"question": "Hồ nào lớn nhất thế giới?", "answers": ["Hồ Superior", "Biển Caspi", "Hồ Victoria", "Hồ Baikal"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 7 — Thể thao
    // ══════════════════════════════
    [
      {"question": "Môn thể thao nào được gọi là 'Vua của các môn thể thao'?", "answers": ["Bóng rổ", "Bóng đá", "Tennis", "Bơi lội"], "correctIndex": 1},
      {"question": "Thế vận hội Olympic hiện đại được tổ chức lần đầu năm nào?", "answers": ["1892", "1896", "1900", "1904"], "correctIndex": 1},
      {"question": "Giải bóng đá World Cup diễn ra mấy năm một lần?", "answers": ["2 năm", "3 năm", "4 năm", "5 năm"], "correctIndex": 2},
      {"question": "Môn nào không phải là môn võ thuật?", "answers": ["Judo", "Taekwondo", "Karate", "Polo"], "correctIndex": 3},
      {"question": "Trong bóng đá, thẻ màu gì là thẻ phạt nặng nhất?", "answers": ["Vàng", "Đỏ", "Cam", "Đen"], "correctIndex": 1},
      {"question": "Tay vợt nào giữ kỷ lục nhiều Grand Slam nhất tính đến 2024?", "answers": ["Roger Federer", "Rafael Nadal", "Novak Djokovic", "Andy Murray"], "correctIndex": 2},
      {"question": "Bóng rổ NBA có bao nhiêu đội?", "answers": ["28", "30", "32", "34"], "correctIndex": 1},
      {"question": "Trọng lượng chuẩn của quả bóng đá FIFA là bao nhiêu gram?", "answers": ["350-390g", "390-430g", "410-450g", "430-470g"], "correctIndex": 2},
      {"question": "Khoảng cách chạy Marathon chuẩn là bao nhiêu km?", "answers": ["40km", "41km", "42,195km", "43km"], "correctIndex": 2},
      {"question": "Ai là vận động viên điền kinh nhanh nhất thế giới (100m)?", "answers": ["Carl Lewis", "Michael Johnson", "Usain Bolt", "Justin Gatlin"], "correctIndex": 2},
      {"question": "Môn bơi lội bơi ếch tiếng Anh gọi là gì?", "answers": ["Backstroke", "Butterfly", "Freestyle", "Breaststroke"], "correctIndex": 3},
      {"question": "Trong cờ vua, quân nào có thể đi theo đường chéo?", "answers": ["Xe", "Mã", "Tượng", "Tốt"], "correctIndex": 2},
      {"question": "Giải đua xe F1 danh tiếng nhất thế giới tên đầy đủ là gì?", "answers": ["Formula One", "Formula Racing", "Formula Prix", "Formula Grand Prix"], "correctIndex": 0},
      {"question": "Môn cầu lông sử dụng loại cầu gì?", "answers": ["Cầu cao su", "Cầu lông vũ", "Cầu nhựa", "Cầu kim loại"], "correctIndex": 1},
      {"question": "Đội bóng đá nào nhiều lần vô địch World Cup nhất?", "answers": ["Đức", "Ý", "Argentina", "Brazil"], "correctIndex": 3},
    ],

    // ══════════════════════════════
    //  MÀN 8 — Công nghệ & Internet
    // ══════════════════════════════
    [
      {"question": "WWW là viết tắt của cụm từ gì?", "answers": ["World Wide Web", "World Wide Window", "World Wide Wire", "Web Wide World"], "correctIndex": 0},
      {"question": "Ngôn ngữ lập trình nào có biểu tượng con rắn?", "answers": ["Java", "Ruby", "Python", "Cobra"], "correctIndex": 2},
      {"question": "CPU là viết tắt của gì?", "answers": ["Computer Processing Unit", "Central Processing Unit", "Core Processing Unit", "Control Processing Unit"], "correctIndex": 1},
      {"question": "Ai sáng lập ra công ty Apple?", "answers": ["Bill Gates", "Elon Musk", "Steve Jobs", "Mark Zuckerberg"], "correctIndex": 2},
      {"question": "HTML viết tắt của cụm từ gì?", "answers": ["HyperText Markup Language", "HyperText Machine Language", "High Text Markup Language", "HyperText Modern Language"], "correctIndex": 0},
      {"question": "RAM là gì?", "answers": ["Bộ nhớ chỉ đọc", "Bộ nhớ truy cập ngẫu nhiên", "Bộ nhớ lưu trữ cố định", "Bộ nhớ đồ họa"], "correctIndex": 1},
      {"question": "Mạng xã hội Facebook được thành lập năm nào?", "answers": ["2002", "2003", "2004", "2005"], "correctIndex": 2},
      {"question": "Đơn vị nhỏ nhất của thông tin số là gì?", "answers": ["Byte", "Kilobyte", "Bit", "Nibble"], "correctIndex": 2},
      {"question": "Hệ điều hành Android được phát triển bởi công ty nào?", "answers": ["Apple", "Microsoft", "Samsung", "Google"], "correctIndex": 3},
      {"question": "1 Gigabyte bằng bao nhiêu Megabyte?", "answers": ["100MB", "512MB", "1024MB", "2048MB"], "correctIndex": 2},
      {"question": "Ngôn ngữ lập trình nào được dùng nhiều nhất trong web frontend?", "answers": ["Python", "Java", "JavaScript", "PHP"], "correctIndex": 2},
      {"question": "USB là viết tắt của gì?", "answers": ["Universal Serial Bus", "Universal System Bus", "Unified Serial Bus", "Universal Storage Bus"], "correctIndex": 0},
      {"question": "AI là viết tắt của cụm từ gì?", "answers": ["Automatic Intelligence", "Artificial Intelligence", "Advanced Intelligence", "Applied Intelligence"], "correctIndex": 1},
      {"question": "Giao thức HTTPS khác HTTP ở điểm nào chính?", "answers": ["Nhanh hơn", "Bảo mật hơn", "Tốn ít băng thông hơn", "Hỗ trợ nhiều thiết bị hơn"], "correctIndex": 1},
      {"question": "Thiết bị nào dùng để chuyển đổi tín hiệu số thành tương tự?", "answers": ["Router", "Modem", "Switch", "Hub"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 9 — Âm nhạc thế giới
    // ══════════════════════════════
    [
      {"question": "Ban nhạc nào nổi tiếng với bài 'Bohemian Rhapsody'?", "answers": ["The Beatles", "Rolling Stones", "Queen", "Led Zeppelin"], "correctIndex": 2},
      {"question": "Michael Jackson được gọi là 'Vua' của thể loại nhạc gì?", "answers": ["Rock", "Jazz", "Pop", "Soul"], "correctIndex": 2},
      {"question": "Nhạc cụ nào có nhiều dây nhất?", "answers": ["Đàn guitar", "Đàn violin", "Đàn piano", "Đàn harp"], "correctIndex": 3},
      {"question": "Bài hát 'Imagine' do ai sáng tác?", "answers": ["Paul McCartney", "John Lennon", "Ringo Starr", "George Harrison"], "correctIndex": 1},
      {"question": "Mozart sinh ra ở thành phố nào?", "answers": ["Vienna", "Berlin", "Salzburg", "Munich"], "correctIndex": 2},
      {"question": "Nhạc Jazz có nguồn gốc từ quốc gia nào?", "answers": ["Anh", "Pháp", "Cuba", "Mỹ"], "correctIndex": 3},
      {"question": "Cây đàn piano có bao nhiêu phím?", "answers": ["76", "82", "88", "92"], "correctIndex": 2},
      {"question": "Beethoven sáng tác bản nhạc nổi tiếng 'Für Elise' cho nhạc cụ gì?", "answers": ["Violin", "Piano", "Cello", "Flute"], "correctIndex": 1},
      {"question": "Grammy Award được trao cho lĩnh vực nào?", "answers": ["Điện ảnh", "Âm nhạc", "Truyền hình", "Văn học"], "correctIndex": 1},
      {"question": "Thể loại nhạc 'Blues' bắt nguồn từ cộng đồng nào?", "answers": ["Người Mỹ gốc Phi", "Người gốc Latin", "Người Ireland", "Người gốc Á"], "correctIndex": 0},
      {"question": "Ai được mệnh danh là 'The Voice' trong âm nhạc thế giới?", "answers": ["Celine Dion", "Whitney Houston", "Mariah Carey", "Adele"], "correctIndex": 1},
      {"question": "Bản nhạc 'Ode to Joy' của Beethoven thuộc giao hưởng số mấy?", "answers": ["7", "8", "9", "10"], "correctIndex": 2},
      {"question": "Nhạc cụ kèn Trumpet thuộc họ nhạc cụ nào?", "answers": ["Dây", "Hơi gỗ", "Hơi đồng", "Gõ"], "correctIndex": 2},
      {"question": "Bài hát nào được xem là bài hát sinh nhật phổ biến nhất thế giới?", "answers": ["Happy Birthday to You", "For He's a Jolly Good Fellow", "Birthday Song", "Many Happy Returns"], "correctIndex": 0},
      {"question": "Band nhạc nào được gọi là 'The Fab Four'?", "answers": ["Queen", "Rolling Stones", "The Beatles", "Led Zeppelin"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 10 — Điện ảnh
    // ══════════════════════════════
    [
      {"question": "Giải Oscar được trao cho lĩnh vực gì?", "answers": ["Âm nhạc", "Điện ảnh", "Sân khấu", "Văn học"], "correctIndex": 1},
      {"question": "Bộ phim 'Titanic' được đạo diễn bởi ai?", "answers": ["Steven Spielberg", "Martin Scorsese", "James Cameron", "Christopher Nolan"], "correctIndex": 2},
      {"question": "Hãng phim nào tạo ra nhân vật Mickey Mouse?", "answers": ["Warner Bros", "Pixar", "Disney", "DreamWorks"], "correctIndex": 2},
      {"question": "Phim hoạt hình 'Spirited Away' do đạo diễn người Nhật nào thực hiện?", "answers": ["Isao Takahata", "Mamoru Oshii", "Hayao Miyazaki", "Makoto Shinkai"], "correctIndex": 2},
      {"question": "Phim 'The Dark Knight' nói về siêu anh hùng nào?", "answers": ["Superman", "Spider-Man", "Batman", "Iron Man"], "correctIndex": 2},
      {"question": "Ai đóng vai Iron Man trong MCU?", "answers": ["Chris Evans", "Robert Downey Jr.", "Chris Hemsworth", "Mark Ruffalo"], "correctIndex": 1},
      {"question": "Phim 'Schindler's List' được đạo diễn bởi ai?", "answers": ["Francis Ford Coppola", "Steven Spielberg", "Oliver Stone", "Ridley Scott"], "correctIndex": 1},
      {"question": "Phim nào giữ kỷ lục doanh thu cao nhất mọi thời đại?", "answers": ["Titanic", "Avengers: Endgame", "Avatar", "Star Wars"], "correctIndex": 2},
      {"question": "Cannes Film Festival diễn ra hàng năm tại quốc gia nào?", "answers": ["Ý", "Anh", "Pháp", "Mỹ"], "correctIndex": 2},
      {"question": "Bộ phim 'Parasite' đoạt Oscar phim hay nhất đến từ quốc gia nào?", "answers": ["Nhật Bản", "Trung Quốc", "Thái Lan", "Hàn Quốc"], "correctIndex": 3},
      {"question": "Nhân vật James Bond có mã số điệp viên là gì?", "answers": ["005", "006", "007", "008"], "correctIndex": 2},
      {"question": "Phim 'The Godfather' dựa trên tiểu thuyết của ai?", "answers": ["Stephen King", "Mario Puzo", "John Grisham", "Tom Clancy"], "correctIndex": 1},
      {"question": "Giải Cành Cọ Vàng được trao tại liên hoan phim nào?", "answers": ["Oscar", "Venice", "Berlin", "Cannes"], "correctIndex": 3},
      {"question": "Ai đóng vai Joker trong phim 'Joker' (2019)?", "answers": ["Heath Ledger", "Jack Nicholson", "Joaquin Phoenix", "Jared Leto"], "correctIndex": 2},
      {"question": "Franchise phim nào có doanh thu tổng cao nhất thế giới?", "answers": ["Star Wars", "Marvel Cinematic Universe", "Harry Potter", "James Bond"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 11 — Ẩm thực
    // ══════════════════════════════
    [
      {"question": "Món ăn nào là đặc sản nổi tiếng của Hà Nội?", "answers": ["Bánh mì", "Phở", "Bún bò Huế", "Hủ tiếu"], "correctIndex": 1},
      {"question": "Sushi là món ăn truyền thống của quốc gia nào?", "answers": ["Trung Quốc", "Hàn Quốc", "Nhật Bản", "Thái Lan"], "correctIndex": 2},
      {"question": "Pizza có nguồn gốc từ quốc gia nào?", "answers": ["Pháp", "Tây Ban Nha", "Hy Lạp", "Ý"], "correctIndex": 3},
      {"question": "Kimchi là món ăn đặc trưng của quốc gia nào?", "answers": ["Nhật Bản", "Trung Quốc", "Hàn Quốc", "Việt Nam"], "correctIndex": 2},
      {"question": "Trà xanh Matcha nổi tiếng của quốc gia nào?", "answers": ["Trung Quốc", "Nhật Bản", "Hàn Quốc", "Ấn Độ"], "correctIndex": 1},
      {"question": "Bánh mì baguette là đặc sản của quốc gia nào?", "answers": ["Ý", "Pháp", "Bỉ", "Đức"], "correctIndex": 1},
      {"question": "Gia vị nào đắt nhất thế giới?", "answers": ["Tiêu đen", "Nhụy hoa nghệ tây (Saffron)", "Vani", "Quế"], "correctIndex": 1},
      {"question": "Món Pho của Việt Nam được nấu từ loại thịt truyền thống nào?", "answers": ["Heo", "Gà", "Bò", "Vịt"], "correctIndex": 2},
      {"question": "Chocolate được làm từ hạt của cây nào?", "answers": ["Cà phê", "Cacao", "Vanilla", "Hạnh nhân"], "correctIndex": 1},
      {"question": "Rượu Champagne nổi tiếng xuất xứ từ vùng nào của Pháp?", "answers": ["Bordeaux", "Burgundy", "Champagne", "Alsace"], "correctIndex": 2},
      {"question": "Đậu phụ (Tofu) có nguồn gốc từ quốc gia nào?", "answers": ["Nhật Bản", "Hàn Quốc", "Trung Quốc", "Việt Nam"], "correctIndex": 2},
      {"question": "Cà phê Việt Nam nổi tiếng với loại cà phê gì?", "answers": ["Arabica", "Robusta", "Liberica", "Excelsa"], "correctIndex": 1},
      {"question": "Món ăn nào truyền thống trong dịp Tết Việt Nam?", "answers": ["Phở", "Bún bò", "Bánh chưng", "Bánh mì"], "correctIndex": 2},
      {"question": "Paella là món ăn truyền thống của quốc gia nào?", "answers": ["Bồ Đào Nha", "Tây Ban Nha", "Ý", "Hy Lạp"], "correctIndex": 1},
      {"question": "Wasabi thường ăn kèm với món gì?", "answers": ["Ramen", "Tempura", "Sushi", "Teriyaki"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 12 — Động vật
    // ══════════════════════════════
    [
      {"question": "Loài động vật nào được gọi là 'Vua của rừng xanh'?", "answers": ["Hổ", "Sư tử", "Báo", "Gấu"], "correctIndex": 1},
      {"question": "Cá voi xanh là loài động vật lớn nhất trên Trái Đất, nặng bao nhiêu tấn?", "answers": ["50 tấn", "100 tấn", "150 tấn", "200 tấn"], "correctIndex": 2},
      {"question": "Loài chim nào bay nhanh nhất thế giới?", "answers": ["Đại bàng", "Cắt lớn", "Hải âu", "Cò trắng"], "correctIndex": 1},
      {"question": "Loài động vật nào ngủ đứng?", "answers": ["Ngựa", "Bò", "Voi", "Tất cả đều đúng"], "correctIndex": 3},
      {"question": "Bạch tuộc có bao nhiêu xúc tu?", "answers": ["6", "8", "10", "12"], "correctIndex": 1},
      {"question": "Loài động vật nào có tuổi thọ lâu nhất?", "answers": ["Rùa", "Cá voi", "Voi", "Cá sấu"], "correctIndex": 0},
      {"question": "Kangaroo là loài vật đặc trưng của quốc gia nào?", "answers": ["New Zealand", "Úc", "Nam Phi", "Brazil"], "correctIndex": 1},
      {"question": "Gấu trúc khổng lồ là loài vật biểu tượng của quốc gia nào?", "answers": ["Nhật Bản", "Thái Lan", "Trung Quốc", "Hàn Quốc"], "correctIndex": 2},
      {"question": "Loài côn trùng nào là loài đông nhất thế giới?", "answers": ["Ong", "Kiến", "Muỗi", "Bọ cánh cứng"], "correctIndex": 1},
      {"question": "Con tằm tạo ra sợi tơ từ bộ phận nào?", "answers": ["Miệng", "Bụng", "Chân", "Lưng"], "correctIndex": 0},
      {"question": "Loài cá nào có thể phát ra điện?", "answers": ["Cá hồi", "Cá chình điện", "Cá ngừ", "Cá kiếm"], "correctIndex": 1},
      {"question": "Hươu cao cổ là loài động vật có cổ dài nhất, chiều cao trung bình là bao nhiêu?", "answers": ["3-4m", "4-5m", "5-6m", "6-7m"], "correctIndex": 2},
      {"question": "Loài chim nào không biết bay?", "answers": ["Cánh cụt", "Kiwi", "Đà điểu", "Tất cả đều đúng"], "correctIndex": 3},
      {"question": "Tê giác có sừng làm từ chất liệu gì?", "answers": ["Xương", "Ngà", "Keratin", "Can-xi"], "correctIndex": 2},
      {"question": "Loài động vật có vú nào đẻ trứng?", "answers": ["Chuột chũi", "Thú mỏ vịt", "Chuột túi", "Sóc"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 13 — Y tế & Sức khỏe
    // ══════════════════════════════
    [
      {"question": "Tim người bơm bao nhiêu lít máu mỗi phút khi nghỉ ngơi?", "answers": ["2-3 lít", "4-5 lít", "6-7 lít", "8-9 lít"], "correctIndex": 1},
      {"question": "Cơ thể người có bao nhiêu xương?", "answers": ["186", "196", "206", "216"], "correctIndex": 2},
      {"question": "Nhóm máu nào được gọi là 'người cho máu toàn năng'?", "answers": ["A", "B", "AB", "O"], "correctIndex": 3},
      {"question": "Vitamin C có nhiều trong loại quả nào?", "answers": ["Táo", "Chuối", "Cam", "Nho"], "correctIndex": 2},
      {"question": "Bệnh viêm gan B do tác nhân nào gây ra?", "answers": ["Vi khuẩn", "Ký sinh trùng", "Virus", "Nấm"], "correctIndex": 2},
      {"question": "Não người chiếm khoảng bao nhiêu phần trăm trọng lượng cơ thể?", "answers": ["1%", "2%", "3%", "5%"], "correctIndex": 1},
      {"question": "Huyết áp bình thường của người trưởng thành là bao nhiêu?", "answers": ["100/60 mmHg", "120/80 mmHg", "140/90 mmHg", "160/100 mmHg"], "correctIndex": 1},
      {"question": "Loại tế bào nào có nhiệm vụ bảo vệ cơ thể khỏi vi khuẩn?", "answers": ["Hồng cầu", "Tiểu cầu", "Bạch cầu", "Tế bào thần kinh"], "correctIndex": 2},
      {"question": "Cơ quan nào sản xuất insulin?", "answers": ["Gan", "Thận", "Tụy", "Dạ dày"], "correctIndex": 2},
      {"question": "Bệnh đái tháo đường (tiểu đường) liên quan đến nồng độ chất gì trong máu?", "answers": ["Cholesterol", "Glucose", "Protein", "Canxi"], "correctIndex": 1},
      {"question": "Con người cần ngủ bao nhiêu tiếng mỗi ngày để đảm bảo sức khỏe?", "answers": ["4-5 tiếng", "5-6 tiếng", "7-9 tiếng", "10-12 tiếng"], "correctIndex": 2},
      {"question": "Vitamin D được cơ thể tổng hợp qua tác động của gì?", "answers": ["Nước", "Ánh nắng mặt trời", "Không khí", "Thức ăn"], "correctIndex": 1},
      {"question": "Bệnh sốt xuất huyết do loài muỗi nào truyền?", "answers": ["Muỗi Anopheles", "Muỗi Culex", "Muỗi Aedes", "Muỗi Mansonia"], "correctIndex": 2},
      {"question": "Cơ quan nào có chức năng lọc máu trong cơ thể?", "answers": ["Gan và phổi", "Tim và phổi", "Thận và gan", "Lách và thận"], "correctIndex": 2},
      {"question": "BMI (chỉ số khối cơ thể) bình thường nằm trong khoảng nào?", "answers": ["15-18,5", "18,5-24,9", "25-29,9", "30-34,9"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 14 — Kinh tế
    // ══════════════════════════════
    [
      {"question": "GDP là viết tắt của cụm từ gì?", "answers": ["General Domestic Product", "Gross Domestic Product", "Global Domestic Product", "Grand Domestic Product"], "correctIndex": 1},
      {"question": "Quốc gia nào có GDP lớn nhất thế giới?", "answers": ["Trung Quốc", "Mỹ", "Nhật Bản", "Đức"], "correctIndex": 1},
      {"question": "Đồng tiền chung của khu vực Eurozone là gì?", "answers": ["Bảng Anh", "Đô la", "Euro", "Frank"], "correctIndex": 2},
      {"question": "WTO là tổ chức gì?", "answers": ["Tổ chức Thương mại Thế giới", "Tổ chức Tài chính Thế giới", "Tổ chức Kinh tế Thế giới", "Tổ chức Công nghiệp Thế giới"], "correctIndex": 0},
      {"question": "Lạm phát là gì?", "answers": ["Giá hàng hóa giảm", "Giá hàng hóa tăng liên tục", "Kinh tế tăng trưởng", "Thất nghiệp tăng"], "correctIndex": 1},
      {"question": "Bitcoin là loại gì?", "answers": ["Cổ phiếu", "Tiền điện tử", "Trái phiếu", "Vàng kỹ thuật số"], "correctIndex": 1},
      {"question": "Sở giao dịch chứng khoán lớn nhất thế giới là gì?", "answers": ["London Stock Exchange", "Tokyo Stock Exchange", "New York Stock Exchange", "Shanghai Stock Exchange"], "correctIndex": 2},
      {"question": "IMF là viết tắt của tổ chức nào?", "answers": ["Quỹ Tiền tệ Quốc tế", "Ngân hàng Thế giới", "Tổ chức Hợp tác Kinh tế", "Quỹ Phát triển Quốc tế"], "correctIndex": 0},
      {"question": "Chuỗi cung ứng (Supply Chain) bắt đầu từ đâu?", "answers": ["Nhà bán lẻ", "Người tiêu dùng", "Nhà cung cấp nguyên liệu", "Nhà sản xuất"], "correctIndex": 2},
      {"question": "Năm 2008 xảy ra khủng hoảng tài chính toàn cầu bắt nguồn từ ngành nào?", "answers": ["Bất động sản và ngân hàng", "Công nghệ thông tin", "Dầu mỏ", "Ô tô"], "correctIndex": 0},
      {"question": "Đồng tiền của Nhật Bản là gì?", "answers": ["Won", "Nhân dân tệ", "Yên", "Baht"], "correctIndex": 2},
      {"question": "Nguyên tắc cơ bản nào của kinh tế học là 'không có bữa ăn trưa miễn phí'?", "answers": ["Chi phí cơ hội", "Luật cung cầu", "Kinh tế vĩ mô", "Tối đa hóa lợi nhuận"], "correctIndex": 0},
      {"question": "ASEAN được thành lập năm nào?", "answers": ["1960", "1965", "1967", "1970"], "correctIndex": 2},
      {"question": "Ngân hàng trung ương của Mỹ được gọi là gì?", "answers": ["World Bank", "Federal Reserve", "IMF", "Bank of America"], "correctIndex": 1},
      {"question": "Chỉ số VN-Index là chỉ số chứng khoán của quốc gia nào?", "answers": ["Venezuela", "Vietnam", "Vanuatu", "Virgin Islands"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 15 — Nghệ thuật & Kiến trúc
    // ══════════════════════════════
    [
      {"question": "Bức tranh 'Mona Lisa' được vẽ bởi ai?", "answers": ["Michelangelo", "Leonardo da Vinci", "Raphael", "Botticelli"], "correctIndex": 1},
      {"question": "Tháp Eiffel được xây dựng năm nào?", "answers": ["1879", "1884", "1889", "1894"], "correctIndex": 2},
      {"question": "Đấu trường La Mã (Colosseum) nằm ở thành phố nào?", "answers": ["Athens", "Rome", "Paris", "Madrid"], "correctIndex": 1},
      {"question": "Bức tượng nổi tiếng 'Tiếng thét' do họa sĩ người nước nào vẽ?", "answers": ["Pháp", "Đức", "Na Uy", "Thụy Điển"], "correctIndex": 2},
      {"question": "Vạn Lý Trường Thành được xây dựng để bảo vệ đế chế nào?", "answers": ["Nhật Bản", "Mông Cổ", "Trung Quốc", "Hàn Quốc"], "correctIndex": 2},
      {"question": "Bảo tàng nào nổi tiếng nhất thế giới, lưu giữ Mona Lisa?", "answers": ["British Museum", "Metropolitan Museum", "Louvre", "Prado"], "correctIndex": 2},
      {"question": "Trường phái hội họa 'Ấn tượng' (Impressionism) xuất hiện ở đâu?", "answers": ["Anh", "Ý", "Pháp", "Đức"], "correctIndex": 2},
      {"question": "Ai là kiến trúc sư thiết kế nhà hát Opera Sydney?", "answers": ["Norman Foster", "Jørn Utzon", "Frank Gehry", "Zaha Hadid"], "correctIndex": 1},
      {"question": "Đền Taj Mahal nằm ở quốc gia nào?", "answers": ["Pakistan", "Bangladesh", "Nepal", "Ấn Độ"], "correctIndex": 3},
      {"question": "Bức tranh 'The Starry Night' do ai vẽ?", "answers": ["Claude Monet", "Pablo Picasso", "Vincent van Gogh", "Salvador Dalí"], "correctIndex": 2},
      {"question": "Tượng Nhân Sư (Sphinx) nằm ở quốc gia nào?", "answers": ["Iraq", "Jordan", "Ai Cập", "Saudi Arabia"], "correctIndex": 2},
      {"question": "Kiến trúc Gothic nổi tiếng bởi đặc điểm gì?", "answers": ["Mái tròn", "Cột thẳng đứng", "Mái vòm nhọn", "Tường phẳng"], "correctIndex": 2},
      {"question": "Bức tranh 'Guernica' mô tả thảm kịch ở quốc gia nào?", "answers": ["Pháp", "Tây Ban Nha", "Ý", "Đức"], "correctIndex": 1},
      {"question": "Stonehenge nằm ở quốc gia nào?", "answers": ["Ireland", "Scotland", "Wales", "Anh"], "correctIndex": 3},
      {"question": "Michelangelo vẽ trần nhà nguyện Sistine ở đâu?", "answers": ["Florence", "Milan", "Vatican", "Venice"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 16 — Thiên văn học
    // ══════════════════════════════
    [
      {"question": "Mặt Trời thuộc loại thiên thể gì?", "answers": ["Hành tinh", "Sao lùn", "Ngôi sao", "Tiểu hành tinh"], "correctIndex": 2},
      {"question": "Hệ Mặt Trời có bao nhiêu hành tinh?", "answers": ["7", "8", "9", "10"], "correctIndex": 1},
      {"question": "Hành tinh nào có nhiều mặt trăng nhất trong Hệ Mặt Trời?", "answers": ["Sao Mộc", "Sao Thổ", "Sao Hải Vương", "Sao Thiên Vương"], "correctIndex": 1},
      {"question": "Dải Ngân Hà có đường kính khoảng bao nhiêu năm ánh sáng?", "answers": ["10.000", "50.000", "100.000", "1.000.000"], "correctIndex": 2},
      {"question": "Lỗ đen (Black Hole) hấp thụ cả gì?", "answers": ["Chỉ vật chất", "Chỉ ánh sáng", "Cả vật chất và ánh sáng", "Chỉ khí"], "correctIndex": 2},
      {"question": "Mặt Trăng mất bao lâu để quay một vòng quanh Trái Đất?", "answers": ["7 ngày", "14 ngày", "27 ngày", "30 ngày"], "correctIndex": 2},
      {"question": "Sao nào gần Trái Đất nhất (ngoài Mặt Trời)?", "answers": ["Sirius", "Proxima Centauri", "Alpha Centauri", "Betelgeuse"], "correctIndex": 1},
      {"question": "Tàu vũ trụ nào đưa con người lên Mặt Trăng lần đầu tiên?", "answers": ["Apollo 10", "Apollo 11", "Apollo 12", "Apollo 13"], "correctIndex": 1},
      {"question": "Sao Hỏa được gọi là 'Hành tinh đỏ' vì lý do gì?", "answers": ["Đất chứa sắt oxide", "Bầu khí quyển đỏ", "Nhiệt độ cực cao", "Ánh sáng phản chiếu"], "correctIndex": 0},
      {"question": "Thiên văn học nghiên cứu về gì?", "answers": ["Khí quyển Trái Đất", "Lòng đất", "Vũ trụ và thiên thể", "Đại dương"], "correctIndex": 2},
      {"question": "Hiện tượng 'nhật thực' xảy ra khi nào?", "answers": ["Mặt Trăng che Mặt Trời", "Trái Đất che Mặt Trăng", "Mặt Trời che Mặt Trăng", "Trái Đất che Mặt Trời"], "correctIndex": 0},
      {"question": "Vũ trụ hình thành qua sự kiện nào khoảng 13,8 tỷ năm trước?", "answers": ["Big Freeze", "Big Crunch", "Big Bang", "Big Rip"], "correctIndex": 2},
      {"question": "Hành tinh nào có vành đai nổi tiếng nhất?", "answers": ["Sao Mộc", "Sao Thổ", "Sao Hải Vương", "Sao Thiên Vương"], "correctIndex": 1},
      {"question": "Kính thiên văn vũ trụ nổi tiếng nhất mang tên ai?", "answers": ["Newton", "Einstein", "Hubble", "Galileo"], "correctIndex": 2},
      {"question": "Nhiệt độ bề mặt Mặt Trời khoảng bao nhiêu độ C?", "answers": ["1.000°C", "3.000°C", "5.500°C", "10.000°C"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 17 — Ngôn ngữ & Chữ viết
    // ══════════════════════════════
    [
      {"question": "Ngôn ngữ nào có nhiều người nói nhất thế giới (bao gồm tiếng mẹ đẻ và thứ hai)?", "answers": ["Tiếng Anh", "Tiếng Quan Thoại", "Tiếng Hindi", "Tiếng Tây Ban Nha"], "correctIndex": 0},
      {"question": "Bảng chữ cái tiếng Việt có bao nhiêu chữ cái?", "answers": ["26", "27", "28", "29"], "correctIndex": 3},
      {"question": "Tiếng Anh có nguồn gốc chính từ ngữ hệ nào?", "answers": ["Latin", "German", "French", "Celtic"], "correctIndex": 1},
      {"question": "Chữ viết cổ nhất thế giới là gì?", "answers": ["Chữ Hán", "Chữ Hieroglyphics", "Chữ hình nêm (Cuneiform)", "Chữ Hy Lạp"], "correctIndex": 2},
      {"question": "Tiếng Tây Ban Nha là ngôn ngữ chính thức của bao nhiêu quốc gia?", "answers": ["15", "18", "20", "22"], "correctIndex": 2},
      {"question": "Morse code được phát minh bởi ai?", "answers": ["Graham Bell", "Samuel Morse", "Thomas Edison", "Nikola Tesla"], "correctIndex": 1},
      {"question": "Ngôn ngữ lập trình nào gần giống với ngôn ngữ tự nhiên nhất?", "answers": ["C++", "Python", "COBOL", "Assembly"], "correctIndex": 2},
      {"question": "Chữ Quốc ngữ (chữ Latinh tiếng Việt) do ai tạo ra?", "answers": ["Alexandre de Rhodes", "Pigneau de Béhaine", "Francisco de Pina", "Gaspar do Amaral"], "correctIndex": 0},
      {"question": "Ngôn ngữ nào sử dụng bảng chữ cái Cyrillic?", "answers": ["Ả Rập", "Tiếng Nga", "Tiếng Hy Lạp", "Tiếng Hebrew"], "correctIndex": 1},
      {"question": "Tiếng Anh có bao nhiêu chữ cái trong bảng chữ cái?", "answers": ["24", "25", "26", "27"], "correctIndex": 2},
      {"question": "Ngôn ngữ nào được dùng trong kinh Phật cổ đại?", "answers": ["Sanskrit", "Pali", "Tibetan", "Khmer"], "correctIndex": 1},
      {"question": "Ký hiệu '@' trong email tiếng Việt gọi là gì?", "answers": ["Còng", "Ốc", "Xoắn", "Vòng"], "correctIndex": 0},
      {"question": "UN (Liên Hợp Quốc) có bao nhiêu ngôn ngữ chính thức?", "answers": ["4", "5", "6", "7"], "correctIndex": 2},
      {"question": "Tiếng Nhật có bao nhiêu hệ thống chữ viết chính?", "answers": ["1", "2", "3", "4"], "correctIndex": 2},
      {"question": "Braille là hệ thống chữ viết dành cho ai?", "answers": ["Người câm", "Người điếc", "Người mù", "Người khuyết tật vận động"], "correctIndex": 2},
    ],

    // ══════════════════════════════
    //  MÀN 18 — Triết học & Tâm lý học
    // ══════════════════════════════
    [
      {"question": "Triết gia nào nói câu 'Tôi suy nghĩ, vậy tôi tồn tại'?", "answers": ["Plato", "Aristotle", "Descartes", "Kant"], "correctIndex": 2},
      {"question": "Maslow nổi tiếng với lý thuyết gì trong tâm lý học?", "answers": ["Tháp nhu cầu", "Lý thuyết học tập", "Tâm lý phân tích", "Hành vi học"], "correctIndex": 0},
      {"question": "Ai là 'cha đẻ của triết học phương Tây'?", "answers": ["Socrates", "Plato", "Aristotle", "Thales"], "correctIndex": 0},
      {"question": "Freud nổi tiếng với lý thuyết về gì?", "answers": ["Hành vi", "Vô thức và tâm lý phân tích", "Nhận thức", "Cảm xúc"], "correctIndex": 1},
      {"question": "Hiện tượng 'Placebo' trong y học là gì?", "answers": ["Thuốc thật", "Phản ứng phụ", "Hiệu ứng tâm lý từ thuốc giả", "Liều dùng cao"], "correctIndex": 2},
      {"question": "IQ viết tắt của gì?", "answers": ["Intelligence Quantity", "Intelligence Quotient", "Intellectual Quality", "Inner Quotient"], "correctIndex": 1},
      {"question": "Triết học Phật giáo nhấn mạnh điều gì là gốc rễ của khổ đau?", "answers": ["Nghèo đói", "Tham ái và vô minh", "Bệnh tật", "Cái chết"], "correctIndex": 1},
      {"question": "Lý thuyết 'Conditioning' (điều kiện hóa) nổi tiếng với thí nghiệm nào?", "answers": ["Con chó của Pavlov", "Chuột mê cung", "Khỉ quan sát", "Mèo trong hộp"], "correctIndex": 0},
      {"question": "Triết học Stoicism chủ trương điều gì?", "answers": ["Theo đuổi khoái lạc", "Kiểm soát cảm xúc và lý trí", "Tìm kiếm sự hoàn hảo", "Tránh xa xã hội"], "correctIndex": 1},
      {"question": "Hiện tượng 'Cognitive Dissonance' là gì?", "answers": ["Mâu thuẫn nội tâm", "Mất trí nhớ", "Rối loạn tư duy", "Ảo giác"], "correctIndex": 0},
      {"question": "Ai viết tác phẩm triết học 'Phê phán lý tính thuần túy'?", "answers": ["Hegel", "Nietzsche", "Kant", "Schopenhauer"], "correctIndex": 2},
      {"question": "Lý thuyết tiến hóa của Darwin được áp dụng vào triết học xã hội gọi là?", "answers": ["Social Darwinism", "Marxism", "Utilitarianism", "Pragmatism"], "correctIndex": 0},
      {"question": "Khổng Tử là triết gia của nền văn minh nào?", "answers": ["Ấn Độ", "Nhật Bản", "Trung Hoa", "Hàn Quốc"], "correctIndex": 2},
      {"question": "EQ là gì?", "answers": ["Educational Quotient", "Emotional Quotient", "Ethical Quotient", "Energy Quotient"], "correctIndex": 1},
      {"question": "Triết học hiện sinh (Existentialism) gắn với triết gia nào?", "answers": ["Bertrand Russell", "Jean-Paul Sartre", "John Dewey", "William James"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 19 — Môi trường
    // ══════════════════════════════
    [
      {"question": "Khí nào gây ra hiệu ứng nhà kính nhiều nhất?", "answers": ["Ozone", "CO2", "Methane", "NO2"], "correctIndex": 1},
      {"question": "Tầng ozone bảo vệ Trái Đất khỏi điều gì?", "answers": ["Mưa axit", "Tia cực tím UV", "Ô nhiễm không khí", "Sóng điện từ"], "correctIndex": 1},
      {"question": "Hiệp định Paris về biến đổi khí hậu ký năm nào?", "answers": ["2012", "2013", "2015", "2016"], "correctIndex": 2},
      {"question": "Mực nước biển dâng cao do nguyên nhân chính nào?", "answers": ["Mưa nhiều", "Băng tan do nhiệt độ tăng", "Núi lửa phun trào", "Động đất"], "correctIndex": 1},
      {"question": "Rừng Amazon chiếm bao nhiêu % diện tích rừng nhiệt đới thế giới?", "answers": ["30%", "40%", "50%", "60%"], "correctIndex": 2},
      {"question": "Năng lượng nào thân thiện với môi trường nhất?", "answers": ["Than đá", "Dầu mỏ", "Khí tự nhiên", "Năng lượng mặt trời"], "correctIndex": 3},
      {"question": "Rác thải nhựa mất bao nhiêu năm để phân hủy trong tự nhiên?", "answers": ["10-50 năm", "50-100 năm", "100-450 năm", "500-1000 năm"], "correctIndex": 2},
      {"question": "Ngày Môi trường Thế giới là ngày mấy?", "answers": ["5/4", "5/5", "5/6", "5/7"], "correctIndex": 2},
      {"question": "Quá trình biến chất thải hữu cơ thành phân bón gọi là gì?", "answers": ["Recycling", "Composting", "Incineration", "Landfilling"], "correctIndex": 1},
      {"question": "Loài nào được coi là chỉ thị môi trường nước sạch?", "answers": ["Cá chép", "Ếch", "Con tôm", "Cá trê"], "correctIndex": 1},
      {"question": "CO2 viết tắt của hợp chất gì?", "answers": ["Carbon Monoxide", "Carbon Dioxide", "Calcium Oxide", "Cobalt Dioxide"], "correctIndex": 1},
      {"question": "Nguyên nhân chính gây ra mưa axit là gì?", "answers": ["CO2 và Methane", "SO2 và NOx", "Ozone và CO", "Chlorine và Fluorine"], "correctIndex": 1},
      {"question": "Từ 'Ecology' (sinh thái học) liên quan đến nghiên cứu gì?", "answers": ["Kinh tế", "Mối quan hệ sinh vật và môi trường", "Địa chất", "Hóa học"], "correctIndex": 1},
      {"question": "El Niño là hiện tượng gì?", "answers": ["Bão nhiệt đới", "Ấm lên của nước biển Thái Bình Dương", "Lũ lụt đại dương", "Sóng thần"], "correctIndex": 1},
      {"question": "Chỉ số AQI đo lường gì?", "answers": ["Chất lượng nước", "Chất lượng không khí", "Chất lượng đất", "Nhiệt độ môi trường"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 20 — Thế giới hiện đại
    // ══════════════════════════════
    [
      {"question": "Liên Hợp Quốc được thành lập năm nào?", "answers": ["1943", "1944", "1945", "1946"], "correctIndex": 2},
      {"question": "Bức tường Berlin sụp đổ năm nào?", "answers": ["1987", "1988", "1989", "1990"], "correctIndex": 2},
      {"question": "Tổ chức NATO được thành lập năm nào?", "answers": ["1947", "1949", "1951", "1953"], "correctIndex": 1},
      {"question": "Ai là người đầu tiên đặt chân lên Mặt Trăng?", "answers": ["Buzz Aldrin", "Neil Armstrong", "Michael Collins", "Yuri Gagarin"], "correctIndex": 1},
      {"question": "Điện thoại thông minh đầu tiên được Apple ra mắt năm nào?", "answers": ["2005", "2006", "2007", "2008"], "correctIndex": 2},
      {"question": "Đại dịch COVID-19 bùng phát lần đầu ở đâu?", "answers": ["Bắc Kinh", "Thượng Hải", "Vũ Hán", "Hồng Kông"], "correctIndex": 2},
      {"question": "Mạng xã hội nào có nhiều người dùng nhất thế giới?", "answers": ["Instagram", "Twitter/X", "TikTok", "Facebook"], "correctIndex": 3},
      {"question": "Hiệp ước Paris (1783) chính thức kết thúc cuộc chiến nào?", "answers": ["Thế chiến 1", "Thế chiến 2", "Chiến tranh Mỹ - Anh độc lập", "Chiến tranh Lạnh"], "correctIndex": 2},
      {"question": "Liên minh châu Âu (EU) hiện có bao nhiêu thành viên?", "answers": ["25", "27", "29", "31"], "correctIndex": 1},
      {"question": "ChatGPT do công ty nào phát triển?", "answers": ["Google", "Microsoft", "OpenAI", "Meta"], "correctIndex": 2},
      {"question": "Elon Musk là CEO của những công ty nào?", "answers": ["Tesla và SpaceX", "Apple và Tesla", "Amazon và SpaceX", "Google và Tesla"], "correctIndex": 0},
      {"question": "Chiến tranh Lạnh kết thúc khi nào?", "answers": ["1985", "1989", "1991", "1993"], "correctIndex": 2},
      {"question": "Tổ chức Y tế Thế giới viết tắt là gì?", "answers": ["WTO", "WFP", "WHO", "UNICEF"], "correctIndex": 2},
      {"question": "Metaverse là khái niệm gắn với công ty nào?", "answers": ["Apple", "Microsoft", "Meta (Facebook)", "Google"], "correctIndex": 2},
      {"question": "Giải Nobel Hòa bình 2024 được trao cho tổ chức nào?", "answers": ["Doctors Without Borders", "Nihon Hidankyo", "UNHCR", "Red Cross"], "correctIndex": 1},
    ],

    // ══════════════════════════════
    //  MÀN 21–30: Tổng hợp nâng cao
    // ══════════════════════════════
    // MÀN 21
    [
      {"question": "Trong hóa học, pH = 7 biểu thị dung dịch có tính gì?", "answers": ["Acid", "Kiềm", "Trung tính", "Muối"], "correctIndex": 2},
      {"question": "Đơn vị đo cường độ âm thanh là gì?", "answers": ["Hertz", "Decibel", "Watt", "Lux"], "correctIndex": 1},
      {"question": "Thuyết tương đối được phát triển bởi ai?", "answers": ["Newton", "Bohr", "Einstein", "Hawking"], "correctIndex": 2},
      {"question": "Nguyên tố nào nhẹ nhất trong bảng tuần hoàn?", "answers": ["Helium", "Hydrogen", "Lithium", "Oxygen"], "correctIndex": 1},
      {"question": "Nhiệt kế Celsius và Fahrenheit bằng nhau ở bao nhiêu độ?", "answers": ["-32°", "-40°", "-48°", "-56°"], "correctIndex": 1},
      {"question": "Màu nào không có trong cầu vồng?", "answers": ["Chàm", "Tím", "Hồng", "Cam"], "correctIndex": 2},
      {"question": "Trái Đất quay một vòng quanh Mặt Trời mất bao lâu?", "answers": ["364 ngày", "365 ngày", "365,25 ngày", "366 ngày"], "correctIndex": 2},
      {"question": "Tế bào nào không có nhân?", "answers": ["Tế bào cơ", "Hồng cầu trưởng thành", "Tế bào thần kinh", "Tế bào gan"], "correctIndex": 1},
      {"question": "Chuỗi DNA xoắn kép được khám phá bởi ai?", "answers": ["Mendel", "Darwin", "Watson & Crick", "Fleming"], "correctIndex": 2},
      {"question": "Sấm sét xảy ra do hiện tượng gì?", "answers": ["Gió mạnh", "Phóng điện tích trong khí quyển", "Áp suất không khí", "Bức xạ mặt trời"], "correctIndex": 1},
      {"question": "Kim cương là dạng tinh thể của nguyên tố nào?", "answers": ["Silicon", "Boron", "Carbon", "Nitrogen"], "correctIndex": 2},
      {"question": "Đơn vị đo điện trở là gì?", "answers": ["Volt", "Ampere", "Ohm", "Watt"], "correctIndex": 2},
      {"question": "Mô hình nguyên tử hiện đại nhất được gọi là gì?", "answers": ["Mô hình Bohr", "Mô hình cơ học lượng tử", "Mô hình Thomson", "Mô hình Rutherford"], "correctIndex": 1},
      {"question": "Phản ứng nào xảy ra trong lò phản ứng hạt nhân?", "answers": ["Phản ứng hóa học", "Phân hạch", "Tổng hợp hạt nhân", "Phản ứng quang học"], "correctIndex": 1},
      {"question": "Sóng âm không thể truyền trong môi trường nào?", "answers": ["Không khí", "Nước", "Chân không", "Kim loại"], "correctIndex": 2},
    ],

    // MÀN 22
    [
      {"question": "Cuộc cách mạng công nghiệp lần thứ nhất bắt đầu ở đâu?", "answers": ["Pháp", "Đức", "Mỹ", "Anh"], "correctIndex": 3},
      {"question": "Bộ luật cổ đại nổi tiếng nhất thế giới là gì?", "answers": ["Luật La Mã", "Bộ luật Hammurabi", "Magna Carta", "Bộ luật Justinian"], "correctIndex": 1},
      {"question": "Đế quốc La Mã sụp đổ năm nào?", "answers": ["376", "410", "455", "476"], "correctIndex": 3},
      {"question": "Ai phát minh ra kính hiển vi?", "answers": ["Galileo", "Antonie van Leeuwenhoek", "Robert Hooke", "Isaac Newton"], "correctIndex": 1},
      {"question": "Cuộc Đại suy thoái kinh tế thế giới bắt đầu năm nào?", "answers": ["1927", "1929", "1931", "1933"], "correctIndex": 1},
      {"question": "Chiến tranh Thế giới thứ Nhất kết thúc năm nào?", "answers": ["1916", "1917", "1918", "1919"], "correctIndex": 2},
      {"question": "Hiệp ước Versailles ký năm nào sau Thế chiến 1?", "answers": ["1917", "1918", "1919", "1920"], "correctIndex": 2},
      {"question": "Ai là người phát minh ra điện thoại?", "answers": ["Thomas Edison", "Nikola Tesla", "Alexander Graham Bell", "Guglielmo Marconi"], "correctIndex": 2},
      {"question": "Phong trào Phục Hưng (Renaissance) bắt đầu ở đâu?", "answers": ["Pháp", "Anh", "Ý", "Tây Ban Nha"], "correctIndex": 2},
      {"question": "Ai phát minh ra bóng đèn điện?", "answers": ["Benjamin Franklin", "Nikola Tesla", "James Watt", "Thomas Edison"], "correctIndex": 3},
      {"question": "Cuộc cách mạng Pháp nổ ra năm nào?", "answers": ["1785", "1787", "1789", "1791"], "correctIndex": 2},
      {"question": "Ai là người đầu tiên đi vòng quanh Trái Đất?", "answers": ["Columbus", "Vasco da Gama", "Magellan", "Drake"], "correctIndex": 2},
      {"question": "Đế chế Mông Cổ đạt đỉnh cao dưới triều đại của ai?", "answers": ["Hốt Tất Liệt", "Thành Cát Tư Hãn", "Oa Khoát Đài", "Mông Ca"], "correctIndex": 1},
      {"question": "Thế chiến 2 chính thức kết thúc năm nào?", "answers": ["1943", "1944", "1945", "1946"], "correctIndex": 2},
      {"question": "Ai là người phát minh ra máy in?", "answers": ["Leonardo da Vinci", "Johannes Gutenberg", "Benjamin Franklin", "James Watt"], "correctIndex": 1},
    ],

    // MÀN 23
    [
      {"question": "Tứ đại phát minh của Trung Quốc cổ đại gồm những gì?", "answers": ["Giấy, in, la bàn, thuốc súng", "Giấy, lụa, gốm, chè", "La bàn, kính, giấy, pháo", "Thuốc súng, lụa, gốm, in"], "correctIndex": 0},
      {"question": "Ai là người đề xuất thuyết nhật tâm (Mặt Trời là trung tâm)?", "answers": ["Galileo", "Kepler", "Copernicus", "Brahe"], "correctIndex": 2},
      {"question": "Chất kháng sinh đầu tiên (Penicillin) được phát hiện bởi ai?", "answers": ["Louis Pasteur", "Robert Koch", "Alexander Fleming", "Joseph Lister"], "correctIndex": 2},
      {"question": "Ngôn ngữ lập trình Python ra đời năm nào?", "answers": ["1985", "1989", "1991", "1995"], "correctIndex": 2},
      {"question": "Mạng Internet ban đầu được phát triển để phục vụ mục đích gì?", "answers": ["Thương mại", "Giáo dục", "Quân sự", "Giải trí"], "correctIndex": 2},
      {"question": "Tàu vũ trụ nào đầu tiên rời khỏi Hệ Mặt Trời?", "answers": ["Voyager 1", "Pioneer 10", "New Horizons", "Cassini"], "correctIndex": 0},
      {"question": "Ai là nhà khoa học đầu tiên đưa ra khái niệm 'lực hấp dẫn'?", "answers": ["Einstein", "Galileo", "Newton", "Kepler"], "correctIndex": 2},
      {"question": "Thuốc lá gây hại cho cơ quan nào nhiều nhất?", "answers": ["Gan", "Tim", "Phổi", "Thận"], "correctIndex": 2},
      {"question": "ChatGPT được ra mắt công khai năm nào?", "answers": ["2020", "2021", "2022", "2023"], "correctIndex": 2},
      {"question": "Blockchain là công nghệ nền tảng của loại tiền nào?", "answers": ["Đô la điện tử", "Tiền điện tử (Cryptocurrency)", "Thẻ tín dụng", "Thanh toán QR"], "correctIndex": 1},
      {"question": "Hội chứng Stockholm là gì?", "answers": ["Sợ không gian hẹp", "Cảm xúc tích cực với người bắt cóc", "Rối loạn lo âu", "Sợ đám đông"], "correctIndex": 1},
      {"question": "Tàu không gian SpaceX Starship được phát triển bởi ai?", "answers": ["NASA", "Boeing", "SpaceX - Elon Musk", "Blue Origin - Jeff Bezos"], "correctIndex": 2},
      {"question": "Hiệu ứng Doppler mô tả hiện tượng gì?", "answers": ["Ánh sáng bị bẻ cong", "Thay đổi tần số sóng khi nguồn di chuyển", "Phản xạ sóng âm", "Hấp thụ ánh sáng"], "correctIndex": 1},
      {"question": "Định luật bảo toàn năng lượng phát biểu rằng?", "answers": ["Năng lượng không thể tạo ra hoặc mất đi", "Năng lượng có thể tạo ra từ chân không", "Năng lượng giảm theo thời gian", "Năng lượng tăng theo nhiệt độ"], "correctIndex": 0},
      {"question": "Quá trình tổng hợp protein diễn ra ở bào quan nào?", "answers": ["Mitochondria", "Nucleus", "Ribosome", "Golgi apparatus"], "correctIndex": 2},
    ],

    // MÀN 24
    [
      {"question": "Cung hoàng đạo nào tương ứng với người sinh từ 21/3 - 19/4?", "answers": ["Bạch Dương", "Kim Ngưu", "Song Tử", "Cự Giải"], "correctIndex": 0},
      {"question": "Bài thơ 'Ông đồ' do ai sáng tác?", "answers": ["Tế Hanh", "Vũ Đình Liên", "Thế Lữ", "Lưu Trọng Lư"], "correctIndex": 1},
      {"question": "Nhân vật Tôn Ngộ Không xuất hiện trong tác phẩm nào?", "answers": ["Thủy Hử", "Tam Quốc Diễn Nghĩa", "Tây Du Ký", "Hồng Lâu Mộng"], "correctIndex": 2},
      {"question": "Trò chơi Rubik's Cube được phát minh bởi người nước nào?", "answers": ["Đức", "Hungary", "Áo", "Tiệp Khắc"], "correctIndex": 1},
      {"question": "Giải thưởng Nobel đầu tiên trao năm nào?", "answers": ["1895", "1899", "1901", "1905"], "correctIndex": 2},
      {"question": "Thành phố nào có biệt danh 'Apple Big' (Quả táo lớn)?", "answers": ["Los Angeles", "Chicago", "New York", "San Francisco"], "correctIndex": 2},
      {"question": "Vật liệu nào dẫn điện tốt nhất?", "answers": ["Vàng", "Bạc", "Đồng", "Nhôm"], "correctIndex": 1},
      {"question": "Đèn LED là viết tắt của gì?", "answers": ["Light Emitting Device", "Light Energy Diode", "Light Emitting Diode", "Luminous Energy Device"], "correctIndex": 2},
      {"question": "Phương pháp nào không dùng để tiệt trùng thực phẩm?", "answers": ["Pasteur hóa", "Tiệt trùng UHT", "Đông lạnh", "Chiếu xạ"], "correctIndex": 2},
      {"question": "Ngày Trái Đất (Earth Day) được tổ chức vào ngày nào?", "answers": ["20/3", "22/4", "5/6", "16/9"], "correctIndex": 1},
      {"question": "Trò chơi video nào bán chạy nhất mọi thời đại?", "answers": ["GTA V", "Minecraft", "Tetris", "PUBG"], "correctIndex": 1},
      {"question": "Đơn vị đo lường pixel dùng cho gì?", "answers": ["Âm thanh", "Hình ảnh kỹ thuật số", "Dung lượng file", "Tốc độ mạng"], "correctIndex": 1},
      {"question": "Môn thể thao nào sử dụng vợt lớn nhất?", "answers": ["Cầu lông", "Squash", "Tennis", "Pickleball"], "correctIndex": 2},
      {"question": "Ai là tổng thống Mỹ đầu tiên?", "answers": ["John Adams", "Thomas Jefferson", "George Washington", "Benjamin Franklin"], "correctIndex": 2},
      {"question": "Chất liệu nào được dùng làm lốp xe đầu tiên?", "answers": ["Nhựa tổng hợp", "Cao su tự nhiên", "Vải bố", "Kim loại"], "correctIndex": 1},
    ],

    // MÀN 25
    [
      {"question": "Bảng tuần hoàn được sắp xếp theo tiêu chí nào?", "answers": ["Khối lượng nguyên tử", "Số proton (số hiệu nguyên tử)", "Số neutron", "Số electron"], "correctIndex": 1},
      {"question": "Cơ quan nào trong cơ thể sản xuất mật?", "answers": ["Dạ dày", "Tụy", "Gan", "Thận"], "correctIndex": 2},
      {"question": "Tàu Titanic chìm năm nào?", "answers": ["1910", "1911", "1912", "1913"], "correctIndex": 2},
      {"question": "Người đầu tiên bay vào vũ trụ là ai?", "answers": ["Neil Armstrong", "Buzz Aldrin", "Alan Shepard", "Yuri Gagarin"], "correctIndex": 3},
      {"question": "Hội chứng Down do nguyên nhân gì?", "answers": ["Đột biến gen", "Thừa 1 nhiễm sắc thể số 21", "Thiếu vitamin", "Di truyền lặn"], "correctIndex": 1},
      {"question": "Giá trị e (số Euler) xấp xỉ bằng bao nhiêu?", "answers": ["1,618", "2,718", "3,141", "1,414"], "correctIndex": 1},
      {"question": "Hiện tượng quang điện do ai giải thích đầu tiên?", "answers": ["Newton", "Maxwell", "Planck", "Einstein"], "correctIndex": 3},
      {"question": "Virus máy tính đầu tiên tên là gì?", "answers": ["ILOVEYOU", "Creeper", "Melissa", "WannaCry"], "correctIndex": 1},
      {"question": "Định lý Pythagoras áp dụng cho loại tam giác nào?", "answers": ["Tam giác đều", "Tam giác cân", "Tam giác vuông", "Tam giác tù"], "correctIndex": 2},
      {"question": "Giải vô địch bóng đá châu Âu (UEFA Euro) diễn ra mấy năm một lần?", "answers": ["2 năm", "3 năm", "4 năm", "5 năm"], "correctIndex": 2},
      {"question": "Điểm nào trong hệ tọa độ được gọi là 'gốc tọa độ'?", "answers": ["(1, 1)", "(0, 0)", "(-1, -1)", "Điểm bất kỳ"], "correctIndex": 1},
      {"question": "Hệ thập lục phân (hexadecimal) dùng bao nhiêu ký tự?", "answers": ["8", "10", "16", "32"], "correctIndex": 2},
      {"question": "Nhiệt độ tuyệt đối được đo bằng đơn vị gì?", "answers": ["Celsius", "Fahrenheit", "Kelvin", "Rankine"], "correctIndex": 2},
      {"question": "Trong quang học, màu nào có bước sóng dài nhất?", "answers": ["Tím", "Xanh lam", "Vàng", "Đỏ"], "correctIndex": 3},
      {"question": "Đơn vị đo áp suất là gì?", "answers": ["Newton", "Pascal", "Joule", "Watt"], "correctIndex": 1},
    ],

    // MÀN 26
    [
      {"question": "Phương trình nổi tiếng E = mc² là của ai?", "answers": ["Newton", "Bohr", "Einstein", "Planck"], "correctIndex": 2},
      {"question": "Vắc-xin đầu tiên trên thế giới được phát triển cho bệnh gì?", "answers": ["Bại liệt", "Dịch hạch", "Đậu mùa", "Bệnh dại"], "correctIndex": 2},
      {"question": "Đại học nào lâu đời nhất thế giới?", "answers": ["Oxford", "Cambridge", "Bologna", "Harvard"], "correctIndex": 2},
      {"question": "Ngôn ngữ HTML được viết bởi ai?", "answers": ["Bill Gates", "Steve Jobs", "Tim Berners-Lee", "Larry Page"], "correctIndex": 2},
      {"question": "Hệ mặt trời nằm trong thiên hà nào?", "answers": ["Andromeda", "Milky Way", "Triangulum", "Centaurus A"], "correctIndex": 1},
      {"question": "Phương pháp khoa học bao gồm bước nào đầu tiên?", "answers": ["Giả thuyết", "Thí nghiệm", "Quan sát", "Kết luận"], "correctIndex": 2},
      {"question": "Năng lượng hạt nhân khai thác từ loại phản ứng nào trong lò phản ứng?", "answers": ["Fusion", "Fission", "Combustion", "Oxidation"], "correctIndex": 1},
      {"question": "Hormone nào gọi là 'hormone hạnh phúc'?", "answers": ["Adrenaline", "Cortisol", "Serotonin", "Insulin"], "correctIndex": 2},
      {"question": "Hội chứng hội thảo Zoom (Zoom fatigue) mô tả điều gì?", "answers": ["Nghiện công nghệ", "Mệt mỏi do họp video quá nhiều", "Mất ngủ do màn hình", "Lo âu về công nghệ"], "correctIndex": 1},
      {"question": "Nguyên lý bất định Heisenberg nói về điều gì?", "answers": ["Không thể đo chính xác cả vị trí và động lượng hạt", "Năng lượng không bảo toàn", "Ánh sáng có lưỡng tính", "Hạt nhân không ổn định"], "correctIndex": 0},
      {"question": "Kính hiển vi điện tử có độ phóng đại cao hơn kính quang học bao nhiêu lần?", "answers": ["10 lần", "100 lần", "1000 lần", "Hơn 1000 lần"], "correctIndex": 3},
      {"question": "Tốc độ âm thanh trong không khí xấp xỉ bao nhiêu m/s?", "answers": ["240 m/s", "340 m/s", "440 m/s", "540 m/s"], "correctIndex": 1},
      {"question": "Insulin lần đầu được chiết xuất từ tuyến tụy của loài vật nào?", "answers": ["Bò", "Lợn", "Chó", "Cừu"], "correctIndex": 2},
      {"question": "Hiệu ứng quang hợp đo bằng đơn vị nào?", "answers": ["Joule", "Lux", "Mol CO₂/m²/s", "Kelvin"], "correctIndex": 2},
      {"question": "Số Avogadro (6,022 × 10²³) dùng để đo gì?", "answers": ["Số nguyên tử trong 1 mol", "Tốc độ ánh sáng", "Khối lượng mol", "Điện tích electron"], "correctIndex": 0},
    ],

    // MÀN 27
    [
      {"question": "Trận đánh nào đánh dấu sự thất bại của Napoleon?", "answers": ["Trận Austerlitz", "Trận Waterloo", "Trận Leipzig", "Trận Borodino"], "correctIndex": 1},
      {"question": "Ai viết tác phẩm 'Tư bản luận' (Das Kapital)?", "answers": ["Lenin", "Engels", "Marx", "Trotsky"], "correctIndex": 2},
      {"question": "Phong trào đòi quyền bầu cử cho phụ nữ gọi là gì?", "answers": ["Feminism", "Suffragette", "Liberalism", "Abolitionism"], "correctIndex": 1},
      {"question": "Mao Trạch Đông thành lập nước Cộng hòa Nhân dân Trung Hoa năm nào?", "answers": ["1945", "1947", "1949", "1951"], "correctIndex": 2},
      {"question": "Bức tường Berlin dài bao nhiêu km?", "answers": ["75km", "100km", "155km", "200km"], "correctIndex": 2},
      {"question": "Ai là người đầu tiên đặt chân lên Nam Cực?", "answers": ["Robert Scott", "Roald Amundsen", "Ernest Shackleton", "Richard Byrd"], "correctIndex": 1},
      {"question": "Cuộc chiến tranh 100 năm diễn ra giữa hai quốc gia nào?", "answers": ["Anh - Đức", "Pháp - Tây Ban Nha", "Anh - Pháp", "Đức - Pháp"], "correctIndex": 2},
      {"question": "Ai sáng lập đạo Hồi (Islam)?", "answers": ["Ibrahim", "Moses", "Muhammad", "Jesus"], "correctIndex": 2},
      {"question": "Năm 1969 con người lần đầu đặt chân lên Mặt Trăng, sứ mệnh đó tên là gì?", "answers": ["Apollo 9", "Apollo 10", "Apollo 11", "Apollo 12"], "correctIndex": 2},
      {"question": "Chiến tranh Việt Nam - Mỹ chấm dứt năm nào?", "answers": ["1973", "1974", "1975", "1976"], "correctIndex": 2},
      {"question": "Đế quốc Ottoman tan rã năm nào?", "answers": ["1918", "1920", "1922", "1924"], "correctIndex": 2},
      {"question": "Ai là lãnh tụ độc lập đầu tiên của Ấn Độ?", "answers": ["Gandhi", "Nehru", "Jinnah", "Patel"], "correctIndex": 1},
      {"question": "Phong trào dân quyền Mỹ gắn liền với tên tuổi ai?", "answers": ["Malcolm X", "Martin Luther King Jr.", "Barack Obama", "Frederick Douglass"], "correctIndex": 1},
      {"question": "Hiệp ước Westphalia (1648) chấm dứt cuộc chiến nào?", "answers": ["Chiến tranh 100 năm", "Chiến tranh 30 năm", "Chiến tranh hoa hồng", "Thập tự chinh"], "correctIndex": 1},
      {"question": "Ai là Nữ hoàng Anh lâu năm nhất trong lịch sử?", "answers": ["Victoria", "Elizabeth I", "Elizabeth II", "Mary I"], "correctIndex": 2},
    ],

    // MÀN 28
    [
      {"question": "Nguyên lý nào trong đạo đức học: 'Hãy làm điều tốt nhất cho nhiều người nhất'?", "answers": ["Deontology", "Utilitarianism", "Virtue ethics", "Contractualism"], "correctIndex": 1},
      {"question": "Phép biện chứng duy vật gắn với triết học của ai?", "answers": ["Kant", "Hegel", "Marx", "Engels"], "correctIndex": 2},
      {"question": "Trường phái triết học nào cho rằng 'không có gì là chắc chắn'?", "answers": ["Dogmatism", "Rationalism", "Skepticism", "Empiricism"], "correctIndex": 2},
      {"question": "Khái niệm 'Ý chí quyền năng' (Will to Power) của ai?", "answers": ["Nietzsche", "Schopenhauer", "Kierkegaard", "Heidegger"], "correctIndex": 0},
      {"question": "Thuật ngữ 'Tabula Rasa' (tờ giấy trắng) trong triết học nghĩa là?", "answers": ["Con người sinh ra đã có kiến thức bẩm sinh", "Tâm trí con người lúc sinh là trống rỗng", "Không ai có thể học được", "Kiến thức là bẩm sinh"], "correctIndex": 1},
      {"question": "Ai là người đề xuất phương pháp khoa học thực nghiệm?", "answers": ["Descartes", "Francis Bacon", "Hume", "Locke"], "correctIndex": 1},
      {"question": "Trường phái 'Pragmatism' (thực dụng luận) phát triển mạnh ở đâu?", "answers": ["Đức", "Anh", "Pháp", "Mỹ"], "correctIndex": 3},
      {"question": "Luân lý học Kant đặt trung tâm ở khái niệm nào?", "answers": ["Hậu quả hành động", "Quy tắc tuyệt đối (Categorical Imperative)", "Cảm xúc con người", "Lợi ích xã hội"], "correctIndex": 1},
      {"question": "Plato sáng lập trường triết học tên là gì?", "answers": ["Lyceum", "Academy", "Stoa", "Garden"], "correctIndex": 1},
      {"question": "Aristotle phân loại chính phủ thành bao nhiêu loại chính?", "answers": ["3", "4", "5", "6"], "correctIndex": 3},
      {"question": "Tư tưởng 'Đạo' trong triết học Trung Hoa gắn với học phái nào?", "answers": ["Nho giáo", "Phật giáo", "Đạo giáo", "Mặc gia"], "correctIndex": 2},
      {"question": "Hiện tượng học (Phenomenology) do ai sáng lập?", "answers": ["Heidegger", "Husserl", "Merleau-Ponty", "Sartre"], "correctIndex": 1},
      {"question": "Thuyết 'Nhận thức luận' (Epistemology) nghiên cứu gì?", "answers": ["Bản chất tồn tại", "Nguồn gốc và giới hạn kiến thức", "Đạo đức hành vi", "Thẩm mỹ nghệ thuật"], "correctIndex": 1},
      {"question": "Khái niệm 'Siêu nhân' (Übermensch) của Nietzsche nghĩa là?", "answers": ["Người có sức mạnh vật lý vượt trội", "Người vượt qua đạo đức thông thường và tự sáng tạo giá trị", "Nhân vật siêu anh hùng", "Người cai trị xã hội"], "correctIndex": 1},
      {"question": "Triết học Tao Te Ching (Đạo Đức Kinh) do ai viết?", "answers": ["Khổng Tử", "Trang Tử", "Lão Tử", "Mạnh Tử"], "correctIndex": 2},
    ],

    // MÀN 29
    [
      {"question": "Số bước sóng của màu xanh lam trong quang phổ là khoảng bao nhiêu nm?", "answers": ["380-450nm", "450-500nm", "500-550nm", "550-600nm"], "correctIndex": 1},
      {"question": "Trong lập trình, 'recursion' (đệ quy) là gì?", "answers": ["Vòng lặp thông thường", "Hàm tự gọi chính nó", "Điều kiện if-else", "Mảng nhiều chiều"], "correctIndex": 1},
      {"question": "Chuỗi polyme DNA gồm các đơn vị cơ bản là gì?", "answers": ["Amino acid", "Nucleotide", "Monosaccharide", "Fatty acid"], "correctIndex": 1},
      {"question": "Trong kinh tế học, 'Invisible Hand' (Bàn tay vô hình) là khái niệm của ai?", "answers": ["Keynes", "Marx", "Adam Smith", "Friedman"], "correctIndex": 2},
      {"question": "Phản ứng hạt nhân tổng hợp (Nuclear fusion) xảy ra ở đâu trong tự nhiên?", "answers": ["Lõi Trái Đất", "Trong lòng các ngôi sao", "Khí quyển hành tinh", "Đại dương sâu"], "correctIndex": 1},
      {"question": "Đơn vị SI của năng lượng là gì?", "answers": ["Watt", "Newton", "Joule", "Pascal"], "correctIndex": 2},
      {"question": "Hiệu ứng nào giải thích tại sao bầu trời màu xanh?", "answers": ["Hiệu ứng Doppler", "Tán xạ Rayleigh", "Khúc xạ ánh sáng", "Phản xạ toàn phần"], "correctIndex": 1},
      {"question": "Trong cơ học lượng tử, 'superposition' nghĩa là?", "answers": ["Hạt đứng yên", "Hạt có thể ở nhiều trạng thái cùng lúc", "Hạt di chuyển nhanh hơn ánh sáng", "Hai hạt cùng vị trí"], "correctIndex": 1},
      {"question": "Loài nào được xem là tổ tiên tiến hóa của loài người?", "answers": ["Homo habilis", "Homo heidelbergensis", "Homo erectus", "Homo sapiens archaic"], "correctIndex": 0},
      {"question": "CRISPR là công nghệ ứng dụng trong lĩnh vực nào?", "answers": ["Năng lượng", "Chỉnh sửa gen", "Trí tuệ nhân tạo", "Vật liệu mới"], "correctIndex": 1},
      {"question": "Máy tính lượng tử (Quantum computer) sử dụng đơn vị tính toán là gì?", "answers": ["Bit", "Qubit", "Nibble", "Byte"], "correctIndex": 1},
      {"question": "Trong hóa học hữu cơ, liên kết đôi C=C gọi là loại liên kết gì?", "answers": ["Đơn", "Đôi", "Ba", "Ion"], "correctIndex": 1},
      {"question": "Hiện tượng 'entanglement' lượng tử mô tả gì?", "answers": ["Hạt bị mắc kẹt", "Hai hạt tương quan tức thời dù cách xa nhau", "Sóng và hạt giao thoa", "Hạt biến mất"], "correctIndex": 1},
      {"question": "Đơn vị đo lường góc trong hệ radian, 360° bằng bao nhiêu radian?", "answers": ["π", "2π", "3π", "4π"], "correctIndex": 1},
      {"question": "Hiệu suất (efficiency) tối đa của động cơ nhiệt lý tưởng được giới hạn bởi chu trình nào?", "answers": ["Chu trình Otto", "Chu trình Diesel", "Chu trình Carnot", "Chu trình Rankine"], "correctIndex": 2},
    ],

    // MÀN 30 — Câu hỏi khó nhất
    [
      {"question": "Paradox nào mô tả: 'Con mèo vừa sống vừa chết đồng thời'?", "answers": ["Paradox Zeno", "Con mèo Schrödinger", "Nghịch lý sinh đôi", "Nghịch lý EPR"], "correctIndex": 1},
      {"question": "Ai đã chứng minh Định lý Fermat cuối cùng (Fermat's Last Theorem)?", "answers": ["Andrew Wiles", "Pierre de Fermat", "Carl Gauss", "Leonard Euler"], "correctIndex": 0},
      {"question": "Nguyên lý nhân quả (causality) trong vật lý nói rằng?", "answers": ["Nguyên nhân xảy ra sau hệ quả", "Nguyên nhân xảy ra trước hoặc đồng thời hệ quả", "Nguyên nhân và hệ quả độc lập nhau", "Không tồn tại mối quan hệ nhân quả"], "correctIndex": 1},
      {"question": "Nhánh toán học nào nghiên cứu tính chất không thay đổi khi biến dạng liên tục?", "answers": ["Đại số", "Hình học vi phân", "Tô-pô học (Topology)", "Giải tích"], "correctIndex": 2},
      {"question": "Giả thuyết Riemann liên quan đến phân bố của gì?", "answers": ["Số nguyên tố", "Số vô tỉ", "Số phức", "Số Fibonacci"], "correctIndex": 0},
      {"question": "Trong lý thuyết thông tin, 'entropy' của Shannon đo lường gì?", "answers": ["Nhiệt độ hệ thống", "Độ bất định của thông tin", "Tốc độ truyền dữ liệu", "Kích thước file"], "correctIndex": 1},
      {"question": "Bộ não người có khoảng bao nhiêu tế bào thần kinh?", "answers": ["1 tỷ", "86 tỷ", "100 tỷ", "1 nghìn tỷ"], "correctIndex": 1},
      {"question": "Định lý bất toàn của Gödel phát biểu gì?", "answers": ["Toán học có thể tự chứng minh hoàn toàn", "Mọi hệ thống hình thức đủ mạnh đều có phát biểu không thể chứng minh hay bác bỏ", "Tất cả bài toán đều có nghiệm", "Logic học là nền tảng của toán học"], "correctIndex": 1},
      {"question": "Trong AI, 'Transformer architecture' lần đầu được giới thiệu trong bài báo nào?", "answers": ["Deep Learning", "Attention Is All You Need", "ImageNet Classification", "Playing Atari with Deep RL"], "correctIndex": 1},
      {"question": "Năng lượng tối (Dark Energy) chiếm khoảng bao nhiêu % vũ trụ?", "answers": ["27%", "48%", "68%", "85%"], "correctIndex": 2},
      {"question": "Hiệu ứng 'Butterfly Effect' là khái niệm trong lý thuyết nào?", "answers": ["Cơ học lượng tử", "Lý thuyết hỗn loạn (Chaos Theory)", "Thuyết tương đối", "Nhiệt động lực học"], "correctIndex": 1},
      {"question": "Mã di truyền (genetic code) mã hóa thông tin từ DNA sang protein qua bao nhiêu codon?", "answers": ["20", "32", "64", "128"], "correctIndex": 2},
      {"question": "Bài toán 'P vs NP' là một trong bao nhiêu bài toán thiên niên kỷ?", "answers": ["5", "7", "9", "10"], "correctIndex": 1},
      {"question": "Siêu dẫn (Superconductivity) xảy ra khi nhiệt độ vật liệu đạt đến trạng thái gì?", "answers": ["Nhiệt độ cao bất thường", "Gần 0 Kelvin (cực lạnh)", "Điểm nóng chảy", "Nhiệt độ phòng"], "correctIndex": 1},
      {"question": "Công thức nổi tiếng nhất của Euler: e^(iπ) + 1 = 0 kết hợp bao nhiêu hằng số toán học?", "answers": ["3", "4", "5", "6"], "correctIndex": 2},
    ],
  ];
}
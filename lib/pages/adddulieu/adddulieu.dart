import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDataSetup {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final Random _random = Random();

  static Map<String, dynamic> randomizeQuestion(Map<String, dynamic> q) {
    List<String> answers = List<String>.from(q["answers"]);
    int correctIndex = q["correctIndex"];

    String correctAnswer = answers[correctIndex];

    // 👉 đảo đáp án
    answers.shuffle(_random);

    // 👉 tìm lại vị trí đúng mới
    int newCorrectIndex = answers.indexOf(correctAnswer);

    return {
      "question": q["question"],
      "answers": answers,
      "correctIndex": newCorrectIndex,
    };
  }

  static Future<void> setup() async {
    try {
      print("🔥 Setup Môn Học");

      final categoryRef = firestore.collection("categories").doc("monan");

      List<Map<String, dynamic>> quizQuestions = [
        {
          "question": "Bún sứa là món ăn đặc trưng của vùng nào?",
          "answers": ["Nha Trang", "Phan Thiết", "Phú Quốc", "Bình Dương"],
          "correctIndex": 0,
        },
        {
          "question": "Thành phố cảng Hải Phòng nổi tiếng với món đặc sản nào?",
          "answers": ["Bún cá", "Phở gà", "Bánh đa cua", "Chả cá"],
          "correctIndex": 2,
        },
        {
          "question": "Bánh phu thê là đặc sản của vùng miền nào?",
          "answers": ["Hà Tĩnh", "Bắc Ninh", "Yên Bái", "Quảng Nam"],
          "correctIndex": 1,
        },
        {
          "question": "Lạng Sơn có món đặc sản trứ danh nào?",
          "answers": ["Thịt lợn rừng", "Lẩu mắm", "Vịt quay", "Phở chua"],
          "correctIndex": 2,
        },
        {
          "question": "Bánh tráng nướng gắn liền với tỉnh thành nào?",
          "answers": ["Bình Dương", "Đồng Nai", "Đà Lạt", "Tây Nguyên"],
          "correctIndex": 2,
        },
        {
          "question":
              "Nhắc tới bánh khọt, chúng ta nghĩ ngay tới địa danh nào?",
          "answers": ["Vũng Tàu", "Nha Trang", "Khánh Hòa", "Bình Thuận"],
          "correctIndex": 0,
        },
        {
          "question": "Đặc sản nổi bật nhất của Hà Giang là gì?",
          "answers": [
            "Thịt trâu gác bếp",
            "Thắng cố",
            "Phá lấu",
            "Bánh chưng đen",
          ],
          "correctIndex": 1,
        },
        {
          "question": "Chuột đồng là đặc sản phổ biến ở tỉnh thành nào?",
          "answers": ["An Giang", "Đồng Tháp", "Sa Đéc", "Hậu Giang"],
          "correctIndex": 1,
        },
        {
          "question": "Loại bánh nào là đặc sản nổi tiếng của Phú Thọ?",
          "answers": ["Bánh gai", "Bánh gối", "Bánh tai", "Bánh cuốn"],
          "correctIndex": 2,
        },
        {
          "question": "Bánh Pía là đặc sản của tỉnh nào?",
          "answers": ["An Giang", "Bạc Liêu", "Sóc Trăng", "Kiên Giang"],
          "correctIndex": 2,
        },
        {
          "question": "Cơm cháy có nguồn gốc từ vùng nào?",
          "answers": ["Cao Bằng", "Quảng Ninh", "Mộc Châu", "Ninh Bình"],
          "correctIndex": 3,
        },
        {
          "question": "Ninh Bình nổi tiếng với món thịt nào?",
          "answers": ["Thịt bê", "Thịt dê", "Thịt trâu", "Thịt lợn rừng"],
          "correctIndex": 1,
        },
        {
          "question": "Bún bò Huế là đặc sản nổi tiếng của tỉnh nào?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Bình", "Quảng Trị"],
          "correctIndex": 0,
        },
        {
          "question": "Món phở nổi tiếng có nguồn gốc từ đâu?",
          "answers": ["Hà Nội", "Nam Định", "Hải Phòng", "Hà Nam"],
          "correctIndex": 1,
        },
        {
          "question": "Bánh mì Hội An nổi tiếng thuộc tỉnh nào?",
          "answers": ["Quảng Nam", "Đà Nẵng", "Huế", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Cao lầu là đặc sản của vùng nào?",
          "answers": ["Hội An", "Huế", "Đà Nẵng", "Quảng Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh canh Trảng Bàng thuộc tỉnh nào?",
          "answers": ["Tây Ninh", "Long An", "Đồng Nai", "Bình Dương"],
          "correctIndex": 0,
        },
        {
          "question": "Gỏi cá Nam Ô là đặc sản của đâu?",
          "answers": ["Đà Nẵng", "Huế", "Quảng Nam", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Chả cá Lã Vọng nổi tiếng ở đâu?",
          "answers": ["Hà Nội", "Hải Phòng", "Nam Định", "Ninh Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bún mắm là đặc sản của miền nào?",
          "answers": ["Miền Tây", "Miền Trung", "Miền Bắc", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Nem chua Thanh Hóa là đặc sản của đâu?",
          "answers": ["Thanh Hóa", "Nghệ An", "Hà Tĩnh", "Ninh Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh đậu xanh nổi tiếng ở tỉnh nào?",
          "answers": ["Hải Dương", "Hà Nội", "Hưng Yên", "Nam Định"],
          "correctIndex": 0,
        },
        {
          "question": "Bún chả là món đặc sản nổi tiếng của đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Sài Gòn"],
          "correctIndex": 0,
        },
        {
          "question": "Hủ tiếu Mỹ Tho là đặc sản của tỉnh nào?",
          "answers": ["Tiền Giang", "Bến Tre", "Cần Thơ", "Vĩnh Long"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tét là món truyền thống của vùng nào?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Mắm tôm chua là đặc sản của đâu?",
          "answers": ["Huế", "Quảng Bình", "Đà Nẵng", "Nghệ An"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh hỏi lòng heo nổi tiếng ở đâu?",
          "answers": ["Bình Định", "Phú Yên", "Quảng Ngãi", "Gia Lai"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh căn là đặc sản của vùng nào?",
          "answers": ["Ninh Thuận", "Khánh Hòa", "Phú Yên", "Bình Thuận"],
          "correctIndex": 0,
        },
        {
          "question": "Món thắng dền là đặc sản của đâu?",
          "answers": ["Hà Giang", "Lào Cai", "Yên Bái", "Cao Bằng"],
          "correctIndex": 0,
        },
        {
          "question": "Cơm lam là món đặc sản của vùng nào?",
          "answers": ["Tây Nguyên", "Miền Bắc", "Miền Trung", "Miền Nam"],
          "correctIndex": 0,
        },
        {
          "question": "Gà nướng cơm lam nổi tiếng ở đâu?",
          "answers": ["Tây Nguyên", "Huế", "Đà Nẵng", "Quảng Nam"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh ướt lòng gà là đặc sản của đâu?",
          "answers": ["Đà Lạt", "Nha Trang", "Phan Thiết", "Huế"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh xèo miền Tây thường ăn kèm với gì?",
          "answers": ["Rau sống", "Bánh mì", "Cơm", "Bún"],
          "correctIndex": 0,
        },
        {
          "question": "Chè Huế nổi tiếng với loại chè nào?",
          "answers": ["Chè hẻm", "Chè đậu", "Chè sắn", "Chè sen"],
          "correctIndex": 0,
        },
        {
          "question": "Món lẩu mắm nổi tiếng ở đâu?",
          "answers": ["Miền Tây", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh cuốn Thanh Trì thuộc đâu?",
          "answers": ["Hà Nội", "Hà Nam", "Nam Định", "Ninh Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Chả ram tôm đất là đặc sản của đâu?",
          "answers": ["Bình Định", "Phú Yên", "Khánh Hòa", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh bột lọc là đặc sản của đâu?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Nam", "Quảng Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh gai là đặc sản của tỉnh nào?",
          "answers": ["Hải Dương", "Nam Định", "Hưng Yên", "Hà Nam"],
          "correctIndex": 1,
        },
        {
          "question": "Món cháo lươn nổi tiếng ở đâu?",
          "answers": ["Nghệ An", "Hà Tĩnh", "Thanh Hóa", "Quảng Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh đa nem thường dùng để làm gì?",
          "answers": ["Nem rán", "Bánh cuốn", "Bún", "Phở"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh bèo chén là đặc sản của đâu?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Nam", "Phú Yên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh trôi nước là món truyền thống dịp nào?",
          "answers": ["Tết Hàn Thực", "Tết Nguyên Đán", "Trung Thu", "Giỗ tổ"],
          "correctIndex": 0,
        },
        {
          "question": "Món bò kho thường ăn kèm với gì?",
          "answers": ["Bánh mì", "Cơm", "Bún", "Phở"],
          "correctIndex": 0,
        },
        {
          "question": "Chè bưởi là đặc sản của đâu?",
          "answers": ["Miền Tây", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh đúc nóng phổ biến ở đâu?",
          "answers": ["Miền Bắc", "Miền Nam", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh canh cua nổi tiếng ở đâu?",
          "answers": ["Sài Gòn", "Huế", "Đà Nẵng", "Quảng Nam"],
          "correctIndex": 0,
        },
        // ===== THÊM 60 CÂU MỚI =====
        {
          "question": "Bún thang là đặc sản nổi tiếng của đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Cần Thơ"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh gối là món ăn phổ biến ở đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Lạt", "Vũng Tàu"],
          "correctIndex": 0,
        },
        {
          "question": "Xôi xéo là món đặc sản của miền nào?",
          "answers": ["Miền Bắc", "Miền Trung", "Miền Nam", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh cuốn nóng thường ăn kèm với gì?",
          "answers": ["Chả lụa", "Thịt bò", "Hải sản", "Cá"],
          "correctIndex": 0,
        },
        {
          "question": "Miến lươn là đặc sản nổi tiếng ở đâu?",
          "answers": ["Nghệ An", "Huế", "Đà Nẵng", "Hà Nội"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh đa cá rô là món ăn của vùng nào?",
          "answers": ["Hải Dương", "Hà Nội", "Nam Định", "Thái Bình"],
          "correctIndex": 3,
        },
        {
          "question": "Bún đậu mắm tôm nổi tiếng ở đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Cần Thơ"],
          "correctIndex": 0,
        },
        {
          "question": "Bún cá rô đồng phổ biến ở miền nào?",
          "answers": ["Miền Bắc", "Miền Trung", "Miền Nam", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tôm Hồ Tây là đặc sản ở đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Hải Phòng"],
          "correctIndex": 0,
        },
        {
          "question": "Bún mọc là món ăn của vùng nào?",
          "answers": ["Miền Bắc", "Miền Trung", "Miền Nam", "Tây Nguyên"],
          "correctIndex": 0,
        },

        {
          "question": "Mì Quảng là đặc sản của tỉnh nào?",
          "answers": ["Quảng Nam", "Huế", "Đà Nẵng", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh đập là món ăn của đâu?",
          "answers": ["Quảng Nam", "Huế", "Đà Nẵng", "Phú Yên"],
          "correctIndex": 0,
        },
        {
          "question": "Bún hến là đặc sản của đâu?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Bình", "Quảng Trị"],
          "correctIndex": 0,
        },
        {
          "question": "Cơm hến nổi tiếng ở đâu?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Nam", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh nậm là đặc sản của đâu?",
          "answers": ["Huế", "Đà Nẵng", "Quảng Nam", "Quảng Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh ram ít là món ăn của đâu?",
          "answers": ["Huế", "Bình Định", "Quảng Nam", "Phú Yên"],
          "correctIndex": 1,
        },
        {
          "question": "Bún sứa ngoài Nha Trang còn phổ biến ở đâu?",
          "answers": ["Phú Yên", "Huế", "Đà Nẵng", "Quảng Bình"],
          "correctIndex": 0,
        },
        {
          "question": "Gỏi cá mai là đặc sản của đâu?",
          "answers": ["Phú Quốc", "Huế", "Đà Nẵng", "Quảng Nam"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh xèo miền Trung nhỏ hơn vì lý do gì?",
          "answers": ["Ít dầu", "Ít nhân", "Ăn kèm nhiều", "Tiết kiệm"],
          "correctIndex": 0,
        },
        {
          "question": "Bún chả cá là đặc sản của đâu?",
          "answers": ["Nha Trang", "Huế", "Hà Nội", "Cần Thơ"],
          "correctIndex": 0,
        },

        {
          "question": "Hủ tiếu Nam Vang phổ biến ở đâu?",
          "answers": ["Sài Gòn", "Huế", "Hà Nội", "Đà Nẵng"],
          "correctIndex": 0,
        },
        {
          "question": "Cơm tấm là đặc sản của đâu?",
          "answers": ["Sài Gòn", "Huế", "Hà Nội", "Đà Nẵng"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tráng trộn nổi tiếng ở đâu?",
          "answers": ["Sài Gòn", "Đà Lạt", "Nha Trang", "Huế"],
          "correctIndex": 0,
        },
        {
          "question": "Bò lá lốt thường ăn kèm với gì?",
          "answers": ["Bún", "Cơm", "Phở", "Bánh mì"],
          "correctIndex": 0,
        },
        {
          "question": "Canh chua cá là món ăn của miền nào?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Cá kho tộ là món phổ biến ở đâu?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh bò thốt nốt là đặc sản của đâu?",
          "answers": ["An Giang", "Cần Thơ", "Sóc Trăng", "Bạc Liêu"],
          "correctIndex": 0,
        },
        {
          "question": "Lẩu cá linh bông điên điển thuộc vùng nào?",
          "answers": ["Miền Tây", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Bún nước lèo là đặc sản của đâu?",
          "answers": ["Sóc Trăng", "Cần Thơ", "An Giang", "Bạc Liêu"],
          "correctIndex": 0,
        },
        {
          "question": "Cháo cá lóc phổ biến ở đâu?",
          "answers": ["Miền Tây", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },

        {
          "question": "Bánh cống là đặc sản của đâu?",
          "answers": ["Cần Thơ", "An Giang", "Sóc Trăng", "Bạc Liêu"],
          "correctIndex": 0,
        },
        {
          "question": "Nem nướng nổi tiếng ở đâu?",
          "answers": ["Nha Trang", "Huế", "Hà Nội", "Sài Gòn"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh hỏi thường ăn kèm với gì?",
          "answers": ["Thịt nướng", "Cá", "Hải sản", "Đậu"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh canh ghẹ nổi tiếng ở đâu?",
          "answers": ["Vũng Tàu", "Huế", "Đà Nẵng", "Quảng Nam"],
          "correctIndex": 0,
        },
        {
          "question": "Bún riêu cua có nguyên liệu chính là gì?",
          "answers": ["Cua đồng", "Cá", "Thịt bò", "Tôm"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh mì Việt Nam nổi tiếng nhờ điều gì?",
          "answers": ["Nhân đa dạng", "Giá rẻ", "Hình thức", "Kích thước"],
          "correctIndex": 0,
        },
        {
          "question": "Phở bò thường dùng loại nước dùng nào?",
          "answers": ["Hầm xương bò", "Hầm cá", "Hầm gà", "Nước lã"],
          "correctIndex": 0,
        },
        {
          "question": "Chè ba màu gồm những gì?",
          "answers": [
            "Đậu, thạch, nước cốt dừa",
            "Cơm, cá, thịt",
            "Bún, thịt",
            "Bánh",
          ],
          "correctIndex": 0,
        },
        {
          "question": "Bánh flan Việt Nam có nguồn gốc từ đâu?",
          "answers": ["Pháp", "Mỹ", "Nhật", "Hàn"],
          "correctIndex": 0,
        },
        {
          "question": "Cà phê sữa đá là đặc trưng của đâu?",
          "answers": ["Việt Nam", "Pháp", "Ý", "Mỹ"],
          "correctIndex": 0,
        },
        // ===== THÊM 30 CÂU MỚI =====
        {
          "question":
              "Bánh đa cua Hải Phòng có màu đặc trưng của bánh đa là gì?",
          "answers": ["Màu nâu đỏ", "Màu trắng", "Màu vàng", "Màu xanh"],
          "correctIndex": 0,
        },
        {
          "question": "Bún bò Huế thường có vị đặc trưng nào?",
          "answers": ["Cay và đậm đà", "Ngọt", "Chua", "Nhạt"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tráng cuốn thịt heo nổi tiếng ở đâu?",
          "answers": ["Đà Nẵng", "Huế", "Hà Nội", "Cần Thơ"],
          "correctIndex": 0,
        },
        {
          "question": "Cá kèo nướng muối ớt là món phổ biến ở đâu?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Món gỏi cuốn thường chấm với gì?",
          "answers": ["Tương đậu", "Nước mắm", "Muối", "Đường"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh bột chiên là món ăn đường phố nổi tiếng ở đâu?",
          "answers": ["Sài Gòn", "Hà Nội", "Huế", "Đà Nẵng"],
          "correctIndex": 0,
        },
        {
          "question": "Bún cá Nha Trang có đặc điểm gì nổi bật?",
          "answers": ["Chả cá", "Thịt bò", "Gà", "Tôm"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh ít lá gai là đặc sản của đâu?",
          "answers": ["Bình Định", "Huế", "Hà Nội", "Đà Nẵng"],
          "correctIndex": 0,
        },
        {
          "question": "Món phá lấu phổ biến ở đâu?",
          "answers": ["Sài Gòn", "Huế", "Hà Nội", "Đà Nẵng"],
          "correctIndex": 0,
        },
        {
          "question": "Bún cá Châu Đốc thuộc tỉnh nào?",
          "answers": ["An Giang", "Cần Thơ", "Bến Tre", "Sóc Trăng"],
          "correctIndex": 0,
        },

        {
          "question": "Bánh tai heo là đặc sản của đâu?",
          "answers": ["Phú Thọ", "Hà Nội", "Nam Định", "Hải Phòng"],
          "correctIndex": 0,
        },
        {
          "question": "Món nem lụi thường ăn kèm với gì?",
          "answers": ["Bánh tráng", "Cơm", "Bún khô", "Phở"],
          "correctIndex": 0,
        },
        {
          "question": "Bún chả cá Quy Nhơn thuộc tỉnh nào?",
          "answers": ["Bình Định", "Phú Yên", "Khánh Hòa", "Quảng Ngãi"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh canh bột gạo phổ biến ở miền nào?",
          "answers": ["Miền Trung", "Miền Bắc", "Miền Nam", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Món gà hấp lá chanh thường dùng loại gà nào?",
          "answers": ["Gà ta", "Gà công nghiệp", "Gà tây", "Gà rừng"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh mì chảo thường ăn kèm với gì?",
          "answers": ["Trứng và xúc xích", "Cá", "Bún", "Chè"],
          "correctIndex": 0,
        },
        {
          "question": "Bún ốc là món đặc sản của đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Sài Gòn"],
          "correctIndex": 0,
        },
        {
          "question": "Món vịt quay Lạng Sơn nổi tiếng nhờ gì?",
          "answers": ["Gia vị đặc trưng", "Giá rẻ", "Màu sắc", "Kích thước"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tráng phơi sương là đặc sản của đâu?",
          "answers": ["Tây Ninh", "Long An", "Đồng Nai", "Bình Dương"],
          "correctIndex": 0,
        },
        {
          "question": "Món lẩu gà lá é nổi tiếng ở đâu?",
          "answers": ["Phú Yên", "Huế", "Hà Nội", "Đà Nẵng"],
          "correctIndex": 0,
        },

        {
          "question": "Bún bò Nam Bộ có đặc điểm gì?",
          "answers": ["Không có nước dùng", "Có nhiều nước", "Rất cay", "Chua"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh hỏi cháo lòng là đặc sản của đâu?",
          "answers": ["Bình Định", "Huế", "Đà Nẵng", "Quảng Nam"],
          "correctIndex": 0,
        },
        {
          "question": "Món canh khổ qua nhồi thịt thường ăn vào dịp nào?",
          "answers": ["Tết", "Hè", "Thu", "Đông"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh mì kẹp thịt nướng thường dùng loại thịt nào?",
          "answers": ["Thịt heo", "Thịt bò", "Thịt gà", "Cá"],
          "correctIndex": 0,
        },
        {
          "question": "Món chả giò miền Nam thường có nhân gì?",
          "answers": ["Thịt và miến", "Cá", "Tôm", "Rau"],
          "correctIndex": 0,
        },
        {
          "question": "Bún măng vịt phổ biến ở đâu?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
        {
          "question": "Món bò né thường được phục vụ như thế nào?",
          "answers": ["Chảo nóng", "Đĩa lạnh", "Bát", "Hộp"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh cuốn Tây Hồ nổi tiếng ở đâu?",
          "answers": ["Hà Nội", "Huế", "Đà Nẵng", "Sài Gòn"],
          "correctIndex": 0,
        },
        {
          "question": "Món cơm gà Hội An có màu đặc trưng gì?",
          "answers": ["Vàng", "Đỏ", "Xanh", "Trắng"],
          "correctIndex": 0,
        },
        {
          "question": "Bánh tằm bì là đặc sản của đâu?",
          "answers": ["Miền Nam", "Miền Bắc", "Miền Trung", "Tây Nguyên"],
          "correctIndex": 0,
        },
      ];
      List<Map<String, dynamic>> finalQuestions =
          quizQuestions.map((q) => randomizeQuestion(q)).toList();

      // (tuỳ chọn) random luôn thứ tự câu hỏi
      finalQuestions.shuffle(_random);
      
      await categoryRef.set({
        "id": "monan",
        "name": "Món Ăn",
        "image": "https://res.cloudinary.com/dejxoaud5/image/upload/v1774685853/012pIkbEsTNPw_qqhv7q.png",
        "order": 7,
        "type": "direct", // 👈 giống domeo
        "questions": finalQuestions, // 👈 lưu trực tiếp ở đây
      });

      print("🎉 DONE Môn Học");
    } catch (e) {
      print("❌ Lỗi: $e");
    }
  }
}

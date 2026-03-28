import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDataSetup {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> setup() async {
    try {
      print("🔥 Setup Món Ăn");

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
      ];

      await categoryRef.set({
        "id": "monan",
        "name": "Món Ăn",
        "image": "assets/images/food.png",
        "order": 3,
        "type": "quiz", // 👈 giống domeo
        "questions": quizQuestions, // 👈 lưu trực tiếp ở đây
      });

      print("🎉 DONE Món Ăn");
    } catch (e) {
      print("❌ Lỗi: $e");
    }
  }
}

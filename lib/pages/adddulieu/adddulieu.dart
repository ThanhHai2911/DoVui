import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class VietnamLandmarkSetup {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String shuffleQuestion(String answer) {
    String noSpace = answer.replaceAll(" ", "");
    List<String> chars = noSpace.split("");
    chars.shuffle(Random());
    return chars.join(" ");
  }

  static Future<void> setupVietnamLandmarks() async {
    try {
      print("🔥 Setup danh lam thắng cảnh VN");

      final categoryRef =
          firestore.collection("categories").doc("danhlam");

      await categoryRef.set({
        "name": "Danh Lam Việt Nam",
        "image": "assets/images/vietnam.png",
        "type": "level",
        "order": 2,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final Map<String, List<Map<String, String>>> data = {

        /// MÀN 1
        "level1": [
          {"name": "Vịnh Hạ Long", "image": "https://i.imgur.com/YHh9Z6B.jpg"},
          {"name": "Chùa Một Cột", "image": "https://i.imgur.com/zG3X3sJ.jpg"},
          {"name": "Hồ Hoàn Kiếm", "image": "https://i.imgur.com/TY3zvYh.jpg"},
          {"name": "Phố Cổ Hội An", "image": "https://i.imgur.com/lYk8xZX.jpg"},
          {"name": "Cầu Rồng", "image": "https://i.imgur.com/EYq8RPH.jpg"},
          {"name": "Nhà Thờ Đức Bà", "image": "https://i.imgur.com/QkZKkYp.jpg"},
          {"name": "Chợ Bến Thành", "image": "https://i.imgur.com/1nC0tNf.jpg"},
          {"name": "Cố Đô Huế", "image": "https://i.imgur.com/NM9p9wQ.jpg"},
          {"name": "Hang Sơn Đoòng", "image": "https://i.imgur.com/7b7YkXB.jpg"},
          {"name": "Núi Bà Đen", "image": "https://i.imgur.com/LvSY2qQ.jpg"},
        ],

        /// MÀN 2
        "level2": [
          {"name": "Fansipan", "image": "https://i.imgur.com/YcQLwzL.jpg"},
          {"name": "Tam Cốc", "image": "https://i.imgur.com/GL6cwgm.jpg"},
          {"name": "Tràng An", "image": "https://i.imgur.com/JUO3N5e.jpg"},
          {"name": "Bà Nà Hills", "image": "https://i.imgur.com/fcKzZ9P.jpg"},
          {"name": "Cầu Vàng", "image": "https://i.imgur.com/AvzJdYc.jpg"},
          {"name": "Đèo Hải Vân", "image": "https://i.imgur.com/Y0dRkZy.jpg"},
          {"name": "Biển Mỹ Khê", "image": "https://i.imgur.com/2LJ2TqM.jpg"},
          {"name": "Đảo Phú Quốc", "image": "https://i.imgur.com/W6p8K7F.jpg"},
          {"name": "Thác Bản Giốc", "image": "https://i.imgur.com/yqzAJYF.jpg"},
          {"name": "Hồ Ba Bể", "image": "https://i.imgur.com/ywM2m4q.jpg"},
        ],

        /// MÀN 3
        "level3": [
          {"name": "Núi Ngũ Hành Sơn", "image": "https://i.imgur.com/Q2XjTRN.jpg"},
          {"name": "Đầm Lập An", "image": "https://i.imgur.com/BVtCk6g.jpg"},
          {"name": "Vịnh Lăng Cô", "image": "https://i.imgur.com/Gp3I9lG.jpg"},
          {"name": "Đồi Cát Mũi Né", "image": "https://i.imgur.com/yvWkj7c.jpg"},
          {"name": "Tháp Chàm", "image": "https://i.imgur.com/h0n8F6Z.jpg"},
          {"name": "Thung Lũng Tình Yêu", "image": "https://i.imgur.com/CPQ6W4M.jpg"},
          {"name": "Hồ Xuân Hương", "image": "https://i.imgur.com/LvVZ3fO.jpg"},
          {"name": "Langbiang", "image": "https://i.imgur.com/8P2YkGp.jpg"},
          {"name": "Thác Datanla", "image": "https://i.imgur.com/6Sm9X2t.jpg"},
          {"name": "Hồ Tuyền Lâm", "image": "https://i.imgur.com/0Yp6E0E.jpg"},
        ],

        /// MÀN 4
        "level4": [
          {"name": "Chùa Thiên Mụ", "image": "https://i.imgur.com/Kg2rYqF.jpg"},
          {"name": "Cầu Tràng Tiền", "image": "https://i.imgur.com/VK2Ue9o.jpg"},
          {"name": "Biển Nha Trang", "image": "https://i.imgur.com/MJq5cKk.jpg"},
          {"name": "Hòn Mun", "image": "https://i.imgur.com/X5AKM7p.jpg"},
          {"name": "Vinpearl", "image": "https://i.imgur.com/wnW0Z4f.jpg"},
          {"name": "Thác Pongour", "image": "https://i.imgur.com/5V0Zkcl.jpg"},
          {"name": "Hồ Lak", "image": "https://i.imgur.com/7j6KzDj.jpg"},
          {"name": "Nhà Rông", "image": "https://i.imgur.com/y1jvYpp.jpg"},
          {"name": "Biển Cửa Lò", "image": "https://i.imgur.com/pyj0M3q.jpg"},
          {"name": "Biển Sầm Sơn", "image": "https://i.imgur.com/2v7mA4Q.jpg"},
        ],


      };

      int manOrder = 1;

      for (var entry in data.entries) {
        String manId = entry.key;
        List<Map<String, String>> questions = entry.value;

        final manRef = categoryRef.collection("mans").doc(manId);

        await manRef.set({
          "name": "Màn $manOrder",
          "order": manOrder,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (int i = 0; i < questions.length; i++) {
          String answer = questions[i]["name"]!;
          String image = questions[i]["image"]!;

          await manRef.collection("questions").doc("question${i + 1}").set({
            "image": image,
            "question": shuffleQuestion(answer),
            "answers": [answer],
            "correctIndex": 0,
            "order": i + 1,
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }

        manOrder++;
      }

      print("🎉 Setup danh lam thắng cảnh hoàn tất");
    } catch (e) {
      print("❌ Lỗi setup: $e");
    }
  }
}
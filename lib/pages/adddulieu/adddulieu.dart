// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class GameDataSetup {
//   static final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // =============================
//   // Xáo trộn chữ (giữ dấu tiếng Việt)
//   // =============================
//   static String shuffleQuestion(String answer) {
//     String noSpace = answer.replaceAll(" ", "");
//     List<String> chars = noSpace.split("");
//     chars.shuffle(Random());
//     return chars.join(" ");
//   }

//   // =============================
//   // Setup toàn bộ dữ liệu
//   // =============================
//   static Future<void> setupGameData() async {
//     try {
//       print("🔥 Bắt đầu setup dữ liệu");

//       final categoryRef = firestore.collection("categories").doc("amnhac");

//       await categoryRef.set({
//         "name": "Âm Nhạc",
//         "image": "assets/images/nhac.png",
//         "type": "level",
//         "order": 1,
//         "updatedAt": FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       final Map<String, List<String>> allMans = {
//         "man1": [
//           "Người Ấy Là Ai",
//           "Em Của Quá Khứ",
//           "Cảm Ơn Vì Tất Cả",
//           "Yêu 5",
//           "Thiên Đàng Gọi Tên",
//           "Mưa Hồng",
//           "Hai Chữ Đã Từng",
//           "Bất Chấp",
//           "Anh Chưa Từng",
//           "Tình Đơn Phương",
//         ],
//         "man2": [
//           "Người Tình Mùa Đông",
//           "Như Những Phút Ban Đầu",
//           "Hạnh Phúc Mới",
//           "Cơn Mưa Tình Yêu",
//           "Mắt Nâu",
//           "Gặp Nhưng Không Ở Lại",
//           "Thương Anh Nhiều Hơn Nói",
//           "Mashup Yêu",
//           "Anh Ơi Tình Yêu Là Gì",
//           "Chờ Người",
//         ],
//         "man3": [
//           "Chúng Ta Của Hiện Tại",
//           "Bên Trên Tầng Lầu",
//           "Đừng Hỏi Em",
//           "Anh Ơi Ở Lại",
//           "Nếu Ngày Ấy",
//           "Giấc Mơ Trưa",
//           "Chạy Ngay Đi",
//           "Hãy Tin Anh",
//           "Anh Luôn Như Vậy",
//           "Mưa Trên Cuộc Tình",
//         ],
//         "man4": [
//           "Chúng Ta Không Thuộc Về Nhau",
//           "Tháng Tư Là Lời Nói Dối Của Em",
//           "Buồn Của Anh",
//           "Anh Nhớ Em",
//           "Mình Yêu Nhau Đi",
//           "Người Lạ Ơi",
//           "Em Gái Mưa",
//           "Tương Tư",
//           "Anh Sai Rồi",
//           "Vỡ Nguồn",
//         ],
//         "man5": [
//           "Anh Thanh Niên",
//           "Năm Ấy Con Sẽ Khác",
//           "Em Của Ngày Hôm Qua",
//           "Lạc Trôi",
//           "Sóng Gió",
//           "Hãy Trao Cho Anh",
//           "Cơn Mưa Ngang Qua",
//           "Yêu Thương Anh",
//           "Hoang Mang",
//           "Mơ Hồ",
//         ],
//       };

//       int manOrder = 1;

//       // =============================
//       // TẠO TỪNG MÀN
//       // =============================
//       for (var entry in allMans.entries) {
//         String manId = entry.key;
//         List<String> questionList = entry.value;

//         print("👉 Đang tạo $manId");

//         final manRef = categoryRef.collection("mans").doc(manId);

//         await manRef.set({
//           "name": "Màn $manOrder",
//           "order": manOrder,
//           "updatedAt": FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         // =============================
//         // TẠO CÂU HỎI
//         // =============================
//         for (int i = 0; i < questionList.length; i++) {
//           String correctAnswer = questionList[i];
//           String shuffled = shuffleQuestion(correctAnswer);

//           await manRef.collection("questions").doc("question${i + 1}").set({
//             "originalName": correctAnswer,
//             "question": shuffled, // 👈 chỉ lưu chữ xáo trộn
//             "answers": [correctAnswer],
//             "correctIndex": 0,
//             "order": i + 1,
//             "updatedAt": FieldValue.serverTimestamp(),
//           }, SetOptions(merge: true));

//           print("   ✅ question${i + 1}");
//         }

//         manOrder++;
//       }

//       print("🎉 Hoàn tất cập nhật dữ liệu");
//     } catch (e) {
//       print("❌ LỖI setupGameData: $e");
//     }
//   }
// }

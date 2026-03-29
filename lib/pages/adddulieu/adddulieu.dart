import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Setup màn 5 → 50 với 3 chủ đề xen kẽ:
/// 🏞️ Danh lam thắng cảnh  (màn lẻ: 5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50)
/// 🍜 Ẩm thực Việt Nam      (màn chẵn: 6,9,12,15,18,21,24,27,30,33,36,39,42,45,48)
/// 🏳️ Quốc kỳ các nước      (màn: 7,10,13,16,19,22,25,28,31,34,37,40,43,46,49)

class VietnamMixedSetup {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String shuffleQuestion(String answer) {
    String noSpace = answer.replaceAll(" ", "");
    List<String> chars = noSpace.split("");
    chars.shuffle(Random());
    return chars.join(" ");
  }

  static String img(String name) =>
      "https://res.cloudinary.com/dejxoaud5/image/upload/$name.jpg";

  static Future<void> setupLevels5to50() async {
    try {
      print("🔥 Bắt đầu setup màn 5 → 50 (mix 3 chủ đề)");

      final categoryRef = firestore.collection("categories").doc("tonghop");

      final Map<String, List<Map<String, String>>> data = {

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 5 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_1": [
          {"name": "Đảo Cô Tô",              "image": img("dao_co_to")},
          {"name": "Vũng Tàu",               "image": img("vung_tau")},
          {"name": "Mũi Né",                 "image": img("mui_ne")},
          {"name": "Đà Lạt",                 "image": img("da_lat")},
          {"name": "Sa Pa",                  "image": img("sa_pa")},
          {"name": "Hà Giang",               "image": img("ha_giang")},
          {"name": "Cao Bằng",               "image": img("cao_bang")},
          {"name": "Mộc Châu",               "image": img("moc_chau")},
          {"name": "Điện Biên Phủ",          "image": img("dien_bien_phu")},
          {"name": "Đảo Cát Bà",             "image": img("dao_cat_ba")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 6 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_2": [
          {"name": "Phở Bò",                 "image": img("pho_bo")},
          {"name": "Bánh Mì",                "image": img("banh_mi")},
          {"name": "Bún Bò Huế",             "image": img("bun_bo_hue")},
          {"name": "Cơm Tấm",                "image": img("com_tam")},
          {"name": "Bánh Xèo",               "image": img("banh_xeo")},
          {"name": "Gỏi Cuốn",               "image": img("goi_cuon")},
          {"name": "Chả Giò",                "image": img("cha_gio")},
          {"name": "Bún Chả",                "image": img("bun_cha")},
          {"name": "Mì Quảng",               "image": img("mi_quang")},
          {"name": "Cao Lầu",                "image": img("cao_lau")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 7 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_3": [
          {"name": "Việt Nam",               "image": img("flag_vietnam")},
          {"name": "Nhật Bản",               "image": img("flag_japan")},
          {"name": "Hàn Quốc",               "image": img("flag_korea")},
          {"name": "Trung Quốc",             "image": img("flag_china")},
          {"name": "Mỹ",                     "image": img("flag_usa")},
          {"name": "Anh",                    "image": img("flag_uk")},
          {"name": "Pháp",                   "image": img("flag_france")},
          {"name": "Đức",                    "image": img("flag_germany")},
          {"name": "Ý",                      "image": img("flag_italy")},
          {"name": "Tây Ban Nha",            "image": img("flag_spain")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 8 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_4": [
          {"name": "Chùa Bái Đính",          "image": img("chua_bai_dinh")},
          {"name": "Động Phong Nha",         "image": img("dong_phong_nha")},
          {"name": "Đèo Mã Pí Lèng",        "image": img("deo_ma_pi_leng")},
          {"name": "Ruộng Bậc Thang Mù Cang Chải", "image": img("ruong_bac_thang")},
          {"name": "Yên Tử",                 "image": img("yen_tu")},
          {"name": "Tam Đảo",                "image": img("tam_dao")},
          {"name": "Chùa Hương",             "image": img("chua_huong")},
          {"name": "Đền Hùng",               "image": img("den_hung")},
          {"name": "Hồ Tây",                 "image": img("ho_tay")},
          {"name": "Vườn Quốc Gia Cúc Phương", "image": img("vuon_cuc_phuong")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 9 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_5": [
          {"name": "Bánh Cuốn",              "image": img("banh_cuon")},
          {"name": "Chè Ba Màu",             "image": img("che_ba_mau")},
          {"name": "Bún Riêu",               "image": img("bun_rieu")},
          {"name": "Hủ Tiếu",                "image": img("hu_tieu")},
          {"name": "Lẩu Thái",               "image": img("lau_thai")},
          {"name": "Bún Đậu Mắm Tôm",       "image": img("bun_dau_mam_tom")},
          {"name": "Nem Cuốn",               "image": img("nem_cuon")},
          {"name": "Bánh Căn",               "image": img("banh_can")},
          {"name": "Cháo Lòng",              "image": img("chao_long")},
          {"name": "Xôi Gấc",               "image": img("xoi_gac")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 10 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_6": [
          {"name": "Úc",                     "image": img("flag_australia")},
          {"name": "Canada",                 "image": img("flag_canada")},
          {"name": "Brazil",                 "image": img("flag_brazil")},
          {"name": "Argentina",              "image": img("flag_argentina")},
          {"name": "Bồ Đào Nha",            "image": img("flag_portugal")},
          {"name": "Hà Lan",                "image": img("flag_netherlands")},
          {"name": "Bỉ",                    "image": img("flag_belgium")},
          {"name": "Thụy Sĩ",              "image": img("flag_switzerland")},
          {"name": "Thụy Điển",            "image": img("flag_sweden")},
          {"name": "Na Uy",                "image": img("flag_norway")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 11 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_7": [
          {"name": "Thành Cổ Quảng Trị",    "image": img("thanh_co_quang_tri")},
          {"name": "Đảo Lý Sơn",            "image": img("dao_ly_son")},
          {"name": "Mỹ Sơn",                "image": img("my_son")},
          {"name": "Phố Cổ Đồng Văn",      "image": img("pho_co_dong_van")},
          {"name": "Cột Cờ Lũng Cú",       "image": img("cot_co_lung_cu")},
          {"name": "Tháp Bà Ponagar",       "image": img("thap_ba_ponagar")},
          {"name": "Biển Long Hải",         "image": img("bien_long_hai")},
          {"name": "Hồ Trị An",             "image": img("ho_tri_an")},
          {"name": "Vịnh Vĩnh Hy",          "image": img("vinh_vinh_hy")},
          {"name": "Chợ Nổi Cái Răng",     "image": img("cho_noi_cai_rang")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 12 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_8": [
          {"name": "Bánh Bèo",              "image": img("banh_beo")},
          {"name": "Bánh Nậm",             "image": img("banh_nam")},
          {"name": "Bánh Lọc",            "image": img("banh_loc")},
          {"name": "Bánh Ướt",            "image": img("banh_uot")},
          {"name": "Cơm Hến",            "image": img("com_hen")},
          {"name": "Bún Thịt Nướng",    "image": img("bun_thit_nuong")},
          {"name": "Phở Gà",            "image": img("pho_ga")},
          {"name": "Bánh Tráng Trộn",  "image": img("banh_trang_tron")},
          {"name": "Bột Chiên",        "image": img("bot_chien")},
          {"name": "Bánh Flan",        "image": img("banh_flan")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 13 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_9": [
          {"name": "Thái Lan",              "image": img("flag_thailand")},
          {"name": "Indonesia",             "image": img("flag_indonesia")},
          {"name": "Malaysia",              "image": img("flag_malaysia")},
          {"name": "Philippines",           "image": img("flag_philippines")},
          {"name": "Singapore",             "image": img("flag_singapore")},
          {"name": "Myanmar",               "image": img("flag_myanmar")},
          {"name": "Campuchia",             "image": img("flag_cambodia")},
          {"name": "Lào",                   "image": img("flag_laos")},
          {"name": "Brunei",                "image": img("flag_brunei")},
          {"name": "Đông Timor",            "image": img("flag_east_timor")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 14 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_10": [
          {"name": "Cù Lao Chàm",           "image": img("cu_lao_cham")},
          {"name": "Bán Đảo Sơn Trà",       "image": img("ban_dao_son_tra")},
          {"name": "Ngũ Hành Sơn",          "image": img("ngu_hanh_son")},
          {"name": "Cầu Vàng Đà Nẵng",      "image": img("cau_vang_da_nang")},
          {"name": "Bà Nà Hills",            "image": img("ba_na_hills")},
          {"name": "Biển Mỹ Khê",           "image": img("bien_my_khe")},
          {"name": "Cầu Sông Hàn",          "image": img("cau_song_han")},
          {"name": "Đảo Lý Sơn Quảng Ngãi", "image": img("dao_ly_son_quang_ngai")},
          {"name": "Gành Đá Đĩa",           "image": img("ganh_da_dia")},
          {"name": "Mũi Điện Phú Yên",      "image": img("mui_dien_phu_yen")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 15 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_11": [
          {"name": "Bánh Chưng",            "image": img("banh_chung")},
          {"name": "Bánh Giầy",             "image": img("banh_giay")},
          {"name": "Bánh Tét",              "image": img("banh_tet")},
          {"name": "Xôi Lá Cẩm",           "image": img("xoi_la_cam")},
          {"name": "Chè Bà Ba",             "image": img("che_ba_ba")},
          {"name": "Bánh Pía",              "image": img("banh_pia")},
          {"name": "Bánh Bò",               "image": img("banh_bo")},
          {"name": "Bánh In",               "image": img("banh_in")},
          {"name": "Mứt Dừa",               "image": img("mut_dua")},
          {"name": "Kẹo Dừa",               "image": img("keo_dua")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 16 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_12": [
          {"name": "Nga",                   "image": img("flag_russia")},
          {"name": "Ukraine",               "image": img("flag_ukraine")},
          {"name": "Ba Lan",                "image": img("flag_poland")},
          {"name": "Hy Lạp",               "image": img("flag_greece")},
          {"name": "Thổ Nhĩ Kỳ",          "image": img("flag_turkey")},
          {"name": "Ả Rập Xê Út",         "image": img("flag_saudi_arabia")},
          {"name": "Israel",               "image": img("flag_israel")},
          {"name": "Iran",                 "image": img("flag_iran")},
          {"name": "Ấn Độ",               "image": img("flag_india")},
          {"name": "Pakistan",             "image": img("flag_pakistan")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 17 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_13": [
          {"name": "Lăng Khải Định",        "image": img("lang_khai_dinh")},
          {"name": "Lăng Minh Mạng",        "image": img("lang_minh_mang")},
          {"name": "Lăng Tự Đức",           "image": img("lang_tu_duc")},
          {"name": "Đại Nội Huế",           "image": img("dai_noi_hue")},
          {"name": "Chùa Thiên Mụ",         "image": img("chua_thien_mu")},
          {"name": "Sông Hương",            "image": img("song_huong")},
          {"name": "Phá Tam Giang",         "image": img("pha_tam_giang")},
          {"name": "Cầu Hiền Lương",        "image": img("cau_hien_luong")},
          {"name": "Động Thiên Đường",      "image": img("dong_thien_duong")},
          {"name": "Hang Én",               "image": img("hang_en")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 18 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_14": [
          {"name": "Bún Mắm",               "image": img("bun_mam")},
          {"name": "Lẩu Cá Kèo",           "image": img("lau_ca_keo")},
          {"name": "Cá Lóc Nướng Trui",    "image": img("ca_loc_nuong_trui")},
          {"name": "Bánh Khọt",            "image": img("banh_khot")},
          {"name": "Hủ Tiếu Nam Vang",     "image": img("hu_tieu_nam_vang")},
          {"name": "Cơm Niêu",             "image": img("com_nieu")},
          {"name": "Gà Nướng Muối Ớt",    "image": img("ga_nuong_muoi_ot")},
          {"name": "Vịt Quay",             "image": img("vit_quay")},
          {"name": "Bê Thui",              "image": img("be_thui")},
          {"name": "Bánh Đa Cua",         "image": img("banh_da_cua")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 19 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_15": [
          {"name": "Mexico",                "image": img("flag_mexico")},
          {"name": "Colombia",              "image": img("flag_colombia")},
          {"name": "Chile",                 "image": img("flag_chile")},
          {"name": "Peru",                  "image": img("flag_peru")},
          {"name": "Venezuela",             "image": img("flag_venezuela")},
          {"name": "Cuba",                  "image": img("flag_cuba")},
          {"name": "Ai Cập",               "image": img("flag_egypt")},
          {"name": "Nam Phi",              "image": img("flag_south_africa")},
          {"name": "Nigeria",              "image": img("flag_nigeria")},
          {"name": "Kenya",                "image": img("flag_kenya")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 20 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_16": [
          {"name": "Làng Cổ Đường Lâm",    "image": img("lang_co_duong_lam")},
          {"name": "Làng Gốm Bát Tràng",   "image": img("lang_gom_bat_trang")},
          {"name": "Làng Lụa Vạn Phúc",    "image": img("lang_lua_van_phuc")},
          {"name": "Văn Miếu Quốc Tử Giám","image": img("van_mieu_quoc_tu_giam")},
          {"name": "Nhà Hát Lớn Hà Nội",   "image": img("nha_hat_lon_ha_noi")},
          {"name": "Lăng Bác",             "image": img("lang_bac")},
          {"name": "Tháp Rùa",             "image": img("thap_rua")},
          {"name": "Cầu Long Biên",        "image": img("cau_long_bien")},
          {"name": "Chùa Trấn Quốc",      "image": img("chua_tran_quoc")},
          {"name": "Hồ Trúc Bạch",        "image": img("ho_truc_bach")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 21 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_17": [
          {"name": "Bánh Mì Thịt",         "image": img("banh_mi_thit")},
          {"name": "Bánh Mì Pate",         "image": img("banh_mi_pate")},
          {"name": "Bánh Mì Trứng",        "image": img("banh_mi_trung")},
          {"name": "Cơm Gà Hội An",        "image": img("com_ga_hoi_an")},
          {"name": "Mì Hoành Thánh",       "image": img("mi_hoanh_thanh")},
          {"name": "Lẩu Mắm",              "image": img("lau_mam")},
          {"name": "Cháo Vịt",             "image": img("chao_vit")},
          {"name": "Bánh Tráng Cuốn Thịt Heo","image": img("banh_trang_cuon_thit")},
          {"name": "Gỏi Ngó Sen",          "image": img("goi_ngo_sen")},
          {"name": "Chè Thái",             "image": img("che_thai")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 22 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_18": [
          {"name": "Nhật Bản",             "image": img("flag_japan")},
          {"name": "Hàn Quốc",             "image": img("flag_korea")},
          {"name": "Đài Loan",             "image": img("flag_taiwan")},
          {"name": "Hồng Kông",            "image": img("flag_hongkong")},
          {"name": "Mông Cổ",              "image": img("flag_mongolia")},
          {"name": "Kazakhstan",           "image": img("flag_kazakhstan")},
          {"name": "Uzbekistan",           "image": img("flag_uzbekistan")},
          {"name": "Afghanistan",          "image": img("flag_afghanistan")},
          {"name": "Bangladesh",           "image": img("flag_bangladesh")},
          {"name": "Sri Lanka",            "image": img("flag_sri_lanka")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 23 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_19": [
          {"name": "Núi Đôi Quản Bạ",      "image": img("nui_doi_quan_ba")},
          {"name": "Cao Nguyên Đồng Văn",  "image": img("cao_nguyen_dong_van")},
          {"name": "Đèo Ô Quy Hồ",        "image": img("deo_o_quy_ho")},
          {"name": "Thung Lũng Mường Hoa", "image": img("thung_lung_muong_hoa")},
          {"name": "Bản Cát Cát",          "image": img("ban_cat_cat")},
          {"name": "Thác Bạc Sapa",        "image": img("thac_bac_sapa")},
          {"name": "Thác Dải Yếm",         "image": img("thac_dai_yem")},
          {"name": "Bản Lác Mai Châu",     "image": img("ban_lac_mai_chau")},
          {"name": "Hồ Hòa Bình",          "image": img("ho_hoa_binh")},
          {"name": "Đèo Khau Phạ",         "image": img("deo_khau_pha")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 24 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_20": [
          {"name": "Thắng Cố",              "image": img("thang_co")},
          {"name": "Cháo Ấu Tẩu",          "image": img("chao_au_tau")},
          {"name": "Bánh Cuốn Trứng",      "image": img("banh_cuon_trung")},
          {"name": "Phở Chua",             "image": img("pho_chua")},
          {"name": "Khau Nhục",            "image": img("khau_nhuc")},
          {"name": "Vịt Quay Lạng Sơn",   "image": img("vit_quay_lang_son")},
          {"name": "Bánh Coong Phù",       "image": img("banh_coong_phu")},
          {"name": "Xôi Ngũ Sắc",         "image": img("xoi_ngu_sac")},
          {"name": "Bánh Chưng Gù",        "image": img("banh_chung_gu")},
          {"name": "Lợn Cắp Nách",         "image": img("lon_cap_nach")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 25 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_21": [
          {"name": "Đan Mạch",             "image": img("flag_denmark")},
          {"name": "Phần Lan",             "image": img("flag_finland")},
          {"name": "Iceland",              "image": img("flag_iceland")},
          {"name": "Ireland",              "image": img("flag_ireland")},
          {"name": "Áo",                   "image": img("flag_austria")},
          {"name": "Hungary",              "image": img("flag_hungary")},
          {"name": "Cộng Hòa Séc",        "image": img("flag_czech")},
          {"name": "Romania",              "image": img("flag_romania")},
          {"name": "Bulgaria",             "image": img("flag_bulgaria")},
          {"name": "Croatia",              "image": img("flag_croatia")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 26 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_22": [
          {"name": "Đảo Tuần Châu",        "image": img("dao_tuan_chau")},
          {"name": "Vịnh Bái Tử Long",     "image": img("vinh_bai_tu_long")},
          {"name": "Đảo Quan Lạn",         "image": img("dao_quan_lan")},
          {"name": "Hang Đầu Gỗ",          "image": img("hang_dau_go")},
          {"name": "Động Thiên Cung",      "image": img("dong_thien_cung")},
          {"name": "Đảo Ti Tốp",           "image": img("dao_ti_top")},
          {"name": "Hòn Gà Chọi",          "image": img("hon_ga_choi")},
          {"name": "Bãi Biển Trà Cổ",     "image": img("bai_bien_tra_co")},
          {"name": "Cửa Khẩu Móng Cái",   "image": img("cua_khau_mong_cai")},
          {"name": "Hang Pác Bó",          "image": img("hang_pac_bo")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 27 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_23": [
          {"name": "Bún Cá",               "image": img("bun_ca")},
          {"name": "Lẩu Hải Sản",          "image": img("lau_hai_san")},
          {"name": "Cua Rang Me",          "image": img("cua_rang_me")},
          {"name": "Tôm Hùm Nướng",       "image": img("tom_hum_nuong")},
          {"name": "Nghêu Hấp Sả",        "image": img("ngheu_hap_sa")},
          {"name": "Ốc Hương Nướng",      "image": img("oc_huong_nuong")},
          {"name": "Cá Bống Kho Tộ",     "image": img("ca_bong_kho_to")},
          {"name": "Mực Nướng",           "image": img("muc_nuong")},
          {"name": "Bạch Tuộc Nướng",    "image": img("bach_tuoc_nuong")},
          {"name": "Ghẹ Hấp",            "image": img("ghe_hap")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 28 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_24": [
          {"name": "Morocco",              "image": img("flag_morocco")},
          {"name": "Tunisia",              "image": img("flag_tunisia")},
          {"name": "Algeria",              "image": img("flag_algeria")},
          {"name": "Ethiopia",             "image": img("flag_ethiopia")},
          {"name": "Ghana",                "image": img("flag_ghana")},
          {"name": "Tanzania",             "image": img("flag_tanzania")},
          {"name": "Mozambique",           "image": img("flag_mozambique")},
          {"name": "Zimbabwe",             "image": img("flag_zimbabwe")},
          {"name": "Senegal",              "image": img("flag_senegal")},
          {"name": "Cameroon",             "image": img("flag_cameroon")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 29 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_25": [
          {"name": "Thành Nhà Hồ",         "image": img("thanh_nha_ho")},
          {"name": "Lam Kinh",             "image": img("lam_kinh")},
          {"name": "Biển Sầm Sơn",         "image": img("bien_sam_son")},
          {"name": "Suối Cá Thần Cẩm Lương","image": img("suoi_ca_than")},
          {"name": "Biển Hải Tiến",        "image": img("bien_hai_tien")},
          {"name": "Đảo Mắt",              "image": img("dao_mat")},
          {"name": "Biển Cửa Lò",          "image": img("bien_cua_lo")},
          {"name": "Vườn Quốc Gia Pù Mát", "image": img("vuon_pu_mat")},
          {"name": "Quê Bác Hồ Kim Liên",  "image": img("que_bac_ho")},
          {"name": "Biển Quỳnh Lưu",       "image": img("bien_quynh_luu")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 30 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_26": [
          {"name": "Bánh Ít Trần",         "image": img("banh_it_tran")},
          {"name": "Bánh Hỏi",             "image": img("banh_hoi")},
          {"name": "Bánh Tráng Phơi Sương","image": img("banh_trang_phoi_suong")},
          {"name": "Nem Chả Rán",          "image": img("nem_cha_ran")},
          {"name": "Chả Cá Lã Vọng",      "image": img("cha_ca_la_vong")},
          {"name": "Bún Thang",            "image": img("bun_thang")},
          {"name": "Phở Cuốn",             "image": img("pho_cuon")},
          {"name": "Bánh Đúc",             "image": img("banh_duc")},
          {"name": "Xôi Xéo",              "image": img("xoi_xeo")},
          {"name": "Chè Kho",              "image": img("che_kho")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 31 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_27": [
          {"name": "New Zealand",          "image": img("flag_new_zealand")},
          {"name": "Papua New Guinea",     "image": img("flag_papua")},
          {"name": "Fiji",                 "image": img("flag_fiji")},
          {"name": "Jamaica",              "image": img("flag_jamaica")},
          {"name": "Haiti",                "image": img("flag_haiti")},
          {"name": "Ecuador",              "image": img("flag_ecuador")},
          {"name": "Bolivia",              "image": img("flag_bolivia")},
          {"name": "Paraguay",             "image": img("flag_paraguay")},
          {"name": "Uruguay",              "image": img("flag_uruguay")},
          {"name": "Costa Rica",           "image": img("flag_costa_rica")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 32 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_28": [
          {"name": "Biển Quy Nhơn",        "image": img("bien_quy_nhon")},
          {"name": "Đảo Kỳ Co",            "image": img("dao_ky_co")},
          {"name": "Eo Gió",               "image": img("eo_gio")},
          {"name": "Ghềnh Ráng",           "image": img("ghenh_rang")},
          {"name": "Tháp Chăm Bình Định",  "image": img("thap_cham_binh_dinh")},
          {"name": "Vịnh Xuân Đài",        "image": img("vinh_xuan_dai")},
          {"name": "Biển Tuy Hòa",         "image": img("bien_tuy_hoa")},
          {"name": "Đầm Ô Loan",           "image": img("dam_o_loan")},
          {"name": "Tháp Nhạn",            "image": img("thap_nhan")},
          {"name": "Biển Cam Ranh",        "image": img("bien_cam_ranh")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 33 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_29": [
          {"name": "Lẩu Bò",               "image": img("lau_bo")},
          {"name": "Lẩu Riêu Cua",         "image": img("lau_rieu_cua")},
          {"name": "Lẩu Gà Lá Giang",      "image": img("lau_ga_la_giang")},
          {"name": "Lẩu Nấm",              "image": img("lau_nam")},
          {"name": "Lẩu Dê",               "image": img("lau_de")},
          {"name": "Lẩu Cá Tầm",           "image": img("lau_ca_tam")},
          {"name": "Cháo Trai",             "image": img("chao_trai")},
          {"name": "Súp Cua",               "image": img("sup_cua")},
          {"name": "Bánh Canh",             "image": img("banh_canh")},
          {"name": "Bánh Canh Ghẹ",        "image": img("banh_canh_ghe")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 34 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_30": [
          {"name": "Jordan",               "image": img("flag_jordan")},
          {"name": "Lebanon",              "image": img("flag_lebanon")},
          {"name": "Syria",                "image": img("flag_syria")},
          {"name": "Iraq",                 "image": img("flag_iraq")},
          {"name": "Kuwait",               "image": img("flag_kuwait")},
          {"name": "Qatar",                "image": img("flag_qatar")},
          {"name": "UAE",                  "image": img("flag_uae")},
          {"name": "Bahrain",              "image": img("flag_bahrain")},
          {"name": "Oman",                 "image": img("flag_oman")},
          {"name": "Yemen",                "image": img("flag_yemen")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 35 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_31": [
          {"name": "Thác Ba Hồ",           "image": img("thac_ba_ho")},
          {"name": "Đảo Bình Ba",          "image": img("dao_binh_ba")},
          {"name": "Vịnh Cam Ranh",        "image": img("vinh_cam_ranh")},
          {"name": "Tháp Bà Nha Trang",   "image": img("thap_ba_nha_trang")},
          {"name": "Đảo Hòn Tre",         "image": img("dao_hon_tre")},
          {"name": "Đảo Hòn Tằm",         "image": img("dao_hon_tam")},
          {"name": "Thác Dray Nur",        "image": img("thac_dray_nur")},
          {"name": "Thác Dray Sáp",       "image": img("thac_dray_sap")},
          {"name": "Buôn Đôn",            "image": img("buon_don")},
          {"name": "Hồ Lắk",             "image": img("ho_lak")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 36 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_32": [
          {"name": "Nem Lụi",               "image": img("nem_lui")},
          {"name": "Bánh Khoái",            "image": img("banh_khoai")},
          {"name": "Cơm Âm Phủ",           "image": img("com_am_phu")},
          {"name": "Bánh Nậm Huế",         "image": img("banh_nam_hue")},
          {"name": "Bún Bò Giò Heo",       "image": img("bun_bo_gio_heo")},
          {"name": "Bánh Bèo Chén",        "image": img("banh_beo_chen")},
          {"name": "Tôm Chua",             "image": img("tom_chua")},
          {"name": "Mắm Ruốc",             "image": img("mam_ruoc")},
          {"name": "Chè Hạt Sen",          "image": img("che_hat_sen")},
          {"name": "Chè Đậu Ván",          "image": img("che_dau_van")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 37 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_33": [
          {"name": "Nepal",                "image": img("flag_nepal")},
          {"name": "Bhutan",               "image": img("flag_bhutan")},
          {"name": "Maldives",             "image": img("flag_maldives")},
          {"name": "Myanmar",              "image": img("flag_myanmar")},
          {"name": "Campuchia",            "image": img("flag_cambodia")},
          {"name": "Lào",                  "image": img("flag_laos")},
          {"name": "Timor Leste",          "image": img("flag_timor_leste")},
          {"name": "Papua",                "image": img("flag_papua")},
          {"name": "Palau",                "image": img("flag_palau")},
          {"name": "Nauru",                "image": img("flag_nauru")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 38 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_34": [
          {"name": "Ga Đà Lạt",            "image": img("ga_da_lat")},
          {"name": "Nhà Thờ Con Gà",       "image": img("nha_tho_con_ga")},
          {"name": "Thác Prenn",           "image": img("thac_prenn")},
          {"name": "Thác Cam Ly",          "image": img("thac_cam_ly")},
          {"name": "Hồ Tuyền Lâm",        "image": img("ho_tuyen_lam")},
          {"name": "Thung Lũng Tình Yêu", "image": img("thung_lung_tinh_yeu")},
          {"name": "Hồ Xuân Hương",       "image": img("ho_xuan_huong")},
          {"name": "Langbiang",           "image": img("langbiang")},
          {"name": "Đồi Cát Mũi Né",     "image": img("doi_cat_mui_ne")},
          {"name": "Bàu Trắng",          "image": img("bau_trang")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 39 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_35": [
          {"name": "Dê Núi Nướng",         "image": img("de_nui_nuong")},
          {"name": "Thịt Chó",             "image": img("thit_cho")},
          {"name": "Tiết Canh",            "image": img("tiet_canh")},
          {"name": "Lòng Lợn Tiết Canh",  "image": img("long_lon_tiet_canh")},
          {"name": "Cà Pháo Mắm Tôm",     "image": img("ca_phao_mam_tom")},
          {"name": "Rau Muống Xào Tỏi",   "image": img("rau_muong_xao_toi")},
          {"name": "Canh Chua Cá Lóc",    "image": img("canh_chua_ca_loc")},
          {"name": "Cá Kho Tộ",           "image": img("ca_kho_to")},
          {"name": "Thịt Kho Tàu",        "image": img("thit_kho_tau")},
          {"name": "Canh Khổ Qua",        "image": img("canh_kho_qua")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 40 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_36": [
          {"name": "Serbia",               "image": img("flag_serbia")},
          {"name": "Slovenia",             "image": img("flag_slovenia")},
          {"name": "Slovakia",             "image": img("flag_slovakia")},
          {"name": "Albania",              "image": img("flag_albania")},
          {"name": "Macedonia",            "image": img("flag_macedonia")},
          {"name": "Montenegro",           "image": img("flag_montenegro")},
          {"name": "Bosnia",               "image": img("flag_bosnia")},
          {"name": "Moldova",              "image": img("flag_moldova")},
          {"name": "Belarus",              "image": img("flag_belarus")},
          {"name": "Estonia",              "image": img("flag_estonia")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 41 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_37": [
          {"name": "Dinh Độc Lập",         "image": img("dinh_doc_lap")},
          {"name": "Bưu Điện Thành Phố",   "image": img("buu_dien_thanh_pho")},
          {"name": "Nhà Thờ Đức Bà HCM",  "image": img("nha_tho_duc_ba_hcm")},
          {"name": "Landmark 81",          "image": img("landmark_81")},
          {"name": "Bitexco Tower",        "image": img("bitexco_tower")},
          {"name": "Phố Đi Bộ Nguyễn Huệ","image": img("pho_di_bo_nguyen_hue")},
          {"name": "Địa Đạo Củ Chi",      "image": img("dia_dao_cu_chi")},
          {"name": "Rừng Sác Cần Giờ",   "image": img("rung_sac_can_gio")},
          {"name": "Lăng Ông Bà Chiểu",  "image": img("lang_ong_ba_chieu")},
          {"name": "Chợ Bến Thành HCM",  "image": img("cho_ben_thanh")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 42 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_38": [
          {"name": "Sầu Riêng",            "image": img("sau_rieng")},
          {"name": "Chôm Chôm",            "image": img("chom_chom")},
          {"name": "Măng Cụt",             "image": img("mang_cut")},
          {"name": "Thanh Long",           "image": img("thanh_long")},
          {"name": "Xoài Cát Hòa Lộc",   "image": img("xoai_cat_hoa_loc")},
          {"name": "Vú Sữa Lò Rèn",      "image": img("vu_sua_lo_ren")},
          {"name": "Nhãn Lồng Hưng Yên", "image": img("nhan_long_hung_yen")},
          {"name": "Vải Thiều Lục Ngạn", "image": img("vai_thieu_luc_ngan")},
          {"name": "Bưởi Năm Roi",        "image": img("buoi_nam_roi")},
          {"name": "Dứa Đồng Giao",      "image": img("dua_dong_giao")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 43 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_39": [
          {"name": "Latvia",               "image": img("flag_latvia")},
          {"name": "Lithuania",            "image": img("flag_lithuania")},
          {"name": "Luxembourg",           "image": img("flag_luxembourg")},
          {"name": "Malta",                "image": img("flag_malta")},
          {"name": "Cyprus",               "image": img("flag_cyprus")},
          {"name": "Georgia",              "image": img("flag_georgia")},
          {"name": "Armenia",              "image": img("flag_armenia")},
          {"name": "Azerbaijan",           "image": img("flag_azerbaijan")},
          {"name": "Kyrgyzstan",           "image": img("flag_kyrgyzstan")},
          {"name": "Tajikistan",           "image": img("flag_tajikistan")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 44 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_40": [
          {"name": "Tòa Thánh Tây Ninh",  "image": img("toa_thanh_tay_ninh")},
          {"name": "Núi Bà Đen Tây Ninh", "image": img("nui_ba_den_tay_ninh")},
          {"name": "Hồ Dầu Tiếng",        "image": img("ho_dau_tieng")},
          {"name": "Núi Bà Rá",           "image": img("nui_ba_ra")},
          {"name": "Thác Mơ",             "image": img("thac_mo")},
          {"name": "Suối Nước Nóng Bình Châu","image": img("suoi_nuoc_nong")},
          {"name": "Hồ Cốc Bà Rịa",      "image": img("ho_coc")},
          {"name": "Biển Hồ Tràm",        "image": img("bien_ho_tram")},
          {"name": "Núi Minh Đạm",        "image": img("nui_minh_dam")},
          {"name": "Biển Bình Châu",      "image": img("bien_binh_chau")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 45 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_41": [
          {"name": "Phở Khô Gia Lai",      "image": img("pho_kho_gia_lai")},
          {"name": "Bánh Canh Bến Có",     "image": img("banh_canh_ben_co")},
          {"name": "Bún Nước Lèo",         "image": img("bun_nuoc_leo")},
          {"name": "Cháo Bà Đen",          "image": img("chao_ba_den")},
          {"name": "Bánh Tằm Bì",          "image": img("banh_tam_bi")},
          {"name": "Bún Suông",            "image": img("bun_suong")},
          {"name": "Cơm Cháy Ninh Bình",  "image": img("com_chay_ninh_binh")},
          {"name": "Bánh Gai",             "image": img("banh_gai")},
          {"name": "Kẹo Lạc",             "image": img("keo_lac")},
          {"name": "Bánh Đậu Xanh",       "image": img("banh_dau_xanh")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 46 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_42": [
          {"name": "Guatemala",            "image": img("flag_guatemala")},
          {"name": "Honduras",             "image": img("flag_honduras")},
          {"name": "El Salvador",          "image": img("flag_el_salvador")},
          {"name": "Nicaragua",            "image": img("flag_nicaragua")},
          {"name": "Panama",               "image": img("flag_panama")},
          {"name": "Trinidad Tobago",      "image": img("flag_trinidad")},
          {"name": "Barbados",             "image": img("flag_barbados")},
          {"name": "Belize",               "image": img("flag_belize")},
          {"name": "Bahamas",              "image": img("flag_bahamas")},
          {"name": "Guyana",               "image": img("flag_guyana")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 47 — DANH LAM
        // ══════════════════════════════════════════════════════════════════════
        "level_43": [
          {"name": "Cố Đô Hoa Lư",        "image": img("co_do_hoa_lu")},
          {"name": "Tràng An Ninh Bình",   "image": img("trang_an_ninh_binh")},
          {"name": "Bái Đính Ninh Bình",   "image": img("bai_dinh_ninh_binh")},
          {"name": "Hang Múa",             "image": img("hang_mua")},
          {"name": "Vân Long",             "image": img("van_long")},
          {"name": "Thung Nham",           "image": img("thung_nham")},
          {"name": "Đền Trần Nam Định",   "image": img("den_tran_nam_dinh")},
          {"name": "Chùa Keo",            "image": img("chua_keo")},
          {"name": "Hồ Tam Chúc",        "image": img("ho_tam_chuc")},
          {"name": "Chùa Long Đọi Sơn",  "image": img("chua_long_doi_son")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🍜 MÀN 48 — ẨM THỰC
        // ══════════════════════════════════════════════════════════════════════
        "level_44": [
          {"name": "Bánh Kem",             "image": img("banh_kem")},
          {"name": "Bánh Su Kem",          "image": img("banh_su_kem")},
          {"name": "Chè Trôi Nước",        "image": img("che_troi_nuoc")},
          {"name": "Bánh Trôi",            "image": img("banh_troi")},
          {"name": "Chè Xôi Nước",         "image": img("che_xoi_nuoc")},
          {"name": "Bánh Rán",             "image": img("banh_ran")},
          {"name": "Bánh Tiêu",            "image": img("banh_tieu")},
          {"name": "Bánh Bao",             "image": img("banh_bao")},
          {"name": "Bánh Phu Thê",         "image": img("banh_phu_the")},
          {"name": "Bánh Cốm",             "image": img("banh_com")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏳️ MÀN 49 — QUỐC KỲ
        // ══════════════════════════════════════════════════════════════════════
        "level_45": [
          {"name": "Angola",               "image": img("flag_angola")},
          {"name": "Congo",                "image": img("flag_congo")},
          {"name": "Sudan",                "image": img("flag_sudan")},
          {"name": "Somalia",              "image": img("flag_somalia")},
          {"name": "Libya",                "image": img("flag_libya")},
          {"name": "Zambia",               "image": img("flag_zambia")},
          {"name": "Madagascar",           "image": img("flag_madagascar")},
          {"name": "Rwanda",               "image": img("flag_rwanda")},
          {"name": "Uganda",               "image": img("flag_uganda")},
          {"name": "Namibia",              "image": img("flag_namibia")},
        ],

        // ══════════════════════════════════════════════════════════════════════
        // 🏞️ MÀN 50 — DANH LAM (Phú Quốc - màn cuối hoành tráng)
        // ══════════════════════════════════════════════════════════════════════
        "level_46": [
          {"name": "Bãi Sao Phú Quốc",    "image": img("bai_sao_phu_quoc")},
          {"name": "Bãi Trường Phú Quốc", "image": img("bai_truong_phu_quoc")},
          {"name": "Cáp Treo Phú Quốc",  "image": img("cap_treo_phu_quoc")},
          {"name": "Vinwonders Phú Quốc", "image": img("vinwonders_phu_quoc")},
          {"name": "Suối Tranh Phú Quốc","image": img("suoi_tranh_phu_quoc")},
          {"name": "Dinh Cậu Phú Quốc",  "image": img("dinh_cau_phu_quoc")},
          {"name": "Chợ Đêm Phú Quốc",   "image": img("cho_dem_phu_quoc")},
          {"name": "Bãi Khem",            "image": img("bai_khem")},
          {"name": "Hòn Thơm",            "image": img("hon_thom")},
          {"name": "Mũi Ông Đội",         "image": img("mui_ong_doi")},
        ],
      };

      int manOrder = 1;

      for (var entry in data.entries) {
        String manId = entry.key;
        List<Map<String, String>> questions = entry.value;

        final manRef = categoryRef.collection("mans").doc(manId);

        // Xác định chủ đề để đặt tên màn
        String themeName;
        if (manOrder % 3 == 2) {
          themeName = "🍜 Ẩm Thực - Level $manOrder";
        } else if (manOrder % 3 == 1) {
          themeName = "🏳️ Quốc Kỳ - Level $manOrder";
        } else {
          themeName = "🏞️ Danh Lam - Level $manOrder";
        }

        await manRef.set({
          "name": "Level $manOrder",
          "themeName": themeName,
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

        print("✅ Màn $manOrder [$themeName] — ${questions.length} câu hỏi");
        manOrder++;
      }

      print("🎉 Hoàn tất! 46 màn × 10 câu = 460 câu hỏi");
      print("📌 Cần upload ảnh lên Cloudinary theo format: v1774754562/ten_file.jpg");
    } catch (e) {
      print("❌ Lỗi: $e");
    }
  }
}

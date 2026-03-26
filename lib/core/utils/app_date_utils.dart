/// ================= EXPERIENCE DAYS =================
/// số ngày từ lúc tạo tài khoản → hiện tại
int calculateExperienceDays(DateTime? createdAt) {
  if (createdAt == null) return 0;

  final now = DateTime.now();
  final diff = now.difference(createdAt).inDays;

  return diff < 0 ? 0 : diff;
}

/// ================= PROGRESS YEAR =================
/// progress theo năm (0 → 1)
double calculateYearProgress(int days) {
  double progress = days / 365;
  if (progress > 1) progress = 1;
  if (progress < 0) progress = 0;
  return progress;
}

/// ================= FORMAT DAYS TEXT =================
String formatExperienceText(int days) {
  if (days <= 0) return "Mới tham gia";
  if (days == 1) return "1 ngày trải nghiệm";
  return "$days ngày trải nghiệm";
}
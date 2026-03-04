import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/profile/widgets/profile_shimmer.dart';
import 'package:dovui/presentation/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.cardColor,
      extendBody: true,
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const ProfileShimmer();
            }

            /// 🔥 Giá trị mặc định khi logout
            String name = "Admin";
            int score = 0;
            String correct = "0%";
            int rank = 0;

            /// ✅ Nếu đã đăng nhập
            if (state is UserRegistered) {
              name = state.user.name;
              score = state.user.score;
              rank = state.user.rank;

              // Bạn có thể tính lại nếu có logic đúng
              correct = "62%";
              
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                children: [
                  /// ================= HEADER =================
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 260,
                        decoration: const BoxDecoration(
                          color: ColorManager.primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text(
                              "Thông Tin",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -60,
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xffE0E0E0),
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : "A",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "@${name.toLowerCase()}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ================= STATS =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(correct, "Correct"),
                        _buildStatCard("$score", "Points"),
                        _buildStatCard("#"+"$rank", "Rank"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ================= LOGOUT BUTTON =================
                  if (state is UserRegistered)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.gamecomplete,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text("Xác nhận"),
                                  content: const Text(
                                    "Bạn có chắc muốn đăng xuất không?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: const Text("Huỷ"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorManager.gamecomplete,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        context
                                            .read<UserBloc>()
                                            .add(LogoutUserEvent());
                                      },
                                      child: const Text(
                                        "Đăng xuất",
                                        style:
                                            TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Đăng xuất",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorManager.cardColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff2E2A72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 
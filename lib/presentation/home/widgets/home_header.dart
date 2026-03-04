import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) {
        // Chỉ rebuild khi state là UserRegistered
        return current is UserRegistered;
      },
      builder: (context, state) {
        String name = "Admin";

        if (state is UserRegistered) {
          name = state.user.name;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin Chào, $name",
              style: const TextStyle(
                fontSize: 16,
                color: ColorManager.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cùng chơi nào!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorManager.primaryDark,
              ),
            ),
          ],
        );
      },
    );
  }
}
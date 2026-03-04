import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/adddulieu/adddulieu.dart';
import 'package:dovui/presentation/home/bloc/home_bloc.dart';
import 'package:dovui/presentation/home/bloc/home_event.dart';
import 'package:dovui/presentation/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/quiz_of_week.dart';
import 'widgets/categories_section.dart';
import 'widgets/home_shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(LoadHome()),
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBackground,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const HomeShimmer();
              }

              if (state is HomeLoaded) {
                Size size = MediaQuery.sizeOf(context);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.06,
                    0,
                    size.width * 0.06,
                    70,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      HomeHeader(),
                      SizedBox(height: 25),
                      StreakCard(),
                      SizedBox(height: 30),
                      QuizOfWeek(),
                      SizedBox(height: 30),
                      CategoriesSection(),
                      SizedBox(height: 30),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

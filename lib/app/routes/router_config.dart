import 'package:dovui/app/routes/router_name.dart';
import 'package:dovui/features/category/category_screen.dart';
import 'package:dovui/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterConfigCustom {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: RouterPath.HomeScreen,
        builder: (BuildContext context, GoRouterState state){
          return const HomeScreen();
        }
        )],
  );
}

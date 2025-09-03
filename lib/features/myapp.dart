import 'package:flutter/material.dart';
import 'package:dovui/app/routes/router_config.dart';

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        useMaterial3: true, 
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black
          )
        ),
      ),
      routerConfig: RouterConfigCustom.router,
    );
  }
}
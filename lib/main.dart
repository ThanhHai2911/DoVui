import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/splash/splash_screen.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WakelockPlus.enable();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  final analytics = FirebaseAnalytics.instance;
  await analytics.logAppOpen();

  // Load ads sau khi init xong
  RewardedAdManager().loadAd();
  InterstitialAdManager().loadAd();
  // await MobileAds.instance.initialize().then((_) {
  //   NativeAdManager().preloadPool();
  // });

  runApp(const MyApp());
}

// ═══════════════════════════════════════════
//  MyApp — StatefulWidget để dùng WidgetsBindingObserver
// ═══════════════════════════════════════════
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (_) => UserBloc(UserRepository())),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
import 'package:app/providers/user_points_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/ui/admin/screens/dashboard_screen.dart';
import 'package:app/ui/order/payment_success.dart';
import 'package:app/ui/product/product_details.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/cart_provider.dart';
import 'ui/main_page.dart';
import 'ui/login/login_page.dart';
import 'ui/login/verify_otp_register.dart';
import 'ui/order/payment_process.dart';
import 'ui/product/product_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio();
  final apiService = ApiService(dio);
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatefulWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(apiService: widget.apiService),
        ),
        ChangeNotifierProvider(create: (_) => UserPointsProvider()),
      ],
      child: MaterialApp(
        locale: Locale('vi', 'VN'),
        supportedLocales: [Locale('en', 'US'), Locale('vi', 'VN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        debugShowCheckedModeBanner: false,
        title: 'Ecommerce App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/main': (context) => MainPage(),
          '/manager': (context) => DashboardScreen(),
          '/login': (context) => LoginPage(),
          '/otp': (context) => VerifyOtpScreen(),
          '/cart': (context) => ShoppingCartPage(),
          '/success': (context) => PaymentSuccessScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String role = "";

  Future<void> _navigateAfterDelay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";

    await Future.delayed(const Duration(seconds: 3));

    if (role == "ROLE_ADMIN") {
      Navigator.pushNamedAndRemoveUntil(context, "/manager", (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/animation.json', width: 200),
            SizedBox(height: 15),
            Text(
              "TechZone",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

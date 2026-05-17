import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp();
  await FirestoreService().seedMenusIfEmpty();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Matchacih',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}

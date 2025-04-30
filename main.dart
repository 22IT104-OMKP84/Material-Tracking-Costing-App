import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartfab_material_tracker/providers/auth_provider.dart';
import 'package:smartfab_material_tracker/providers/theme_provider.dart';
import 'package:smartfab_material_tracker/providers/inventory_provider.dart';
import 'package:smartfab_material_tracker/screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SmartFabApp(),
    ),
  );
}

class SmartFabApp extends StatelessWidget {
  const SmartFabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'SmartFab Material Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

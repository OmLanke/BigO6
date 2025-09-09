import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/location_provider.dart';
import 'providers/tourist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => TouristProvider()),
      ],
      child: MaterialApp.router(
        title: 'Tourist Safety App',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

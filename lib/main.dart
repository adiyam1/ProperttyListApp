import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/app_init_provider.dart';
import 'screens/property_list_screen.dart';

void main() {
  // Ensure Flutter is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Theme (persisted in SQLite via ThemeNotifier)
    final isDarkMode = ref.watch(themeProvider);

    // 2. Watch the Initialization state
    final appInit = ref.watch(appInitProvider);

    return MaterialApp(
      title: 'Property Pal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // themeMode automatically switches based on the profile toggle
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Handle the initial state of the app
      home: appInit.when(
        data: (_) => const PropertyListScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Initialization Failed: $err')),
        ),
      ),
    );
  }
}
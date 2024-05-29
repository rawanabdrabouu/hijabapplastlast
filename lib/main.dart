import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:hijaby_app/screens/home_screen.dart';
import 'package:hijaby_app/screens/user_profile.dart';
import 'package:hijaby_app/screens/signInPage.dart';
import 'package:hijaby_app/screens/signUpPage.dart';
import 'package:hijaby_app/screens/Vendor/add_products.dart';
import 'package:hijaby_app/providers/productProvider.dart';
import 'package:hijaby_app/providers/cartProvider.dart';
import 'package:hijaby_app/utils/theme/theme.dart';
import 'package:hijaby_app/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  ).catchError((error) {
    print('Error initializing Firebase: $error');
  });

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
    debug: true,
  );

  // Request notification permissions
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Initialize FCM service
  await FCMService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hijab Boutique',
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/sign-in': (context) => SignInPage(),
          '/sign-up': (context) => SignUpPage(),
          '/add-product': (context) => AddProductScreen(),
          '/profile': (context) => UserProfile(),
        },
      ),
    );
  }
}

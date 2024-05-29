// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> handleBackgorundMessage (RemoteMessage message) async{
//   print('Title: ${message.notification?.title}');
//   print('Body: ${message.notification?.body}');
//   print('Payload: ${message.data}');
// }

// class FirebaseApi{
//   final _fcm = FirebaseMessaging.instance;

//   void handleMessage(RemoteMessage? message){
//     if(message == null) return;

//     navigatorKey.currentState?.pushNamed(
//       NotificationScreen.route,
//       arguments: message,
//     );
//   }

//   Future initPushNotifications() async {
//     await FirebaseMessaging.instance.set
//   }

//   Future<void> initNotifications() async {
//     await _fcm.requestPermission();
//     final _fcmToken = await _fcm.getToken();
//     print('Token: $_fcmToken');

//     FirebaseMessaging.onBackgroundMessage(handleBackgorundMessage);
//   }
// }
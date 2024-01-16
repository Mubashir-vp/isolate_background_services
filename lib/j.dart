// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   FlutterBackgroundService.initialize(onStart);
//   runApp(MyApp());
// }

// void onStart() {
//   Timer.periodic(Duration(seconds: 1), (timer) async {
//     if (!await FlutterBackgroundService().isServiceRunning()) {
//       timer.cancel();
//       FlutterBackgroundService().sendData({"action": "stopService"});
//       return;
//     }

//     final positionStream = await getSpeed();
//     positionStream.listen((position) {
//       FlutterBackgroundService().sendData({"action": "locationData", "position": position.toJson()});
//       final speed = position.speed * 3.6; // convert m/s to km/h
//       if (speed > 10) {
//         showNotification();
//       }
//     });
//   });
// }

// Future<Stream<Position>> getSpeed() async {
//   await Geolocator.checkPermission();
//   await Geolocator.openLocationSettings();
//   return Geolocator.getPositionStream(
//     desiredAccuracy: LocationAccuracy.high,
//     distanceFilter: 0,
//     intervalDuration: Duration(seconds: 1),
//     forceAndroidLocationManager: true,
//   );
// }

// void showNotification() {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   var android = AndroidNotificationDetails(
//     'channel id',
//     'channel name',
//     'channel description',
//     importance: Importance.high,
//     priority: Priority.high,
//     playSound: true,
//     sound: RawResourceAndroidNotificationSound('notification_sound'),
//   );
//   var iOS = IOSNotificationDetails();
//   var platform = NotificationDetails(android: android, iOS: iOS);
//   flutterLocalNotificationsPlugin.show(
//     Random().nextInt(100),
//     'Speed Limit Exceeded',
//     'You are driving over 10 km/h',
//     platform,
//   );
// }

// class MyApp extends StatelessWidget {
 

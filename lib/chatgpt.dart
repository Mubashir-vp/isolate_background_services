import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isolate_background_services/services/notificationServices.dart';

import 'extraMain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  await Geolocator.requestPermission();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AUTO PARK',
      initialNotificationContent: 'The Automated Paking APP',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();

  runApp(MyApp());
}

void onStart(ServiceInstance service) async {
  // bool serviceEnabled;
  // LocationPermission permission;
  // serviceEnabled = await Geolocator.isLocationServiceEnabled();
  // if (!serviceEnabled) {
  //   log("Permission denied");
  // }
  // permission = await Geolocator.checkPermission();
  // if (permission == LocationPermission.denied) {
  //   permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied) {
  //     return Future.error('Location permissions are denied');
  //   }
  // }

  // if (permission == LocationPermission.deniedForever) {
  //   return Future.error(
  //       'Location permissions are permanently denied, we cannot request permissions.');
  // } else {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    StreamSubscription<Position>? positionStreamSubscription;
    StreamController<bool> trafficStreamController = StreamController<bool>();
    Stream<bool> trafficStream = trafficStreamController.stream;
    ;
    positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: defaultTargetPlatform == TargetPlatform.android
                ? AndroidSettings(
                    accuracy: LocationAccuracy.high,
                    distanceFilter: 0,
                    // forceLocationManager: true,
                    intervalDuration: const Duration(seconds: 1),
                    // (Optional) Set foreground notification config to keep the app alive
                    // when going to the background
                    foregroundNotificationConfig:
                        const ForegroundNotificationConfig(
                      notificationText:
                          "AUTO park will continue to work in background even when you aren't using it",
                      notificationTitle: "Running in Background",
                      enableWakeLock: true,
                    ),
                  )
                : defaultTargetPlatform == TargetPlatform.iOS
                    ? AppleSettings(
                        accuracy: LocationAccuracy.high,
                        activityType: ActivityType.fitness,
                        distanceFilter: 0,
                        pauseLocationUpdatesAutomatically: true,
                        // Only set to true if our app will be started up in the background.
                        showBackgroundLocationIndicator: false,
                      )
                    : const LocationSettings(
                        accuracy: LocationAccuracy.high,
                        distanceFilter: 0,
                      ))
        .listen((position) async {
      final speedInKmh = position.speed * 3.6; // convert speed from m/s to km/h
      log("SPEED HERE BRO${speedInKmh.toString()}");

      if (speedInKmh > 30) {
        FlutterBackgroundService().invoke(speedInKmh.toString());

        NotificationServices().shownotfication();
      }
      final bool isrunning = await FlutterBackgroundService().isRunning();
      if (isrunning == false) {
        positionStreamSubscription?.cancel();
      }
    });
    // if ("speed" != null) {
    //   await NotificationServices().shownotfication();
    // }
  });
}
//   Stream<Traffic> getTrafficStream() {
//     final traffic = Traffic();
//     return traffic.trafficStream;
//   }
// void checkTrafficBeforeSendingNotification() async {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//     final Traffic traffic = await mapController.getVisibleRegion().then(
//           (LatLngBounds bounds) =>
//               mapController.getZoomLevel().then((double zoomLevel) =>
//                   mapController.getTraffic().then((Traffic traffic) => traffic)),
//         );

//     if (traffic == Traffic.congestion || traffic == Traffic.verySlow) {
//       trafficStreamController.add(false);
//     } else {
//       trafficStreamController.add(true);
//     }
//   }
Stream<Position> getSpeed() {
  return Geolocator.getPositionStream(
      locationSettings: defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
              // forceLocationManager: true,
              intervalDuration: const Duration(seconds: 1),
              // (Optional) Set foreground notification config to keep the app alive
              // when going to the background
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationText:
                    "Example app will continue to receive your location even when you aren't using it",
                notificationTitle: "Running in Background",
                enableWakeLock: true,
              ))
          : defaultTargetPlatform == TargetPlatform.iOS
              ? AppleSettings(
                  accuracy: LocationAccuracy.high,
                  activityType: ActivityType.fitness,
                  distanceFilter: 0,
                  pauseLocationUpdatesAutomatically: true,
                  // Only set to true if our app will be started up in the background.
                  showBackgroundLocationIndicator: false,
                )
              : const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 0,
                ));
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'speed_notification',
    'Speed Notification',
    channelDescription: 'Shows a notification when the user is moving too fast',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);
  await FlutterLocalNotificationsPlugin().show(
    0,
    'Speed Warning',
    'You are moving too fast!',
    platformDetails,
    payload: 'speed_warning',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Service Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Service Demo'),
        ),
        body: const Center(
          child: Text('Background Service is running...'),
        ),
      ),
    );
  }
}

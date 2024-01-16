import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location sevices are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are perminently denied, We cannot access it");
    }
    return await Geolocator.getCurrentPosition();
  }

  String? getLivelocation() {
    String message = '';
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      message =
          "Langitude:${position.latitude} Longitude:${position.longitude},";
    });
    return message;
  }

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
                foregroundNotificationConfig:
                    const ForegroundNotificationConfig(
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

  Stream<Position> newGetSpeed() {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    Stream<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);

    return positionStream;
  }
}

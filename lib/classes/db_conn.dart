import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class DatabaseConnection {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  getMyLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': _locationResult.latitude,
        'longtitude': _locationResult.longitude,
        'name': 'john'
      }, SetOptions(merge: true));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> enableLiveLocation(String name) async {
    locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      locationSubscription?.cancel();
      locationSubscription = null;
    }).listen((loc.LocationData currentLocation) async {
      await FirebaseFirestore.instance.collection('location').doc(name).set({
        'latitude': currentLocation.latitude,
        'longtitude': currentLocation.longitude,
        'name': name
      }, SetOptions(merge: true));
    });
  }

  stopLiveLocation() {
    locationSubscription?.cancel();

    locationSubscription = null;
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Fluttertoast.showToast(
          msg: "Permission Granted",
          textColor: Colors.white,
          backgroundColor: Colors.green);
    } else if (status.isDenied) {
      Fluttertoast.showToast(
          msg: "Permission Denied",
          textColor: Colors.white,
          backgroundColor: Colors.red);
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}

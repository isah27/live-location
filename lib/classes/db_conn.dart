import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/classes/user_name_loc_db.dart';
import 'package:location_tracker/model/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

import '../keys/api_key.dart';

class DatabaseConnection {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  DataBaseHelper _baseHelper = DataBaseHelper.instance;

  void initClas() {
    location.changeSettings(interval: 400, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  getMyLocation(User user) async {
    initClas();
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('location')
          .doc(user.name)
          .get();

      if (!snapShot.exists) {
        final loc.LocationData _locationResult = await location.getLocation();
        await FirebaseFirestore.instance
            .collection('location')
            .doc(user.name)
            .set({
          'latitude': _locationResult.latitude,
          'longtitude': _locationResult.longitude,
          'name': user.name
        }, SetOptions(merge: true));
        _baseHelper.insertUser(user);
      } else {
        Fluttertoast.showToast(
          msg: "Name have been taken",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unknown error",
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }
// get my initial location
  // getMyLocation() async {
  //   try {
  //     final loc.LocationData _locationResult = await location.getLocation();
  //     await FirebaseFirestore.instance.collection('location').doc('user1').set({
  //       'latitude': _locationResult.latitude,
  //       'longtitude': _locationResult.longitude,
  //       'name': 'john'
  //     }, SetOptions(merge: true));
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

// enable live location
  Future<void> enableLiveLocation(String name) async {
    initClas();
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

// stop live location
  stopLiveLocation() {
    locationSubscription?.cancel();

    locationSubscription = null;
  }

// request for permission
  requestPermission() async {
    var status = await Permission.locationAlways.request();
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
      requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

// switch between eneble and disable live location function
  switchs(bool value, String name) {
    try {
      if (value == true) {
        enableLiveLocation(name);
      } else if (value == false) {
        stopLiveLocation();
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Add your location",
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

// map api calls
  Future<void> getReverseGeolocation() async {
    final geometry = LatLng(6.2212896, 7.0792027);
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${geometry.latitude},${geometry.longitude}&key=$mapApiKeys");
    var result = await http.get(url).then((value) {
      return value.body;
    });

    log(result.toString());
  }
}

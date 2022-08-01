import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart' as loc;
import 'package:location_tracker/classes/user_name_loc_db.dart';
import 'package:location_tracker/model/user.dart';
import 'package:location_tracker/pages/Map.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  static bool isTextBoxVisible = false;
  TextEditingController nameController = TextEditingController();
  static User userModel = User();
  static DataBaseHelper? _baseHelper;
  static List<User> user = [];
  static bool switchValue = false;
  //form key
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _requestPermission();
    _baseHelper = DataBaseHelper.instance;
    fetchUserInfo();
    location.changeSettings(interval: 400, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  fetchUserInfo() async {
    user = await _baseHelper!.fetchUser();
    setState(() {});
  }

  switchs(bool value) {
    try {
      if (value == true) {
        setState(() {
          enableLiveLocation(user.first.name!);
          switchValue = value;
        });
      } else if (value == false) {
        setState(() {
          stopLiveLocation();
          switchValue = value;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Add your location",
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: isTextBoxVisible ? true : false,
      controller: nameController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Field is empty");
        }

        return null;
      },
      onSaved: (value) {
        nameController.text = value!.toUpperCase();
        userModel.name = value.toUpperCase();
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.verified_user_rounded,
          color: Colors.amber.shade800,
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "User name",
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        title: const Text("Live location Tracker"),
        actions: [
          GestureDetector(
            onTap: () {
              //(user.first.name!);
            },
            child: Switch.adaptive(
              activeColor: Colors.amber.shade800,
              activeTrackColor: Colors.white,
              value: switchValue,
              onChanged: (bool value) {
                switchs(value);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Visibility(
            visible: user.isEmpty ? true : false,
            child: TextButton(
                onPressed: () {
                  isTextBoxVisible = true;
                  fetchUserInfo();

                  setState(() {});
                },
                child: Text(
                  "Add my location",
                  style: TextStyle(color: Colors.amber.shade900),
                )),
          ),
          Visibility(
            visible: isTextBoxVisible ? true : false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  child: Form(
                    key: _formKey,
                    child: nameField,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      getMyLocation(nameController.text.toUpperCase());
                      // user.first.name = "";
                      setState(() {});
                    }

                    setState(() {
                      isTextBoxVisible = false;
                    });
                  },
                  icon: Icon(
                    Icons.add_location,
                    color: Colors.amber.shade900,
                    size: 40,
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("location").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      snapshot.data!.docs[index]['name'].toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    subtitle: Row(
                      children: [
                        Text(snapshot.data!.docs[index]['latitude'].toString(),
                            style: TextStyle(color: Colors.amber.shade800)),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                            snapshot.data!.docs[index]['longtitude'].toString(),
                            style: TextStyle(color: Colors.amber.shade800))
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.directions,
                        color: Colors.amber.shade900,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                Maps(user_id: snapshot.data!.docs[index].id)));
                      },
                    ),
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }

  getMyLocation(String name) async {
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('location')
          .doc(name)
          .get();

      if (!snapShot.exists) {
        final loc.LocationData _locationResult = await location.getLocation();
        await FirebaseFirestore.instance.collection('location').doc(name).set({
          'latitude': _locationResult.latitude,
          'longtitude': _locationResult.longitude,
          'name': name
        }, SetOptions(merge: true));
        _baseHelper!.insertUser(userModel);
      } else {
        Fluttertoast.showToast(
            msg: "Name have been taken",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  Future<void> enableLiveLocation(String name) async {
    locationSubscription = location.onLocationChanged.handleError((onError) {
      Fluttertoast.showToast(
          msg: onError, textColor: Colors.white, backgroundColor: Colors.red);
      locationSubscription?.cancel();
      setState(() {
        locationSubscription = null;
      });
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
    setState(() {
      locationSubscription = null;
    });
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

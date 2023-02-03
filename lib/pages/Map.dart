import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class Maps extends StatefulWidget {
  final String user_id;
  const Maps({Key? key, required this.user_id}) : super(key: key);

  @override
  State<Maps> createState() => _MapState();
}

class _MapState extends State<Maps> {
  final loc.Location location = loc.Location();
  late GoogleMapController controller;
  bool added = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("location")
              .doc(widget.user_id)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (added) {
              _onChangeLocation(snapshot);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            return GoogleMap(
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: MarkerId(snapshot.data!.id),
                  position: LatLng(
                    snapshot.data!['latitude'],
                    snapshot.data!['longtitude'],
                  ),
                  consumeTapEvents: true,
                  infoWindow: InfoWindow(
                    title: snapshot.data!.id,
                    snippet: "good day ${snapshot.data!.id}",
                    anchor: Offset(4, 4),
                    onTap: () {
                      Text(
                        "markers",
                        style: TextStyle(color: Colors.amber.shade900),
                      );
                    },
                  ),
                  onTap: () {
                    Column(
                      children: [
                        Text(
                          "markers",
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ],
                    );
                  },
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
                Marker(
                  markerId: MarkerId(snapshot.data!.id),
                  position: LatLng(
                    snapshot.data!['latitude'],
                    snapshot.data!['longtitude'],
                  ),
                  consumeTapEvents: true,
                  infoWindow: InfoWindow(
                    title: snapshot.data!.id,
                    snippet: "good day ${snapshot.data!.id}",
                    anchor: Offset(4, 4),
                    onTap: () {
                      Text(
                        "markers",
                        style: TextStyle(color: Colors.amber.shade900),
                      );
                    },
                  ),
                  onTap: () {
                    log("markers");
                    InfoWindow(title: "heloooooooo");
                    Column(
                      children: [
                        Text(
                          "markers",
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ],
                    );
                  },
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  snapshot.data!['latitude'],
                  snapshot.data!['longtitude'],
                ),
                zoom: 16.47,
              ),
              onMapCreated: (GoogleMapController _controller) async {
                setState(() {
                  controller = _controller;
                  added = true;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onChangeLocation(
      AsyncSnapshot<DocumentSnapshot> snapshot) async {
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        snapshot.data!["latitude"],
        snapshot.data!['longtitude'],
      ),
      zoom: 17.75,
    )));
  }
}

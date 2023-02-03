import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../pages/Map.dart';

class UserName extends StatelessWidget {
  const UserName({
    Key? key,
    required this.isTextBoxVisible,
    required this.nameController,
  }) : super(key: key);

  final bool isTextBoxVisible;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
  }
}

class MapCustomSwitch extends StatelessWidget {
  const MapCustomSwitch({
    Key? key,
    required this.switchValue,
    required this.onChange,
    required this.size,
  }) : super(key: key);

  final bool switchValue;
  final Function(bool value) onChange;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
        horizontal: size.width * 0.2,
      ),
      child: Row(children: [
        Text(
          switchValue ? "Disable live location" : "Enable live location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(width: size.width * 0.05),
        GestureDetector(
          onTap: () {
            //(user.first.name!);
          },
          child: Switch.adaptive(
            activeColor: Colors.amber.shade800,
            activeTrackColor: Colors.white,
            value: switchValue,
            onChanged: (bool value) {
              onChange(value);
            },
          ),
        ),
      ]),
    );
  }
}

class TeamInfo extends StatelessWidget {
  const TeamInfo(
      {required this.snapshot,
      this.color = Colors.black87,
      required this.onTap,
      Key? key})
      : super(key: key);
  final DocumentSnapshot snapshot;
  final Function() onTap;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => Maps(user_id: snapshot.id),
        //   ),
        // );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  snapshot['name'],
                  style: TextStyle(fontSize: 16.sp, color: color),
                ),
                SizedBox(width: 3.w),
                Row(
                  children: [
                    Text(
                      snapshot['latitude'].toString(),
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      snapshot['longtitude'].toString(),
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 10.sp,
                      ),
                    )
                  ],
                ),
              ],
            ),
            InkWell(
              child: Icon(
                Icons.directions,
                color: Colors.amber.shade900,
                size: 25.sp,
              ),
              onTap: () {
                onTap();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Maps(user_id: snapshot.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class SmallMap extends StatelessWidget {
  const SmallMap({
    Key? key,
    required this.size,
    required this.currentId,
  }) : super(key: key);

  final Size size;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size.height * 0.5,
        width: size.width * 0.9,
        alignment: Alignment.center,
        margin: EdgeInsets.all(size.width * 0.04),
        padding: EdgeInsets.all(size.width * 0.01),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius:
              BorderRadius.circular(size.width * 0.03),
        ),
        child: ClipRRect(
            borderRadius:
                BorderRadius.circular(size.width * 0.03),
            child: Maps(user_id: currentId)),
      );
  }
}
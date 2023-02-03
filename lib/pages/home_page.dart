import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/classes/user_name_loc_db.dart';
import 'package:location_tracker/model/user.dart';
import 'package:sizer/sizer.dart';

import '../classes/db_conn.dart';
import '../widget/map_components.dart';

class MainPage extends StatefulWidget {
  const MainPage({required this.user, Key? key}) : super(key: key);
  final User user;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static bool isTextBoxVisible = false;
  TextEditingController nameController = TextEditingController();

  static DataBaseHelper? _baseHelper;
  static User user = User();
  static String currentId = user.name ?? "";
  static bool switchValue = false;
  bool isLoading = false;
  DatabaseConnection dbConnction = DatabaseConnection();

  @override
  void initState() {
    _baseHelper = DataBaseHelper.instance;
    user = widget.user;
    super.initState();
    // dbConnction.requestPermission();
  }

  fetchUserInfo() async {
    final data = await _baseHelper!.fetchUser();
    setState(() {
      user = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameField = UserName(
      isTextBoxVisible: isTextBoxVisible,
      nameController: nameController,
    );
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.amber.shade900,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MapCustomSwitch(
                  switchValue: switchValue,
                  size: size,
                  onChange: (value) {
                    if (user.name != null) {
                      dbConnction.switchs(value, user.name!);
                      setState(() {
                        switchValue = value;
                      });
                    }
                  },
                ),
                user.name == null
                    ? Container()
                    : SmallMap(size: size, currentId: currentId),
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(size.width * 0.02),
                          topRight: Radius.circular(size.width * 0.02),
                        ),
                      ),
                      child: Column(
                        children: [
                          Visibility(
                            visible: user.name == null ? true : false,
                            child: Column(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      fetchUserInfo();

                                      setState(() {
                                        isTextBoxVisible = true;
                                      });
                                    },
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                          color: Colors.amber.shade900,
                                          fontSize: 12.sp),
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: size.width / 2,
                                      height: size.height * 0.08,
                                      child: nameField,
                                    ),
                                    isLoading
                                        ? SizedBox(
                                            height: size.width * 0.1,
                                            width: size.width * 0.1,
                                            child: CircularProgressIndicator
                                                .adaptive())
                                        : IconButton(
                                            onPressed: () async {
                                              if (nameController
                                                  .text.isNotEmpty) {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await dbConnction.getMyLocation(
                                                    User(
                                                        name: nameController
                                                            .text
                                                            .toUpperCase(),
                                                        enableStatus:
                                                            switchValue
                                                                ? 1
                                                                : 0));

                                                fetchUserInfo();
                                                // user.first.name = "";

                                                if (user.name != null) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.send,
                                              color: Colors.amber.shade900,
                                              size: 30.sp,
                                            ),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("location")
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child:
                                        CircularProgressIndicator.adaptive());
                              }
                              if (!snapshot.hasData) {
                                return Center(child: Container());
                              }
                              return Visibility(
                                visible: user.name == null ? false : true,
                                child: ListView.builder(
                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder: (context, index) {
                                    return TeamInfo(
                                        color: snapshot.data!.docs[index].id ==
                                                currentId
                                            ? Colors.amber.shade900
                                            : Colors.black87,
                                        onTap: () {
                                          setState(() {
                                            currentId =
                                                snapshot.data!.docs[index].id;
                                          });
                                        },
                                        snapshot: snapshot.data!.docs[index]);
                                  },
                                ),
                              );
                            },
                          )),
                          SizedBox(height: size.height * 0.025),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/classes/db_conn.dart';
import 'package:location_tracker/pages/Map.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  //form key
  TextEditingController nameController = TextEditingController();
  static bool switchValue = false;
  static int isTextBoxVisible = 0;
  final DatabaseConnection _connection = DatabaseConnection();
  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: isTextBoxVisible == 1 ? true : false,
      controller: nameController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Field is empty");
        }

        return null;
      },
      onSaved: (value) {
        nameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_city),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "User name",
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
            ),
           
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Live Location",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (switchValue == true) {
                          _connection.enableLiveLocation('ISAH');
                          setState(() {});
                        } else {
                          _connection.stopLiveLocation();
                          setState(() {});
                        }
                      },
                      child: Switch.adaptive(
                        dragStartBehavior: DragStartBehavior.start,
                        activeColor: Colors.amber.shade800,
                        activeTrackColor: Colors.white,
                        value: switchValue,
                        onChanged: (value) {
                          switchValue = value;
                          if (value == true) {
                            _connection.enableLiveLocation;
                          } else {
                            _connection.stopLiveLocation();
                          }

                          print(value);

                          setState(() {});
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: double.maxFinite,
            width: MediaQuery.of(context).size.width,
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
                      title:
                          Text(snapshot.data!.docs[index]['name'].toString()),
                      subtitle: Row(
                        children: [
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longtitude']
                              .toString())
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Maps(
                                  user_id: snapshot.data!.docs[index].id)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

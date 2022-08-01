import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/pages/Map.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
            ),
            child: const Center(
              child: Text(
                "Live Location",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
                      title: Text(
                        snapshot.data!.docs[index]['name'].toString(),
                        style: const TextStyle(fontSize: 30),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            snapshot.data!.docs[index]['latitude'].toString(),
                            style: TextStyle(color: Colors.amber.shade800),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            snapshot.data!.docs[index]['longtitude'].toString(),
                            style: TextStyle(color: Colors.amber.shade800),
                          )
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.directions,
                          color: Colors.amber.shade900,
                        ),
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

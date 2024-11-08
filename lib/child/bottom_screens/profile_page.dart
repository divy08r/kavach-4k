import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavach_4k/child/child_login_screen.dart';
import 'package:kavach_4k/model/user_model.dart';
import 'package:kavach_4k/child/bottom_page.dart'; // Import necessary files
import 'package:kavach_4k/model/contactsm.dart';
import 'package:kavach_4k/db/db_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<UserModel> getUserDetails(String childEmail) async {
    final snapShot = await _db
        .collection("users")
        .where("childEmail", isEqualTo: childEmail)
        .get();
    final userData = snapShot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    return userData;
  }

  getUserData() {
    final userEmail = _user!.email;
    if (userEmail != null) {
      return getUserDetails(userEmail);
    }
  }
  Future<bool> getUserCon() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();
    return contactList.isEmpty;
  }

  // Function to handle logout
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 5.0, bottom: 10.0),  // Adjust the left padding as needed
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 30, color: Colors.black,fontFamily: 'imf'),
          ),
        ),
        backgroundColor: Colors.greenAccent[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(

        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: FutureBuilder(
          future: getUserData(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                UserModel userData = snapshot.data as UserModel;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/icon5.jpg'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hello, ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          userData.name ?? 'User',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<bool>(
                      future: getUserCon(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data == true) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  elevation: 8,
                                  color: Colors.greenAccent[700],
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Profile',
                                          style: TextStyle(
                                            fontFamily: 'imf',
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 8),
                                Text(
                                  '50% completed',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Image.asset(
                                  'assets/profileNotCompleted.jpg',
                                  width: 140,
                                  height: 60,
                                ),
                              ],
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                    Card(
                      elevation: 8,
                      color: Colors.greenAccent[700],
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              'Contact Number',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              userData.phone ?? 'N/A',
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 5,
                            child: Divider(
                              color: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    ),


                    Card(
                      elevation: 8,
                      color: Colors.greenAccent[700],
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 55.0, right:55.0),
                        child: Column(
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              userData.childEmail ?? 'N/A',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            height: 4,
                            width: 220,
                            child: Divider(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),
                    // You can add more user details or customize as needed
                  ],
                );

              } else {
                return const Center(child: Text('Something went wrong'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),

        ),
      ),
    );
  }

}
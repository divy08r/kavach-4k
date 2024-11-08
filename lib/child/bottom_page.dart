import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kavach_4k/child/bottom_screens/contacts_page.dart';
import 'package:kavach_4k/child/bottom_screens/review_page.dart';

import 'bottom_screens/add_contacts.dart';
import 'bottom_screens/chat_page.dart';
import 'bottom_screens/child_home_screen.dart';
import 'bottom_screens/profile_page.dart';

class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    //ContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];
  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(
              label: 'home',
              icon: Icon(
                Icons.home,
              )),
          BottomNavigationBarItem(
              label: 'contacts',
              icon: Icon(
                Icons.contacts,
              )),
          BottomNavigationBarItem(
              label: 'voice',
              icon: Icon(
                Icons.keyboard_voice_rounded,
              )),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(
                Icons.person,
              )),
          BottomNavigationBarItem(
              label: 'Reviews',
              icon: Icon(
                Icons.reviews,
              ))
        ],
      ),
    );
  }
}

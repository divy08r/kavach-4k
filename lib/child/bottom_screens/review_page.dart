import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kavach_4k/components/PrimaryButton.dart';
import 'package:kavach_4k/components/SecondaryButton.dart';
import 'package:kavach_4k/components/custom_textfield.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  bool isSaving = false;

  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Review your place"),
            content: Form(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextField(
                          hintText: 'Enter Location',
                          controller: locationC,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextField(
                          controller: viewsC,
                          hintText: 'Enter Reviews',
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                )),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent[700], // Set the background color to blue
                ),
                onPressed: () {
                  saveReview();
                  Navigator.pop(context);
                },
                child: Text("SAVE"),
              ),
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance
        .collection('reviews')
        .add({'location': locationC.text, 'views': viewsC.text}).then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'review uploaded successfully');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 5.0, bottom: 10.0),  // Adjust the left padding as needed
          child: Text(
            'Recent Reviews',
            style: TextStyle(fontSize: 30, color: Colors.black, fontFamily: 'imf',),
          ),
        ),
        backgroundColor: Colors.greenAccent[700],
        elevation: 0,

      ),
      body: isSaving == true
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Container(
                color: Colors.lightGreen[250],
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final data = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 3.0, right: 3.0),
                          child: Card(
                            elevation: 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: Colors.limeAccent[100],
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 6.0, bottom: 15.0),
                                child: Row(
                                  children: [
                                    Text(
                                      data['location'],
                                      style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'Roboto'),
                                    ),
                                    SizedBox(width: 8.0),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                data['views'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent[700],
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

}

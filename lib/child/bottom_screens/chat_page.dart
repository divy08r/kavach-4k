import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:background_sms/background_sms.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kavach_4k/db/db_services.dart';
import 'package:kavach_4k/model/contactsm.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Position? _curentPosition;
  String? _curentAddress;
  LocationPermission? permission;
  _getpermission() => (Permission.sms).request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;
  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: 1);
    if (result == SmsStatus.sent) {
      print("Sent");
      Fluttertoast.showToast(msg: "send");
    } else {
      Fluttertoast.showToast(msg: "failed");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _curentPosition = position;
        print(_curentPosition!.latitude);
        _getAddressFromLatLon();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _curentPosition!.latitude, _curentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _curentAddress =
        "${place.locality},${place.postalCode},${place.street},";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  bool isRecording = false;
  bool collecting = false;
  late AudioRecorder _audioRecorder;
  late String _filePath;
  bool playing = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _getpermission();
    _getCurrentLocation();
    _audioRecorder = AudioRecorder();
    _filePath = '';
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final path = appDocDir.path + '/myFile.wav';
      // final directory = '/storage/emulated/0/Download';
      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav),
          path: path);

      setState(() {
        isRecording = true;
        _filePath = path;
      });
      print("Recording started. File path: $_filePath");
      Fluttertoast.showToast(
        msg: "Recording started. File path: $_filePath",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Handle permissions not granted
      print("Permissions not granted");
    }
  }

  Future<void> stopRecording() async {
    String? path = await _audioRecorder.stop();
    setState(() {
      isRecording = false;
      _filePath = path!;
    });
    if (path != null) {
      final fileBytes = await File(_filePath).readAsBytes();
      Uint8List audioData = Uint8List.fromList(fileBytes);
      try {
        File file = File(_filePath);
        await file.writeAsBytes(audioData);
        print('saved file at $path');
      } catch (e) {
        print('Error writing audio data: $e');
      }
    }
  }

  Future<void> cancelRecording() async {
    await _audioRecorder.stop();
    setState(() {
      isRecording = false;
      _filePath = '';
    });
  }

  Future<void> sendAudioFile() async {
    final uri = Uri.parse("https://getpredictions-zwofr6ivcq-et.a.run.app/");

    final fileBytes = await File(_filePath).readAsBytes();

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('audio', fileBytes,
            filename: 'myFile.wav'));

      final response = await request.send().timeout(Duration(seconds: 300));

      print(response.statusCode);

      if (response.statusCode == 200) {
        final jsonResponse = await http.Response.fromStream(response);
        print(jsonResponse.body);

        final Map<String, dynamic> result_now = json.decode(jsonResponse.body);
        final accuracy = result_now['accuracy'];
        final predictedClass = result_now['predicted_class'];
        if (predictedClass == "Danger" && accuracy > 60) {
          _getCurrentLocation();
          String recipients = "";
          List<TContact> contactList = await DatabaseHelper().getContactList();
          print(contactList.length);
          if (contactList.isEmpty) {
            Fluttertoast.showToast(msg: "emergency contact is empty");
          } else {
            String messageBody =
                "https://www.google.com/maps/search/?api=1&query=${_curentPosition!.latitude}%2C${_curentPosition!.longitude}. $_curentAddress";

            if (await _isPermissionGranted()) {
              contactList.forEach((element) {
                _sendSms("${element.number}", "i am in trouble $messageBody");
              });
            } else {
              Fluttertoast.showToast(msg: "something wrong");
            }
          }
        }
        if (predictedClass == "Danger" && accuracy > 90) {
          playing = true;
          await player.play(AssetSource('alertalarm.wav'));
        }
        Fluttertoast.showToast(
          msg: "Accuracy: $accuracy, Class: $predictedClass",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> collectAudio() async {
    int i = 0;
    if (await _audioRecorder.hasPermission()) {
      while (collecting) {
        // Record for 3 seconds
        startRecording();
        await Future.delayed(Duration(milliseconds: 3000));
        await stopRecording();

        // Api fetching
        await sendAudioFile();
        //.............
        cancelRecording();
        // Rest for 10 seconds
        await Future.delayed(Duration(milliseconds: 3000));
        print("Recording number: " + i.toString());
        i = i + 1;
      }
    } else {
      // Handle permissions not granted
      print("Permissions not granted");
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text("Voice Page",style: TextStyle(
              fontSize: 30.0,
              fontFamily: 'imf',)),
          backgroundColor: Colors.greenAccent[700],
        ),
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (playing)
                  ElevatedButton(
                      onPressed: () async {
                        playing = false;
                        await player.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Color.fromARGB(255, 182, 35, 24), // Button color
                        foregroundColor: Colors.white, // Text color
                        side: BorderSide(
                            color: Colors.white, width: 2), // White outline
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Stop Alert Beep',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                // Display a photo or image widget here
                Image.asset(
                  'assets/Micnew.png', // replace with your image file path
                  width: 270, // set the width as needed
                  height: 270, // set the height as needed
                  // add more styling properties if required
                ),

                SizedBox(height: 16),
                SizedBox(height: 16),
                SizedBox(height: 16),
                if (collecting)
                  Image.asset(
                    "assets/soundgif.gif",
                    height: 125.0,

                    width: 125.0,
                  ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                SizedBox(height: 16),
                SizedBox(height: 16),
                if (collecting)
                  ElevatedButton(
                    onPressed: () {
                      // stopRecording();
                      setState(() {
                        collecting = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      minimumSize: Size(120, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
                      ),// Set the background color to blue
                    ),
                    child: Text("Stop Recording",style: TextStyle(fontSize: 28, color: Colors.white, )),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        collecting = true;
                      });
                      collectAudio();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      minimumSize: Size(120, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
                      ),// Set the background color to blue
                    ),
                    child: Text("Start Recording", style: TextStyle(fontSize: 28, color: Colors.white, )),
                  ),
                SizedBox(height: 16),
                if (!isRecording && _filePath.isNotEmpty)
                  ElevatedButton(
                    onPressed: cancelRecording,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      minimumSize: Size(120, 60),// Set the background color to blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
                      ),
                    ),
                    child: Text("Cancel Recording", style: TextStyle(fontSize: 28, color: Colors.white, )),
                  ),
              ],
            ),
          ),
        )
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChatPage(),
  ));
}
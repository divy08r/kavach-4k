import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? name;
  String? phone;
  String? id;
  String? childEmail;
  String? parentEmail;
  String? type;
  UserModel(
      {this.name,
        this.childEmail,
        this.id,
        this.parentEmail,
        this.phone,
        this.type});

  Map<String, dynamic> tojson() => {
    'name': name,
    'phone': phone,
    'id': id,
    'childEmail': childEmail,
    'parentEmail': parentEmail,
    'type': type
  };

  toJson() {
    return {
      "childEmail": childEmail,
      "name": name,
      "parentEmail": parentEmail,
      "phone": phone
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
        id: document.id,
        childEmail: data["childEmail"],
        parentEmail: data['parentEmail'],
        name: data["name"],
        phone: data['phone']);
  }
}
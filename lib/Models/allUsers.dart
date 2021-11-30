import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Users {
  String id;
  String email;
  String nom;
  String prenom;
  String tel;
  Users({this.id, this.email, this.nom, this.prenom, this.tel});
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = dataSnapshot.value["email"];
    nom = dataSnapshot.value["nom"];
    prenom = dataSnapshot.value["prenom"];
    tel = dataSnapshot.value["tel"];
  }
  void modifyUser() {}
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber_app/AllScreens/loginScreen.dart';
import 'package:flutter_uber_app/AllScreens/mainScreen.dart';
import 'package:flutter_uber_app/AllWidgets/progressDialog.dart';
import 'package:flutter_uber_app/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idScreen = "signup";
  TextEditingController nomTextEditingController = TextEditingController();
  TextEditingController prenomTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController telTextEditingController = TextEditingController();
  TextEditingController pwdTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 35.0),
              Image(
                image: AssetImage("images/logo.png"),
                width: 366.0,
                height: 240.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 4.0),
              Text(
                "S'inscrire tant qu'un chauffeur",
                style: TextStyle(
                    fontSize: 24.0,
                    fontFamily: "Brand Bold",
                    color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 0.25,
                    ),
                    TextField(
                      controller: nomTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Nom",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: prenomTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Prenom",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: telTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Tel",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: pwdTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    SizedBox(
                      height: 45.0,
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        width: 100.0,
                        child: Center(
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (nomTextEditingController.text.length < 3) {
                          displayToastMessage(
                              "le nom doit contenir au moins 3 lettres !",
                              context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayToastMessage(
                              "email addresse n'est pas valide !", context);
                        } else if (telTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              "Insérez le numéro de telephone SVP !", context);
                        } else if (pwdTextEditingController.text.length < 7) {
                          displayToastMessage(
                              "le mot de passe de 6 caractères au minimum !",
                              context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: Text(
                  "Vous avez déja un compte? S'identifier ici.",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog("Inscréption en cours ....");
        });
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: pwdTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Erruer: " + errMsg.toString(), context);
    }))
        .user;
    if (firebaseUser != null) {
      Map userDataMap = {
        "nom": nomTextEditingController.text.trim(),
        "prenom": prenomTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "tel": telTextEditingController.text.trim(),
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage("compte uilisateur est créé !", context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage("Compte utilisateur n'est pas créé", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}

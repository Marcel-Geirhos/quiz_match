import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:quiz_match/userInterface/loginPage.dart';
import 'package:quiz_match/userInterface/registerPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: RaisedButton(
                child: Text('Logout'),
                onPressed: () => signOutDialog(),
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 30.0),
                child: RaisedButton(
                  child: Text('Account löschen'),
                  onPressed: () => deleteAccountDialog(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TODO auslagern, da diese Funktion auch in gameSelectionPage vorkommt
  Future<bool> signOutDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Ausloggen?'),
        content: Text('Willst du dich wirklich ausloggen?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Nein'),
          ),
          FlatButton(
            onPressed: () => signOut(),
            child: Text('Ja'),
          ),
        ],
      ),
    )) ??
        false;
  }

  /// TODO auslagern, da diese Funktion auch in gameSelectionPage vorkommt
  void signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), ModalRoute.withName('/'));
  }

  Future<bool> deleteAccountDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Account löschen?'),
        content: Text('Willst du dich wirklich deinen Account löschen? Es werden alle Daten unwideruflich gelöscht und können nicht wiederhergestellt werden!'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Nein'),
          ),
          FlatButton(
            onPressed: () => deleteAccount(),
            child: Text('Ja'),
          ),
        ],
      ),
    )) ??
        false;
  }

  void deleteAccount() async {
    FirebaseUser user = await _auth.currentUser();
    await user.delete();
    await Firestore.instance.collection('users').document(user.uid).delete();
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (BuildContext context) => RegisterPage()), ModalRoute.withName('/'));
  }
}

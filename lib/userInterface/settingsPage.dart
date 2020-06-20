import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:quiz_match/userInterface/loginPage.dart';
import 'package:quiz_match/userInterface/registerPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _deleteAccountFormKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'Account wird gelöscht...');
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Um die Löschung deines Accounts zu bestätigen musst du dein Passwort eingeben.',
                    textAlign: TextAlign.center,
                  ),
                ),
                Form(
                  key: _deleteAccountFormKey,
                  child: TextFormField(
                    controller: _password,
                    maxLength: 30,
                    obscureText: true,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      labelText: 'Passwort...',
                      contentPadding: const EdgeInsets.all(0),
                      isDense: true,
                      prefixIcon: Icon(Icons.lock, size: 22.0),
                      counterText: '',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Es werden alle Accountdaten unwideruflich gelöscht und können nicht wiederhergestellt werden!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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

  String validatePassword(String password) {
    int minLength = 6;
    if (password.isEmpty) {
      return 'Bitte Passwort eingeben.';
    } else if (password.length < minLength) {
      return 'Mindestens $minLength Zeichen benötigt.';
    } else {
      return null;
    }
  }

  Future<bool> deleteAccount() async {
    if (_deleteAccountFormKey.currentState.validate()) {
      _progressDialog.show();
      try {
        FirebaseUser user = await _auth.currentUser();
        AuthCredential credentials =
        EmailAuthProvider.getCredential(email: user.email, password: _password.text.toString().trim());
        AuthResult result = await user.reauthenticateWithCredential(credentials);
        await Firestore.instance.collection('users').document(user.uid).delete();
        await result.user.delete();
        _progressDialog.hide();
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (BuildContext context) => RegisterPage()), ModalRoute.withName('/'));
        return true;
      } catch (e) {
        print(e.toString());
        _progressDialog.hide();
        return false;
      }
    }
  }
}

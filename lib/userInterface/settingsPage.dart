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
  final GlobalKey<FormState> _changeUsernameFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  Future _loadUserData;
  ProgressDialog _progressDialog;
  bool _oneClickModus;
  var _userData;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _oneClickModus = true;
    _loadUserData = getCurrentUser();
    _progressDialog = ProgressDialog(context);
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
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SwitchListTile(
            value: _oneClickModus,
            title: Text('Antworten mit einem Klick auf Ergebnisfeld setzen'),
            onChanged: (value) {
              setState(() {
                _oneClickModus = value;
              });
            },
          ),
          FutureBuilder(
            future: _loadUserData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListTile(
                  title: Text('Benutzername:'),
                  subtitle: Form(
                    key: _changeUsernameFormKey,
                    child: TextFormField(
                      controller: _username,
                      maxLength: 30,
                      validator: validateUsername,
                      decoration: InputDecoration(
                        hintText: _userData == null ? '' : _userData['username'],
                        prefixIcon: Icon(Icons.person, size: 22.0),
                        counterText: '',
                      ),
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                child: Builder(
                  builder: (BuildContext context) {
                    return OutlineButton(
                      child: Text('Änderungen übernehmen'),
                      onPressed: () => saveChanges(context),
                      borderSide: BorderSide(width: 2, color: Color(0xFF555555)),
                    );
                  }
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2 - 37,
                child: OutlineButton(
                  child: Text('Ausloggen'),
                  onPressed: () => signOutDialog(),
                  borderSide: BorderSide(width: 2, color: Color(0xFF555555)),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 37,
                child: OutlineButton(
                  child: Text('Account löschen'),
                  onPressed: () => deleteAccountDialog(),
                  borderSide: BorderSide(width: 2, color: Color(0xFF555555)),
                ),
              ),
            ],
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
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
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
              Builder(
                builder: (BuildContext context) {
                  return FlatButton(
                    onPressed: () => deleteAccount(context),
                    child: Text('Ja'),
                  );
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> saveChanges(BuildContext context) async {
    if (_changeUsernameFormKey.currentState.validate()) {
      _progressDialog.style(message: 'Änderungen werden gespeichert...');
      _progressDialog.show();
      try {
        await Firestore.instance.collection('users').document(_user.uid).updateData({
          'username': _username.text,
        });
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Änderungen wurden erfolgreich gespeichert.')));
      } catch (error) {
        print(error.toString());
      }
    }
    _progressDialog.hide();
  }

  Future<void> getCurrentUser() async {
    _user = await _auth.currentUser();
    _userData = await Firestore.instance.collection('users').document(_user.uid).get();
  }

  String validateUsername(String username) {
    int minLength = 3;
    if (username.isEmpty) {
      return 'Bitte Benutzername eingeben.';
    } else if (username.length < minLength) {
      return 'Mindestens $minLength Zeichen benötigt.';
    } else {
      return null;
    }
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

  Future<bool> deleteAccount(BuildContext context) async {
    String errorMessage;
    if (_deleteAccountFormKey.currentState.validate()) {
      _progressDialog.style(message: 'Account wird gelöscht...');
      _progressDialog.show();
      try {
        AuthCredential credentials =
            EmailAuthProvider.getCredential(email: _user.email, password: _password.text.toString().trim());
        AuthResult result = await _user.reauthenticateWithCredential(credentials);
        await Firestore.instance.collection('users').document(_user.uid).delete();
        await result.user.delete();
        _progressDialog.hide();
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (BuildContext context) => RegisterPage()), ModalRoute.withName('/'));
        return true;
      } catch (error) {
        switch (error.code) {
          case "ERROR_WRONG_PASSWORD":
            errorMessage = 'Falsches Passwort.';
            break;
          default:
            errorMessage = 'Unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.';
        }
        // TODO Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        print(error.toString());
        _progressDialog.hide();
        return false;
      }
    }
  }
}

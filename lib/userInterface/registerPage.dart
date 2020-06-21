import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:quiz_match/userInterface/loginPage.dart';
import 'package:quiz_match/userInterface/gameSelectionPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;
  bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    // automatischer Login
    getUser().then((user) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => GameSelectionPage()),
            ModalRoute.withName('/'));
      }
    });
    _obscurePassword = true;
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'Registrierung...');
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Match',
          style: TextStyle(letterSpacing: 1.4),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _registerFormKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  registerText(),
                  usernameField(),
                  emailField(),
                  passwordField(),
                  registerButton(),
                  toLogin(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget registerText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Registrierung',
        style: TextStyle(fontSize: 24.0, letterSpacing: 1.4),
      ),
    );
  }

  Widget usernameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        controller: _username,
        maxLength: 30,
        validator: validateUsername,
        decoration: InputDecoration(
          labelText: 'Benutzername...',
          contentPadding: const EdgeInsets.all(0),
          isDense: true,
          prefixIcon: Icon(Icons.person, size: 22.0),
          counterText: '',
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        controller: _email,
        maxLength: 40,
        validator: validateEmail,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'E-Mail...',
          contentPadding: const EdgeInsets.all(0),
          isDense: true,
          prefixIcon: Icon(Icons.email, size: 22.0),
          counterText: '',
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        controller: _password,
        maxLength: 30,
        obscureText: _obscurePassword,
        validator: validatePassword,
        decoration: InputDecoration(
          labelText: 'Passwort...',
          contentPadding: const EdgeInsets.all(0),
          isDense: true,
          prefixIcon: Icon(Icons.lock, size: 22.0),
          suffixIcon: IconButton(
              icon: Icon(!_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 22.0),
              onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  })),
          counterText: '',
        ),
      ),
    );
  }

  Widget registerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Builder(builder: (BuildContext context) {
        return RaisedButton(
          onPressed: () => registerUser(context),
          child: Text(
            'Registrieren',
            style: TextStyle(fontSize: 18.0, letterSpacing: 1.0),
          ),
        );
      }),
    );
  }

  Widget toLogin() {
    return GestureDetector(
      onTap: () => setState(() {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), ModalRoute.withName('/'));
      }),
      child: Text(
        'Zum Login',
        style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
      ),
    );
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

  String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Bitte E-Mail eingeben.';
    } else if (EmailValidator.validate(email.trim()) == false) {
      return 'E-Mail Format ist nicht korrekt.';
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

  registerUser(BuildContext context) async {
    String errorMessage;
    if (_registerFormKey.currentState.validate()) {
      _progressDialog.show();
      try {
        final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
                email: _email.text.toString().trim(), password: _password.text.toString().trim()))
            .user;
        createUserInCloudFirestore(user);
      } catch (error) {
        switch (error.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            errorMessage = 'E-Mail ist bereits registriert.';
            break;
          default:
            errorMessage = 'Unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.';
        }
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  createUserInCloudFirestore(FirebaseUser user) async {
    try {
      final userData = await Firestore.instance.collection('users').document(user.uid).get();
      if (userData == null || !userData.exists) {
        await Firestore.instance.collection('users').document(user.uid).setData({
          'email': _email.text.toString().trim(),
          'username': _username.text.toString(),
          'coins': 0,
          'classicHighscoreRASP': 0,
          'questionHighscoreRASP5': 0,
          'questionHighscoreRASP10': 0,
          'questionHighscoreRASP15': 0,
          'classicHighscorePSP': 0,
          'questionHighscorePSP5': 0,
          'questionHighscorePSP10': 0,
          'questionHighscorePSP15': 0,
        });
        _progressDialog.hide();
        setState(() {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) => GameSelectionPage()), ModalRoute.withName('/'));
        });
      }
    } catch (error) {
      print('Create User in Cloud Firestore Error: ' + error.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: const Text('Benutzer Registrierung fehlgeschlagen. Bitte versuche es erneut.'),
        ),
      );
    }
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }
}

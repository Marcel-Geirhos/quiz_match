import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:quiz_match/userInterface/registerPage.dart';
import 'package:quiz_match/userInterface/gameSelectionPage.dart';
import 'package:quiz_match/userInterface/resetPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;
  bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _obscurePassword = true;
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'Login...');
  }

  @override
  void dispose() {
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
            key: _loginFormKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  loginText(),
                  emailField(),
                  passwordField(),
                  loginButton(),
                  forgotPassword(),
                  toRegister(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 24.0, letterSpacing: 1.4),
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
              })
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget loginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Builder(
          builder: (BuildContext context) {
            return RaisedButton(
              onPressed: () => loginUser(context),
              child: Text(
                'Einloggen',
                style: TextStyle(fontSize: 18.0, letterSpacing: 1.0),
              ),
            );
          }
      ),
    );
  }

  Widget toRegister() {
    return GestureDetector(
      onTap: () => setState(() {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) => RegisterPage()),
            ModalRoute.withName('/'));
      }),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          'Zur Registrierung',
          style: TextStyle(fontSize: 16.0, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return GestureDetector(
      onTap: () => setState(() {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) => ResetPasswordPage()),
            ModalRoute.withName('/'));
      }),
      child: Text(
        'Passwort vergessen?',
        style: TextStyle(fontSize: 16.0, letterSpacing: 1.2),
      ),
    );
  }

  String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Bitte E-Mail eingeben.';
    } else if (EmailValidator.validate(email.trim()) == false) {
      return 'E-Mail ist nicht richtig formatiert.';
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

  loginUser(BuildContext context) async {
    String errorMessage;
    bool loginSuccessful = false;
    if (_loginFormKey.currentState.validate()) {
      _progressDialog.show();
      try {
        await _auth.signInWithEmailAndPassword(email: _email.text.toString().trim(), password: _password.text.toString().trim());
        loginSuccessful = true;
      } catch (error) {
        switch (error.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = 'E-Mail Format ist nicht korrekt.';
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = 'Falsches Passwort.';
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = 'E-Mail ist nicht registriert.';
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = 'Ihr Konto wurde gesperrt. Bitte melden sie sich beim Support.';
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = 'Zu viele ungültige Versuche. Versuchen sie es bitte später erneut.';
            break;
          default:
            errorMessage = 'Unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.';
        }
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      _progressDialog.hide();
      if (loginSuccessful) {
        setState(() {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) => GameSelectionPage()),
              ModalRoute.withName('/'));
        });
      }
    }
  }
}

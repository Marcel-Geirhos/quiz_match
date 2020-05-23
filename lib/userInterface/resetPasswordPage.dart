import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:quiz_match/userInterface/loginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _resetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'E-Mail wird gesendet...');
  }

  @override
  void dispose() {
    _email.dispose();
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
            key: _resetPasswordFormKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  resetPasswordText(),
                  emailField(),
                  resetPasswordButton(),
                  toLogin(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resetPasswordText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Passwort zurücksetzen',
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

  Widget resetPasswordButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Builder(
          builder: (BuildContext context) {
            return RaisedButton(
              onPressed: () => resetPassword(context),
              child: Text(
                'Passwort zurücksetzen',
                style: TextStyle(fontSize: 18.0, letterSpacing: 1.0),
              ),
            );
          }
      ),
    );
  }

  Widget toLogin() {
    return GestureDetector(
      onTap: () => setState(() {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            ModalRoute.withName('/'));
      }),
      child: Text(
        'Zum Login',
        style: TextStyle(fontSize: 16.0, letterSpacing: 1.0),
      ),
    );
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

  resetPassword(BuildContext context) async {
    bool resetPasswordSuccessful = false;
    if (_resetPasswordFormKey.currentState.validate()) {
      _progressDialog.show();
      try {
        await _auth.sendPasswordResetEmail(email: _email.text.toString().trim());
        resetPasswordSuccessful = true;
      } catch (error) {
        print(error.toString());
      }
      _progressDialog.hide();
      if (resetPasswordSuccessful) {
        setState(() {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
              ModalRoute.withName('/'));
        });
      }
    }
  }
}

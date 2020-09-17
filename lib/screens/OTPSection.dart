import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petopedia/screens/HomePage.dart';
import 'package:petopedia/screens/welcomeScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:toast/toast.dart';

class OTPSection extends StatefulWidget {
  final String phoneController;
  final String verifyid;

  OTPSection(this.phoneController, this.verifyid, {Key key}) : super(key: key);

  @override
  _OTPSectionState createState() => _OTPSectionState();
}

class _OTPSectionState extends State<OTPSection> {
  TextEditingController otpController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String smssent, verificationId;
  Timer _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (mounted) {
        setState(
          () {
            if (_start < 1) {
              timer.cancel();
            } else {
              _start = _start - 1;
            }
          },
        );
      }
    });
  }

  void verifyOTP(String smsCode) async {
    var _authCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
    firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult result) {
      FirebaseUser user = result.user;

      if (user != null) {
        userAuthorized();
      }
    }).catchError((error) {
      Navigator.pop(context);
    });
  }

  userAuthorized() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your SMS one-time pin(OTP) send to",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.phoneController,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: PinCodeTextField(
                  textStyle: TextStyle(color: Colors.white),
                  controller: otpController,
                  onCompleted: (value) {
                    setState(() {
                      smssent = value;
                    });
                  },
                  onChanged: (v) {
                    smssent = v;
                  },
                  textInputType: TextInputType.number,
                  backgroundColor: Colors.transparent,
                  appContext: context,
                  pastedTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obsecureText: false,
                  animationType: AnimationType.fade,
                  /*    validator: (v) {
                if (v.length < 3) {
                  return "I'm from validator";
                } else {
                  return null;
                }
              },*/
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Waiting for OTP in  ",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$_start",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    FirebaseAuth.instance.currentUser().then((user) {
                      if (user != null) {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        Navigator.of(context).pop();
                        signedIn();
                      }
                    });

                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    child: Image.asset(
                      "assets/images/forwordicon.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  AuthCredential signIn(String smsCode) {
    AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return credential;
  }

  void validateAndSubmit() async {
    if (smssent == null || smssent.length != 6) {
      await dialog();
    } else {
      try {
        AuthCredential credential = signIn(smssent);
        try {
          Toast.show("Succesfully LogoIn", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
        } catch (e) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()));
          dialog();
        }
      } catch (e) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
        errorEmailDialog(e.toString());
      }
    }
  }

  Future<void> errorEmailDialog(String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context), child: Text('Ok'))
            ],
          );
        });
  }



  Future<void> dialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('OTP incorrect'),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context), child: Text('Ok'))
            ],
          );
        });
  }

  signedIn() {
    AuthCredential phoneAuthCredential = PhoneAuthProvider.getCredential(
        verificationId: widget.verifyid, smsCode: otpController.text.trim());
    FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .then((user) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ))
        .catchError((e) async {
      await dialog();
      });

  }
}

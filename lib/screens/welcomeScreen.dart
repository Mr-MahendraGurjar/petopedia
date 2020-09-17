import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petopedia/screens/OTPSection.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  ProgressDialog pr;

  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String countrycode, verificationId;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Please wait...');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Petopedia",
          style: TextStyle(color: Color(0xfff99733), fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    "assets/images/welcomeimage.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "Welcome",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Stay updated on sports, events and bars with \n barm8 One place for all your foody and drinky",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "By continuing you agree to Terms & Conditions. ",
                  style: TextStyle(color: Color(0xff595959), fontSize: 15),
                ),
                SizedBox(
                  height: 200,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 30, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Now serving Sdyney's best bars",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        width: double.infinity,
                        color: Color(0xff262626),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CountryCodePicker(
                                onInit: (value) {
                                  countrycode = value.toString();
                                },
                                onChanged: (value) {
                                  setState(() {
                                    countrycode = value.toString();
                                    print(countrycode);
                                  });
                                },
                                showFlagMain: false,
                                textStyle: TextStyle(color: Colors.white),
                                initialSelection: 'IN',
                                favorite: ['+91', 'IN'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                  validator: (val) {
                                    if (val.length > 10)
                                      return 'Not a valid number';
                                    return null;
                                  },
                                  controller: phoneController,
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(10),
                                    // for mobile
                                  ],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: "Enter your mobile number",
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "By entering your mobile number \n you agree to receive..",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () async {
                              verifyPhone(
                                  countrycode + phoneController.text.trim());
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              child: Image.asset(
                                "assets/images/forwordicon.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNo) async {
    await pr.show();
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      setState(() {
        verificationId = verId;
      });
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        verificationId = verId;
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {
      firebaseAuth.signInWithCredential(auth).then((AuthResult value) {
        if (value.user != null) {
          FirebaseUser user = value.user;
          pr.hide().whenComplete(() {
            Toast.show("Please Check OTP", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPSection(
                      phoneController.text, verificationId.toString()),
                ));
          });
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ));
        }
      }).catchError((error) {
        pr.hide();
        Toast.show('error : $error', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        debugPrint('error : $error');
      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      errorPhoneDialog(exception);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }


  Future<void> errorPhoneDialog(AuthException exception) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${exception.message}'),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen())),
                  child: Text('Ok'))
            ],
          );
        });
  }

}

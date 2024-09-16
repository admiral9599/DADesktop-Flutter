import 'dart:convert';
import 'dart:io';
import 'package:drive_adviser/components/startup.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import '../components/api.dart';
import '../components/universalAppBar.dart';
import 'maindata.dart';

class SignIn extends StatelessWidget {
  BuildContext? MyAppContext;
  SignIn({super.key, this.MyAppContext});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drive Adviser',
      home: MySignInPage(MyAppContext: MyAppContext),
    );
  }
}

class MySignInPage extends StatefulWidget {
  BuildContext? MyAppContext;
  MySignInPage({super.key, this.MyAppContext});

  @override
  _MySignInPage createState() => _MySignInPage();
}

///makes the brightness settings an option for future functions
enum InterfaceBrightness {
  light,
  dark,
  auto,
}

///makes the ui brightness set
extension InterfaceBrightnessExtension on InterfaceBrightness {
  bool getIsDark(BuildContext? context) {
    if (this == InterfaceBrightness.light) return false;
    if (this == InterfaceBrightness.auto) {
      if (context == null) return true;

      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    return true;
  }

  Color getForegroundColor(BuildContext? context) {
    return getIsDark(context) ? Colors.white : Colors.black;
  }
}

class _MySignInPage extends State<MySignInPage> {
  bool contactOptions = Api().contactOptions;
  bool isLoading = false; // Track loading state

  String email = Api().emailCustomer;
  String si = Api().si;
  String phoneNumber = Api().phoneNumber;

  WindowEffect effect = WindowEffect.acrylic;
  Color color = Platform.isWindows ? const Color(0xCC222222) : Colors.black12;
  InterfaceBrightness brightness = InterfaceBrightness.dark;

  @override
  void initState() {
    super.initState();
    setWindowEffect(effect);
  }

  void setWindowEffect(WindowEffect? value) {
    Window.setEffect(
      effect: value!,
      color: color,
      dark: brightness == InterfaceBrightness.dark,
    );
    setState(() => effect = value);
  }

  void setBrightness(InterfaceBrightness brightness) {
    this.brightness = brightness;
    if (this.brightness == InterfaceBrightness.dark) {
      color = Platform.isWindows ? const Color(0xCC222222) : Colors.black12;
    } else {
      color = Platform.isWindows ? const Color(0x22DDDDDD) : Colors.black12;
    }
    setWindowEffect(effect);
  }

  bool myIP = MyApp().ip;
  Map<String, dynamic> all = {};

  whatWeCollect() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(
            top: 10.0,
          ),
          title: const Text(
            "Why We Collect",
            style: TextStyle(fontSize: 24.0),
          ),
          content: SizedBox(
            height: 400,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please enter the email address you would like Drive Adviser to send notifications to in the event you experience a failure.  Email is required but sometimes gets sent to spam.  You can also optionally add your cell phone number to receive a text message in addition to an email.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        // fixedSize: Size(250, 50),
                      ),
                      child: const Text(
                        "OK!",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  errorCode(int error, BuildContext widgetContext) {
    List<String> errorcodes = [
      "Please input the SI Tag for this computer and click enter! You can type this on the keyboard or press the enter button",
      "This is not the correct information we have on file, or there was an error. Please enter the correct information associated with this computer and try again!",
      "Be sure the user's computer has been entered as an asset in the online system and that the SI has been properly set up",
      "Please input a valid email address to send notifications if there is a failing drive! (Example: newuser@Schrockinnovations.com)",
      "The phone number you have provided is either not valid, or it is too long or short. you can change this later with the contact button.",
      "You can always provide a phone number later with the contact button."
    ];
    List<String> errorTitles = [
      "Missing info!",
      "Wrong Info!",
      "New User?",
      "Missing info!",
      "Invalid phone number!",
      "Missing phone number"
    ];
    showDialog(
      context: widgetContext,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(
            top: 10.0,
          ),
          title: Text(
            errorTitles[error],
            style: const TextStyle(fontSize: 24.0),
          ),
          content: SizedBox(
            height: 400,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorcodes[error],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  (error == 4 || error == 5)
                      ? Row(
                    children: [
                      Container(
                        width: 120,
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            "Cancel",
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 120,
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              isLoading = true; // Start loading
                            });

                            Api().emailCustomer = email;
                            Api().phoneNumber = phoneNumber;
                            Api().si = si;
                            if (contactOptions) {
                              await Startup().updateUser();
                              Navigator.pop(widget.MyAppContext!);
                            }
                            else {
                              await Startup().makeJsonFileAndFillin();
                              Navigator.push(widgetContext, MaterialPageRoute(
                                builder: (context) {
                                  return MyApp();
                                },
                              ));
                              Startup().updateDriveAndBattery();
                            }

                            setState(() {
                              isLoading = false; // Start loading
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            "OK!",
                          ),
                        ),
                      ),
                    ],
                  )
                      : Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        "OK!",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  whyWeCollect() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(
            top: 10.0,
          ),
          title: const Text(
            "Why We Collect",
            style: TextStyle(fontSize: 24.0),
          ),
          content: SizedBox(
            height: 400,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please enter the email address you would like Drive Adviser to send notifications to in the event you experience a failure.  Email is required but sometimes gets sent to spam.  You can also optionally add your cell phone number to receive a text message in addition to an email.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        // fixedSize: Size(250, 50),
                      ),
                      child: const Text(
                        "OK!",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userdata = {};
    return
      // (MyApp().ip)?
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          splashFactory: InkRipple.splashFactory,
        ),
        darkTheme: ThemeData.dark().copyWith(
          splashFactory: InkRipple.splashFactory,
        ),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          appBar: UniversalAppBar("sign in menu", MyAppContext: widget.MyAppContext),
          body: Column(children: [
            (myIP)
                ? Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                readOnly: true,
                controller: TextEditingController()..text = email,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email (Fill in Si tag and click "Enter")',
                  hintText: 'This field is auto populated by the SI tag',
                ),
                minLines: 1,
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                readOnly: false,
                controller: TextEditingController()..text = email,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email Address (Required)',
                  hintText: 'Enter valid Email Address',
                ),
                onChanged: (value) => email = value,
                minLines: 1,
              ),
            ),
            (myIP)
                ? Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: TextEditingController()..text = si,
                    keyboardType: TextInputType.number, // Set the keyboard type to number
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'SI Tag',
                      hintText: 'Enter The SI tag',
                    ),
                    onChanged: (value) => si = value,
                    onEditingComplete: () async {
                      try {
                        await Api().checkSI(si).then((value) async {
                          userdata = jsonDecode(value);
                          all = userdata["all"];
                          email = all["Email"];
                          phoneNumber = all["HomePhone"];

                          setState(() {});
                        });
                      } catch (e) {
                        email = "Error";
                      }

                    },
                    onSubmitted: (value) async {
                      si = value;
                      setState(() {});
                      await Api().checkSI(si).then((value) async {
                        userdata = jsonDecode(value);
                        all = userdata["all"];
                        email = all["Email"];
                        if (all["PrimaryPhone"] == "613") {
                          phoneNumber = all["HomePhone"];
                        } else if (all["HomePhone"] == "612") {
                          phoneNumber = all["PrimaryPhone"];
                        } else {
                          phoneNumber = all["HomePhone"];
                        }
                        setState(() {});
                      });

                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        try {
                          await Api().checkSI(si).then((value) async {
                            userdata = jsonDecode(value);
                            all = userdata["all"];
                            email = all["Email"];
                            if (all["PrimaryPhone"] == "613") {
                              phoneNumber = all["HomePhone"];
                            } else if (all["HomePhone"] == "612") {
                              phoneNumber = all["PrimaryPhone"];
                            } else {
                              phoneNumber = all["HomePhone"];
                            }
                            setState(() {});
                          });
                        } catch(_) {}
                      },
                      child: const Text("Enter")),
                ],
              ),
            )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                  controller: TextEditingController()..text = phoneNumber,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number (optional)',
                    hintText: 'Enter the 10 Digit Phone Number',
                  ),
                  onChanged: (value) => phoneNumber = value),
            ),
            TextButton(
              onPressed: () {
                whyWeCollect();
              },
              child: const Text(
                'Why Do we collect this information?',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: isLoading
                    ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Loading...')
                  ],
                )
                    : TextButton(
                    onPressed: () async {
                      if (!context.mounted) {
                        return;
                      }
                      bool simatches = false;
                      try {
                        await Api().checkSI(si).then((value) async {
                          userdata = jsonDecode(value);
                          all = userdata["all"];
                          simatches = userdata["success"];
                        });
                      } catch(e) {}
                      if ((email == "" || si == "") && myIP) {
                        errorCode(0, context);
                      }
                      else if (simatches== false&&myIP){
                        errorCode(1, context);
                      }
                      else if (email == "Error") {
                        errorCode(2, context);
                      }
                      else if (EmailValidator.validate(email) == false) {
                        errorCode(3, context);
                      }
                      else if (phoneNumber.length != 10 &&
                          phoneNumber.isNotEmpty) {
                        errorCode(4, context);
                      }
                      else if (phoneNumber.isEmpty) {
                        errorCode(5, context);
                      } else {
                        setState(() {
                          isLoading = true; // Start loading
                        });

                        Api().emailCustomer = email;
                        Api().phoneNumber = phoneNumber;
                        Api().si = si;
                        if (contactOptions) {
                          await Startup().updateUser();
                          Navigator.pop(widget.MyAppContext!);
                        }
                        else {
                          try {
                            await Startup().makeJsonFileAndFillin();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return MyApp();
                              },
                            ));
                            Startup().updateDriveAndBattery();
                          } catch(e) {
                            Logger.log("Sign in err=${e.toString()}");
                            Api().saveLogToFile();
                          }
                        }

                        setState(() {
                          isLoading = false; // Start loading
                        });
                      }
                    },

                    ///todo this is the end of the button press
                    child: (contactOptions == false)
                        ? const Text(
                      'launch',
                      style:
                      TextStyle(color: Colors.white, fontSize: 25),
                    )
                        : const Text(
                      'Save',
                      style:
                      TextStyle(color: Colors.white, fontSize: 25),
                    )))
          ]),
        ),
      );
  }
}

import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drive_adviser/components/startup.dart';
import 'package:drive_adviser/screens/maindata.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../lib2/app.dart';
import '../screens/datapage.dart';
import '../screens/signon.dart';
import 'api.dart';

class UniversalAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String appName; // Declare the variable here
  BuildContext? MyAppContext;
  UniversalAppBar(this.appName, {super.key, this.MyAppContext});

  @override
  State<StatefulWidget> createState() => _UniversalAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UniversalAppBar extends State<UniversalAppBar> {
  void _openFile() async {
    String filePath = "${MyApp().PATH_PROGRAMDATA}/Drive Adviser/driveadviser.json";
    String filePath2 = "${MyApp().PATH_PROGRAMDATA}/Drive Adviser/log.txt";
    // For Windows
    await Process.start('notepad.exe', [filePath], runInShell: true);
    await Process.start('notepad.exe', [filePath2], runInShell: true);
    // If you are targeting multiple platforms, you might need to adjust
    // the command based on the operating system.
  }

  ///the bool responsible for making the size change
  final double _bigXAxis = 376;
  final double _bigYAxis = 400;

  @override
  Widget build(BuildContext context) {
    final AppBar appBar;

    String appName = widget.appName;
    if (appName == "main data page") {
      appBar = AppBar(
        actions: [
               Row(
            children: [
              (MyApp().ip)?
              IconButton(onPressed: () async {
                  final Uri url = Uri.parse(
                    'https://docs.google.com/forms/d/e/1FAIpQLSdNIxUHOmK9cs_Vx80pa8oTHmuclb7M285OO9BSRGMx0cDLTQ/viewform?usp=sf_link',
                  );
                  if (!await launchUrl(url)) {
                    throw Exception(
                      'Could not launch $url',
                    );
                  }
                  _openFile();
                // await _openFile;
              }, icon: const Icon( Icons.bug_report)):Container(),
              ///this is the icon for the refresh button
              IconButton(
                onPressed: () async {
                  await Startup().loadHardwareInfo();
                  setState(() {});
                  Startup().updateDriveAndBattery();
                },
                icon: const Icon(Icons.refresh),
              ),

              ///this is the icon to change the sign in information
              IconButton(
                onPressed: () async {
                  final SnackBar snackBar = SnackBar(
                    content: const Text(
                      "Click contact options to change your email or your phone number",
                    ),
                    action: SnackBarAction(
                      label: 'Contact Options',
                      onPressed: () {
                        click = true;
                        Api().contactOptions = true;
                        appWindow.size = Size(_bigXAxis, _bigYAxis);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  SignIn(MyAppContext: context),
                          ),
                        );
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(Icons.email),
              ),

              ///this is the icon that brings the user to the more information page
              ///this still works fine. no need to change this.
              IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HardwareInfoScreen(),
                    ),
                  );

                },
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),


          ///drive adviser button
          TextButton(
            child: Row(
              children: [
                Image.asset(
                  'images/drive Adviser Logo pin.png',
                  fit: BoxFit.scaleDown,
                  scale: 4,
                ),
                const Text("Drive",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const Text(
                  "Adviser",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w100),
                ),
              ],
            ),
            onPressed: () async {
              final Uri url = Uri.parse(
                'http://www.driveadviser.com/#faq',
              );
              if (!await launchUrl(url)) {
                throw Exception(
                  'Could not launch $url',
                );
              }
            },
          ),

          ///arrows button
          IconButton(
            onPressed: () {
              appWindow.hide();
            },
            icon: const Icon(
                 Icons.arrow_downward),
          ),
        ],
        automaticallyImplyLeading: false,
      );
    }
    else if(appName == "dataPage") {
      appBar = AppBar(
        title: const Text('Hardware Info'),
        leading: IconButton(onPressed: () {
          appWindow.restore();
          Api().contactOptions = false;
          Navigator.pop(context);
        }, icon: const Icon(Icons.home)),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApp2(),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),


          (MyApp().ip)?
          IconButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLSdNIxUHOmK9cs_Vx80pa8oTHmuclb7M285OO9BSRGMx0cDLTQ/viewform?usp=sf_link',
                );
                if (!await launchUrl(url)) {
                  throw Exception(
                    'Could not launch $url',
                  );
                }
                _openFile();
              }, icon: const Icon( Icons.bug_report)):Container(),
          IconButton(
            onPressed: () {
              appWindow.hide();
            },
            icon: const Icon(
                Icons.arrow_downward),
          ),
        ],
      );
    }
    else {
      bool contactOptions = Api().contactOptions;

      appBar = AppBar(
        leading: (contactOptions)?IconButton(onPressed: () {
          Api().contactOptions = false;
          Navigator.pop(widget.MyAppContext!);
        }, icon: const Icon(Icons.arrow_back)):Container(),
        actions: [
          (MyApp().ip)?
          IconButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLSdNIxUHOmK9cs_Vx80pa8oTHmuclb7M285OO9BSRGMx0cDLTQ/viewform?usp=sf_link',
                );
                if (!await launchUrl(url)) {
                  throw Exception(
                    'Could not launch $url',
                  );
                }
                _openFile();
              },
              icon: const Icon( Icons.bug_report)):Container(),

          TextButton(
            child: Row(
              children: [
                Image.asset(
                  'images/drive Adviser Logo pin.png',
                  fit: BoxFit.scaleDown,
                  scale: 4,
                ),
                const Text("Drive",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const Text(
                  "Adviser",
                  style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
                ),
              ],
            ),
            onPressed: () async {
              final Uri url = Uri.parse(
                'http://www.driveadviser.com/#faq',
              );
              if (!await launchUrl(url)) {
                throw Exception(
                  'Could not launch $url',
                );
              }
            },
          ),
          IconButton(
            onPressed: () {
              appWindow.hide();
            },
            icon: const Icon(
                Icons.arrow_downward),
          ),
        ],
      );
    }
    return appBar;
  }
}

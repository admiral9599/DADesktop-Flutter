import 'dart:async';
import 'package:drive_adviser/components/universalAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import '../components/api.dart';
import 'dart:io';

class MyApp extends StatelessWidget {
  static final MyApp _instance = MyApp._internal();
  String PATH_PROGRAMDATA = "";
  String PATH_OSDRIVE = "";
  bool ip = false;
  bool started = false;
  bool error = false;
  Map daJSON = { "data": {} };

  factory MyApp() {
    return _instance;
  }

  MyApp._internal();

  // rest of your class

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
      ),
      darkTheme: ThemeData.dark().copyWith(
        splashFactory: InkRipple.splashFactory,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
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

///the bool responsible for making the size change
bool click = false;

class _MyHomePageState extends State<MyHomePage> {

  WindowEffect effect = WindowEffect.acrylic;
  Color color = Platform.isWindows ? const Color(0xCC222222) : Colors.black12;
  InterfaceBrightness brightness = InterfaceBrightness.dark;

  ///This tries to get the battery data and converts it into a string.
  Future<Widget> getBattData() async {
    if (!Api().batteryExists) {
      return Container();
    }
    else {
      int battH = Api().batteryHealth;

      return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black87,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                flex:1,
                fit: FlexFit.tight,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.battery_full),
                          Text("Battery"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  children: [
                    (battH >= 80)
                        ? Tooltip(
                            message: "$battH%",
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.green,
                            ),
                          )
                        : (battH < 80 && battH >= 50)
                            ? Column(children: [
                                Tooltip(
                                  message: "$battH%",
                                  child: const Icon(
                                    Icons.heart_broken,
                                    color: Colors.yellow,
                                  ),
                                ),
                                Text("$battH%")
                              ])
                            : Tooltip(
                                message: "$battH%",
                                child: const Icon(
                                  Icons.heart_broken,
                                  color: Colors.red,
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

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

  List<Widget> _buildSpecificAttributeDisplays() {
    List<Widget> attributeDisplays = [];

    for (int i = 0; i < Api().driveName.length; i++) {
      String name = Api().driveName[i];
      String driveDetails = "DriveLetter: ${Api().driveLetter[i]}";
      String type = Api().typeList[i];
      String temperature = Api().temperature[i];
      int health = double.parse(Api().driveHealth[i]).toInt();
      String issues = Api().issues[i];
      String tooltipContent = 'Logical Disk: ${Api().disk[i]}\nSize: ${Api()
          .driveCapacity[i]}';
      Widget? tooltip;

      if (health == 100) {
        tooltip = Tooltip(
          message: "There is no issues with your drive.",
          child: Text.rich(
            TextSpan(children: [
              const WidgetSpan(
                  child: Icon(Icons.favorite, color: Colors.green)),
              TextSpan(text: '${health.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ],
            ),
          ),
        );
      }
      else {
        IconData iconData = Icons.heart_broken;
        Color iconColor = Colors.red;

        if (health >= 90) {
          iconData = Icons.favorite;
          iconColor = Colors.green;
        } else if (health >= 80) {
          iconData = Icons.heart_broken;
          iconColor = Colors.yellow;
        }
        tooltip = Tooltip(
          message: "There are some issues with this drive. Click the health to find out more.",
          child: TextButton(
            child: Text.rich(
              TextSpan(children: [
                WidgetSpan(child: Icon(iconData, color: iconColor)),
                TextSpan(text: '${health.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),)
              ],
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Drive Health Issues"),
                    content: SingleChildScrollView(
                        child: SelectableText(
                            "The $type drive is at $health%\nThe drive Temperature is $temperature°\n$issues")),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the dialog
                        },
                      ),
                      // You can add more actions here if needed
                    ],
                  );
                },
              );
            },
          ),
        );
      }

      attributeDisplays.add(Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1, // Equal flex value for both containers
            fit: FlexFit.tight,
            child: Tooltip(
              message: tooltipContent,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        driveDetails,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1, // Equal flex value for both containers
            fit: FlexFit.tight,
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  tooltip,
                  (MyApp().ip) ?
                  (int.parse(temperature) <= 0) ?
                  Container() :
                  Text(
                    '$temperature°',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ) : Container()
                ],
              ),
            ),
          ),
        ],
      ));
    }
    return attributeDisplays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar("main data page"),
      body: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ..._buildSpecificAttributeDisplays(),
          FutureBuilder(
            future: getBattData(),
            builder: (context, snapshot) {
              Widget release = const Column(
                children: [
                  CircularProgressIndicator(),
                  Text("loading"),
                ],
              );
              if (snapshot.connectionState == ConnectionState.done) {
                release = snapshot.data!;
              } else if (snapshot.hasError) {
                release = Text("${snapshot.error}");
              }

              return release;
            },
          )
        ],
      )),
    );
  }
}
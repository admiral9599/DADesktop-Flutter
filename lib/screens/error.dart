import 'package:flutter/material.dart';
import 'dart:io' as io;

class ErrorApp extends StatelessWidget {
  static final ErrorApp _instance = ErrorApp._internal();
  bool ip = false;
  bool started = false;

  factory ErrorApp() {
    return _instance;
  }

  ErrorApp._internal();

  // rest of your class

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text.rich(
            WidgetSpan(
              child: Row(
                children: [
                  Image(image: AssetImage("images/drive Adviser Logo pin.png"),height: 20),
                  Text("Administrator Access denied!")
                ]
              )
            )
          )
        ),
        body: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text("There was an error Activating the automatic Administrator Access, please run the application as Administrator.")
              ),
              TextButton(
                onPressed: () async {
                  io.exit(0);
                },
                child: const Text("Ok, Exit")
              )
            ]
          )
        )
      ),
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


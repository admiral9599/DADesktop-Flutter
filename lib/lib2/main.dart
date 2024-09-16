import 'package:drive_adviser/lib2/util.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main2() {
  WidgetsFlutterBinding.ensureInitialized();
  List<String> drivesList = MyFFI().receivedInitializedVisualStudio();
  if (drivesList.isNotEmpty) {
    MyFFI().dartStringList = MyFFI().receivedDiskInformations(0);
    MyFFI().processDataFromFlutter(0);
  }
  // print(
  //     'Received dynamically prepared CString array from Visual Studio: ${drivesList.first}');

  runApp(const App2());
}

class App2 extends StatelessWidget {
  const App2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollbarTheme = ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(scrollbarTheme: scrollbarTheme),
      darkTheme: ThemeData.dark().copyWith(scrollbarTheme: scrollbarTheme),
      title: 'Drive Adviser Info Collected',
      home: const MyApp2(),
    );
  }
}

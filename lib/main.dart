import 'dart:async';
import 'package:drive_adviser/components/startup.dart';
import 'package:drive_adviser/info/hardDriveInfo.dart';
import 'package:drive_adviser/screens/error.dart';
import 'package:drive_adviser/screens/maindata.dart';
import 'package:drive_adviser/screens/signon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_tray/system_tray.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'components/api.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

Future initApp() async {
  await ComputerInfoGetter().runAsAdminFile();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize path variables
  String? path = Platform.environment['PROGRAMDATA'];
  if (path != null) {
    MyApp().PATH_PROGRAMDATA = path;
    MyApp().PATH_OSDRIVE = path.substring(0, 3);
  }
  else {
    path = Platform.environment['SYSTEMDRIVE'];
    MyApp().PATH_PROGRAMDATA = "$path/ProgramData";
    MyApp().PATH_OSDRIVE = "$path/";
  }

  // Create DriveAdviser folder
  String folderPath = "${MyApp().PATH_PROGRAMDATA}/Drive Adviser";
  Directory directory = Directory(folderPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // Download files
  if(Api().test) {
    await Startup().downloadFile(
       "https://driveadviser.com/driveAdviser_remake/download/installtest.ps1",
       "installtest.ps1");
  }
  else{
    await Startup().downloadFile(
       "https://driveadviser.com/driveAdviser_remake/download/install.ps1",
       "install.ps1");
  }
}

Future<void> initSystemTray() async {
  String path =
  Platform.isWindows ? 'images/app_icon.ico' : 'images/app_icon.ico';

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    title: "system tray",
    iconPath: path,
  );

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
    MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}

Future<void> main(List<String> args) async {
  double bigXAxis = 376;
  double bigYAxis = 400;

  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  await Window.initialize();
  if (Platform.isWindows) {
    await Window.hideWindowControls();
  }

  WindowOptions windowOptions = const WindowOptions(
    skipTaskbar: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..size = Size(bigXAxis, bigYAxis)
        ..alignment = Alignment.bottomRight
        ..show();
    });
  }

  await initSystemTray();
  await Startup().universalStartup();

  if(MyApp().error == true){
    runApp(ErrorApp());
    Logger.log("There was an error in activating the application auto admin launch");
    await Api().saveLogToFile();
  }
  else{
    if (MyApp().started == false) {
      await Startup().preSignInStartup();
      if (MyApp().started == false) {
        runApp(SignIn());
      } else {
        await Startup().loadHardwareInfo();
        runApp(MyApp());
        Startup().updateDriveAndBattery();
        Api().saveLogToFile();
      }
    } else {
      await Startup().loadHardwareInfo();
      runApp(MyApp());
      Startup().updateDriveAndBattery();
      Api().saveLogToFile();
    }
  }
}

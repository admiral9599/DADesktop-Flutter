import 'dart:io';
import 'dart:io' as io;
import 'dart:convert';
import 'package:drive_adviser/lib2/util.dart';
import 'package:process_run/process_run.dart';
import '../screens/maindata.dart';
import 'package:crypto/crypto.dart';

class DriveInfoSaver {
  ///Gets the computer info and maps it
  Future digup(String userEmail, String compID, String si) async {
    try {
      Map computerData = MyApp().daJSON;
      computerData["data"]["wkey"] = await ComputerInfoGetter().getWKey();
      await writeFile("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/driveadviser.json", json.encode(computerData));
    } catch (_) {}
  }
}

class ComputerInfoGetter {
  static final ComputerInfoGetter _instance = ComputerInfoGetter._internal();
  factory ComputerInfoGetter() {
    return _instance;
  }
  ComputerInfoGetter._internal();

  Future<String> getWKey() async {
    String macAddr = await runcmd(
        "wmic",
        ["nic", "get", "MACAddress"],
        'MACAddress'
    );
    return md5.convert(utf8.encode(macAddr)).toString();
  }

  Future<String> getComputerName() async {
    return runcmd(
        "wmic",
        [
          'computersystem',
          'get',
          'name'
        ],
        'name'
    );
  }

///this checks the internet
  Future ping() async{
    String pong = await runcmd(
        "ping",
        [
          "schrockinnovations.com"
        ],
        null
    );
    return !pong.contains("Ping request could not find host");
  }

  Future runAsAdminFile() async {
    final shell = Shell();
    try {
      List<ProcessResult> result = await shell.run(
          '''powershell -Command "If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Output 'True' } Else { Write-Output 'False' }"''');
      bool isAdmin = ((result.first.stdout as String).trim() == 'True');
      if (!isAdmin) {
        result = await shell.run(
            '''powershell -Command "Get-StartApps"''');
        List<String> appNames = (result.first.stdout as String).split("\r\n");
        String appName = '';
        for (String str in appNames) {
          if (str.startsWith("Drive Adviser")) {
            appName = str.substring("Drive Adviser".length).trim();
            break;
          }
        }
        if (appName.isEmpty) {
          throw Exception("");
        }
        await shell.run('''powershell -Command "Start-Process 'shell:AppsFolder\\$appName' -Verb RunAs"''');
        io.exit(0);
      }
    } catch(e) {
      MyApp().error = true;
    }
    try {
      await shell.run('''powershell -Command "Set-ExecutionPolicy RemoteSigned -Force"''');
    } catch(e) {}
  }

  Future<String> runcmd(String executable, List<String> arguments, String? regExpSource) async {
    String result = '';
    try {
      final process = await Process.start(
        executable,
        arguments,
        mode: ProcessStartMode.normal,
      );

      String output = (await process.stdout.transform(utf8.decoder).toList()).join();
      if (regExpSource == null) {
        return output;
      }

      final lines = output.split("\r\n").where((value) => value.trim().isNotEmpty).toList();
      int i = 0;
      regExpSource = regExpSource.toLowerCase();
      for (i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains(regExpSource)) {
          break;
        }
      }

      if (i < lines.length - 1) {
        result = lines[i + 1].trim();
      }
    } catch (_) {}

    return result;
  }
}

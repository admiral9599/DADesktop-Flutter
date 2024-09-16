import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:drive_adviser/screens/maindata.dart';
import 'package:html/parser.dart';
import 'package:process_run/process_run.dart';
import '../info/hardDriveInfo.dart';
import '../lib2/app.dart';
import '../lib2/util.dart';
import 'api.dart';
import 'package:http/http.dart'as http;
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class Startup {
  static final Startup _instance = Startup._internal();
  factory Startup() {
    return _instance;
  }
  Startup._internal();

  ///todo///////////////////////change the version number to match the current pubspec.yaml//////////////////////////////////////////////////
  String currentVersion = (Api().test)?"1.6.4":"1.6.1";
  ///this is the user's IP variable
  String myIp = "";
  List<String> attributesToFind = [
    'Read Error Rate',
    'Percentage Used',
    'Available Spare',
    'Vendor Specific',
    '231',
    'Available Reserve Space',
    'Uncorrectable Error Count',
    'Critical Warning',
    'Grown Bad Blocks',
    'Power-On Hours',
    'Power-on Hours',
    'Power On Hours',
    'Program Fail Count (Total)',
    'Runtime Bad Block (Total)',
    'Wear Leveling Count',
    'Used Reserved Block Count (Total)',
    'Used Reserved Block Count (Chip)',
    'Spin Up Time',
    'Reallocated Sectors Count',
    'Seek Error Rate',
    'Spin Retry Count',
    'End-to-End Error Count',
    'End-to-End Error',
    'Reallocation Event Count',
    'Current Pending Sector Count',
    'Off-Line Uncorrectable Sector Count',
    'Write Error Rate',
    'Number of Valid Spare Blocks',
    'Remaining Life Percentage',
    'Remain Life',
    'Uncorrectable Sectors Count',
    'Power on Hours',
    'SSD Wear Indicator',
    'Power On Time Count',
    'Critical Warning',
    'Unsafe Shutdowns',
    'Media and Data Integrity Errors',
    'Super cap Status',
    'Error Detection',
    'Power on Hours',
    'Bad Block Count',
    'SSD Life Left',
    'Spin-Up Time',
    'Uncorrectable Sector Count',
    'Number of CRC Error',
    'Power-on Count',
    'Media Wearout Indicator',
  ];
  List<String> tempAttributesToFind = [
    'Temperature',
    'Disk Temperature',
    'Composite Temperature',
    'Airflow Temperature',
  ];

  Future<void> loadHardwareInfo() async {
    ///This tries to get the battery data and converts it into a string.
    try {
      final shell = Shell();
      await shell.run('powercfg /batteryreport /output "${MyApp()
          .PATH_PROGRAMDATA}/batter-report.txt"');
      String batteryDataFull = await readFile(
          "${MyApp().PATH_PROGRAMDATA}/batter-report.txt");

      final document = parse(batteryDataFull);
      final editedDocument = document.documentElement!.text;
      if (!(editedDocument.contains("No batteries are currently installed") ||
          editedDocument == "There was an error")) {
        List<String> dataListOne = editedDocument.split("DESIGN CAPACITY");
        List<String> dataListTwo = editedDocument.split("FULL CHARGE CAPACITY");
        List<String> dataOne = dataListOne[1].split("mWh");
        List<String> dataTwo = dataListTwo[1].split("mWh");
        double manCap = double.parse(dataOne[0].replaceAll(",", ""));
        double maxCap = double.parse(dataTwo[0].replaceAll(",", ""));
        int battH = (maxCap * 100 / manCap).toInt();
        Api().batteryHealth = battH;
        Api().batterycap = manCap.toInt();
        Api().batMaxCap = maxCap.toInt();
        Api().batteryExists = true;
        DataLogger.log({
          "batteryData": {
            "batteryHealth": Api().batteryHealth,
            "batterycap": Api().batterycap,
            "batMaxCap": Api().batMaxCap
          }
        });
        if (battH < 80) {
          await Api().emailBatteryHealth(battH);
        }
      }
    } catch(e) {}

    // Initialize drive data
    List<DriveData> allDriveData = [];
    List<String> drivesList = MyFFI().receivedInitializedVisualStudio();
    Api().driveLetter.clear();
    Api().driveName.clear();
    Api().driveCapacity.clear();
    Api().disk.clear();
    Api().typeList.clear();
    Api().storageFree.clear();
    Api().existingDataIdentifiers.clear();
    Api().temperature.clear();
    Api().issues.clear();
    for (int i = 0; i < drivesList.length; i++) {
      // Fetch data for each drive and store it
      var stringList = MyFFI().receivedDiskInformations(
          i); // This should return the updated list for each drive
      // Assuming receivedDiskInformations now correctly updates dartIntArray and dartIdArray
      DriveData driveData = DriveData(
          driveIdentifier: drivesList[i],
          stringList: stringList,
          intList: List.from(MyFFI().dartIntArray),
          idList: List.from(MyFFI().dartIdArray),
          worstList: List.from(MyFFI().dartWorstArray),
          // Assuming you fetched this similarly
          thresholdList: List.from(MyFFI().dartThresholdArray),
          // Assuming you fetched this similarly
          rawvalueList: List.from(MyFFI().dartRawValueList));
      allDriveData.add(driveData);
    }

    for (var driveData in allDriveData) {
      var foundAttributes = driveData.findAttributes(attributesToFind);
      var foundAttributes2 = driveData.findAttributes(tempAttributesToFind);
      Map mapCalcHealth = driveData.calculateHealth(foundAttributes);
      double health = (mapCalcHealth["health"])
          .toDouble(); // Calculate health
      String issues = mapCalcHealth["Issues"];
      String temperature =
      driveData.calculateTemp(foundAttributes2)["Temperature"];
      // Extracting values from driveIdentifier for tooltip content
      var parts = driveData.driveIdentifier.split(":");
      String disk = parts[0].trim();
      String name = parts[1].trim();
      String size = parts[2].replaceAll(RegExp(r'[^0-9]'), "").trim();
      String driveLetter = parts[3].trim();
      if(driveLetter == ""){
        driveLetter = "unformatted or raw";
      }
      String percentFree = "";
      String  totalCapacity = "";

      String totalCapacityunformatted = "";
      int totalCapacityint = 0;
      try{
        percentFree = (parts[4].trim().split("GB")[0].replaceAll("[", "").split("/")[0]).replaceAll(RegExp(r'[^0-9]'), "");
      }
      catch(e){
        percentFree= size;
      }

      try{
        totalCapacityunformatted = (parts[4].trim().split("GB")[0].replaceAll("[", "").split("/")[1]).replaceAll(RegExp(r'[^0-9]'), "");
        try{
          totalCapacityint = int.parse(totalCapacityunformatted);
        }
        catch(e){
          totalCapacityint = int.parse((totalCapacityunformatted.split(" ")[1]));
        }
        totalCapacity = "$totalCapacityint";
      }
      catch(e){
        totalCapacity= size;
      }

      try {
        // Construct a unique identifier for the current data based on driveLetter, driveName, and disk
        String uniqueIdentifier = "$driveLetter-$name-$disk";

        // Check if the unique identifier already exists
        if (!Api().existingDataIdentifiers.contains(uniqueIdentifier)) {
          // Since it's not a duplicate, add the data to your lists
          Api().driveLetter.add(driveLetter);
          Api().driveName.add(name);
          Api().driveHealth.add("$health");
          Api().disk.add(disk);
          Api().driveCapacity.add(size);
          Api().totalAvailable.add(totalCapacity);
          Api().storageFree.add(percentFree);
          Api().temperature.add(temperature);
          Api().issues.add(issues);

          // Don't forget to add the unique identifier to your set to track this new entry
          Api().existingDataIdentifiers.add(uniqueIdentifier);
          int fullcapacity = 1;
          if (totalCapacityint == 0){
            fullcapacity = int.parse(percentFree);
          }
          else{
            fullcapacity = totalCapacityint;
          }
          DataLogger.log({
            "driveNumber$disk": {
              "dOLC": "${DateTime.now()}",
              "driveName": name,
              "diskNumber": disk,
              "driveHealth": health,
              "driveRemainingCapacity": (((int.parse(percentFree) *
                  100)) / fullcapacity).round()
            }
          });
        }
      } catch (e) {}
    }

    await loadComputerDetail();
  }

  Future<void> loadComputerDetail() async {
    final buffer = calloc<ffi.Int8>(4096); // Ensure the buffer is large enough
    MyFFI().getDriveInfo(buffer, 4096);
    String allData = buffer.cast<Utf8>().toDartString();
    calloc.free(buffer);

    // Split the data into parts
    final parts = allData.split('|');
    final String allSerialNumbers = parts[0];
    final String totalMemory = parts.length > 1 ? parts[1] : "Unknown";
    final String cpuSpeed = parts.length > 2 ? parts[2] : "Unknown";
    final String osNumber = parts.length > 4? parts[4] : "Unknown";
    final String cpuName = parts.length > 5? parts[5] : "Unknown";

    Api().serialNumbers = allSerialNumbers.split('\n').where((sn) => sn.isNotEmpty).toList();
    String osVersionID = "";
    String osVersionName = "";
    switch (osNumber) {
      case "10.0.10240":
        osVersionID = "1507";
        break;
      case "10.0.10586":
        osVersionID = "1511";
        break;
      case "10.0.14393.1794":
        osVersionID = "1607";
        break;
      case "10.0.15063.674":
        osVersionID = "1703";
        break;
      case "10.0.16299.19":
        osVersionID = "1709";
        break;
      case "10.0.17134":
        osVersionID = "1803";
        break;
      case "10.0.17763.55":
        osVersionID = "1809";
        break;
      case "10.0.18362.239":
        osVersionID = "1903";
        break;
      case "10.0.18363":
        osVersionID = "1909";
        break;
      case "10.0.19041":
        osVersionID = "2004";
        break;
      case "10.0.19042":
        osVersionID = "20H2";
        break;
      case "10.0.19043":
        osVersionID = "21H1";
        break;
      case "10.0.19044":
        osVersionID = "21H2";
        break;
      case "10.0.19045":
        osVersionID = "22H2";
        break;
      case "10.0.22000":
        osVersionID = "21H2";
        break;
      case "10.0.220001042":
        osVersionID = "21H2";
        break;
      case "10.0.22621":
        osVersionID = "22H2";
        break;
      case "10.0.22631":
        osVersionID = "23H2";
        break;
      default:
        osVersionID = "unknown";
    }
    switch (osVersionID) {
      case "1507":
      case "1511":
      case "1607":
      case "1703":
      case "1709":
      case "1803":
      case "1809":
      case "1903":
      case "1909":
      case "2004":
      case "20H2":
      case "21H1":
        osVersionName = "Windows 10";
        break;
      case "21H2":
        if(osNumber == "10.0.19044")
        {
          osVersionName = "Windows 10";
        } else {
          osVersionName = "Windows 11";
        }
        break;
      case "22H2":
        if(osNumber == "10.0.19045"){
          osVersionName = "Windows 10";
        } else{
          osVersionName = "Windows 11";
        }
        break;
      case "23H2":
        osVersionName = "Windows 11";
        break;
      default:
        osVersionName = "unknown";
    }

    Map dacomputerData = MyApp().daJSON;
    dacomputerData["data"]["cpu"]= cpuName.trim();
    dacomputerData["data"]["os"]= osVersionName;
    dacomputerData["data"]["buildVersion"]= osVersionID;
    dacomputerData["data"]["cpuSpeed"]= cpuSpeed;
    dacomputerData["data"]["ramCapacity"]= totalMemory;
    dacomputerData["data"]["hddCapacity"]= Api().driveCapacity[0];
    dacomputerData["data"]["osDriveLetter"] = Api().driveLetter[0];
    dacomputerData["data"]["active"] = 1;
    dacomputerData["data"]["dateCreated"] = "${DateTime.now()}";
    dacomputerData["data"]["totalCapacity"] = Api().driveCapacity[0];
    dacomputerData["data"]["freeSpace"] = Api().storageFree[0];
    dacomputerData["data"]["driveType"] = Api().typeList[0];
  }

  Future<void> universalStartup() async {
    try {
      MyApp().ip = await Api().checkIp();
    } catch (e) {
      Logger.log("The check IP is having an error $e");
    }

    try {
      Shell shell = Shell();
      String installFile = Api().test ? 'installtest' : 'install';
      await shell.run(
          'powershell -file "${MyApp().PATH_PROGRAMDATA}/Drive adviser/${installFile}.ps1" $currentVersion');
    } catch(_) {}

    try {
      MyApp().daJSON = jsonDecode((await readFile("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/DriveAdviser.json")));
      Api().emailCustomer = MyApp().daJSON["data"]["user_email"];
      Api().phoneNumber = "${MyApp().daJSON["data"]["phone_number"]}";
      Api().compID = "${MyApp().daJSON["data"]["id_computer"]}";
      Api().si = "${MyApp().daJSON["data"]["siTag"]}";
      if (MyApp().ip == true && Api().si != "") {
        MyApp().started = true;
      } else if (MyApp().ip == false) {
        MyApp().started = true;
      }
      ///-------------------------------Universal Tasks---------------------------------------
    } catch (e) {
      await Api().saveLogToFile();
    }
  }

  /// the pre startup tasks
  Future<void> preSignInStartup() async {
    try {
      /// This is the list of tasks unique to pre sign in:
      ///1. Check old Drive Adviser Files and assign the values in the Api() function.
      ///2. Delete the old Drive Adviser File and Sign in if applicable, and if not, move on.
      ///3. Check if The program has already initialized and if the initialization has an SI saved or not.

      ///-------------------------------Pre Start up Tasks -----------------------------------

      ///1. Check old Drive Adviser Files and assign the values in the Api() function.

      await Api().getOldDAInfo();

      ///-----------------------------------------------------------------------------------

      ///2. Check if The program has already initialized and if the initialization has an SI saved or not.
      Map dacomputerdata = MyApp().daJSON;
      Api().emailCustomer = dacomputerdata["data"]["user_email"];
      if (Api().emailCustomer != "") {
        if (Api().si != "") {
          MyApp().started = true;
        } else if (MyApp().ip == false) {
          MyApp().started = true;
        }
      }

      ///-----------------------------------------------------------------------------------
    } catch (e) {}
  }

  Future<void> downloadFile(String url, String fileName) async {
    File file = File("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/$fileName");

    // Check if the file exists
    if (file.existsSync()) {
      // Delete the file
      file.deleteSync();
    }

    // Download file
    await http.get(Uri.parse(url)).then((response) {
      file.writeAsBytesSync(response.bodyBytes);
    }).catchError((err) {});
  }

  ///---------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> updateUser() async {
    try {
      String email = Api().emailCustomer;
      String phoneNumber = Api().phoneNumber;
      String userID = MyApp().daJSON["data"]["user_id"];

      await Api().updateUser(userID, email, phoneNumber);
    } catch (e) {
    }
  }

  Future<void> updateDriveAndBattery() async {
    try {
      String existingData = await readFile("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/Datalog.json");
      Map<String, dynamic> existingJson = existingData.isNotEmpty ? json.decode(existingData) : {};
      bool shouldUpdate = false;
      Map daData = MyApp().daJSON;

      for (var newMessage in DataLogger.getMessages()) {
        String key = newMessage.keys.first;
        Map<String, dynamic> info = newMessage[key];

        if (key == "batteryData") {
          if (!existingJson.containsKey(key)) {
            shouldUpdate = true;
            existingJson[key] = info;
          }
          else if (existingJson[key]['batteryHealth'] != info['batteryHealth'] ||
              existingJson[key]['batterycap'] != info['batterycap'] ||
              existingJson[key]['batMaxCap'] != info['batMaxCap']) {
            shouldUpdate = true;
            existingJson[key] = info;
            try {
              await Api().saveBattery(Api().batterycap, Api().batMaxCap,
                  Api().batterycap, int.parse(daData["data"]["id_computer"]),
                  daData["data"]["wkey"], Api().batteryHealth)
                  .then((value) async {
                daData["data"]["battery_id"] = json.decode(value)["batteryId"];
                await writeFile("${MyApp()
                    .PATH_PROGRAMDATA}/Drive Adviser/driveadviser.json",
                    json.encode(daData));
              });
            } catch(_) {}
          }
        }
        else {
          if (!existingJson.containsKey(key) || (existingJson[key]['driveHealth'] != info['driveHealth'] ||
              existingJson[key]['driveRemainingCapacity'] != info['driveRemainingCapacity'] ||
              existingJson[key]['driveName'] != info['driveName'])) {
            shouldUpdate = true;
            existingJson[key] = info;
            int index = Api().driveName.indexOf(info['driveName']);
            if (index >=0 ) {
              await Api().saveComputerRecord(
                  Api().driveLetter[index],
                  Api().driveHealth[index],
                  Api().serialNumbers[index],
                  Api().driveName[index],
                  Api().totalAvailable[index],
                  Api().storageFree[index],
                  Api().typeList[index]
              );

              if (Api().typeList[index] == "Nvme SSD" &&
                  double.parse(Api().driveHealth[index]) < 80) {
                await Api().emailBadDrive(
                    Api().driveLetter[index], int.parse(Api().driveHealth[index]));
              }
              else if (Api().typeList[index] != "Nvme SSD" &&
                  double.parse(Api().driveHealth[index]) < 100) {
                await Api().emailBadDrive(
                    Api().driveLetter[index], int.parse(Api().driveHealth[index]));
              }

              double percentfree = double.parse(Api().storageFree[index].replaceAll(RegExp(r'[^0-9]'), "").trim()) /
                  double.parse(Api().driveCapacity[index].replaceAll(RegExp(r'[^0-9]'), "").trim()) * 100;
              if (percentfree.round() < 20) {
                await Api().emailDriveCapacity(
                    Api().driveLetter[index], percentfree.round());
              }
            }
          }
        }
      }

      if (shouldUpdate) {
        await writeFile(
            "${MyApp().PATH_PROGRAMDATA}/Drive Adviser/Datalog.json",
            const JsonEncoder.withIndent('  ').convert(existingJson));
      }
      DataLogger.clearMessages();

      if (Api().batteryExists) {
        await saveBatteryRecord();
      }
    }
    catch(e) {}
  }

  Future<String> saveBatteryRecord() async {
    var url = Uri.parse("https://api.driveadviser.com/index.php/api/saveBatteryRecord");
    Battery battery = Battery();
    BatteryState batteryStatus = await battery.batteryState;
    int remainCapacity = ((await battery.batteryLevel) / 100.0 * Api().batterycap) as int;

    // Formatting the body as x-www-form-urlencoded
    var body = {
      "id_battery": "${Api().batteryID}",
      "chargingStatus": (batteryStatus == BatteryState.charging ? "3" : (batteryStatus == BatteryState.discharging ? "1" : "2")),
      "remainingCapacity": "$remainCapacity",
      "health": "${Api().batteryHealth}"
    }.entries.map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}').join('&');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return 'Response data: ${response.body}';
    } else {
      return 'Failed to load data';
    }
  }

  Future<void> makeJsonFileAndFillin() async {
    Map daData = MyApp().daJSON;

    ///find and save user
    String email = Api().emailCustomer;
    String phoneNumber = Api().phoneNumber;
    String userPassword = "";
    const String letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String allowedChars = letters + numbers;
    final Random random = Random();
    final StringBuffer password = StringBuffer();
    while (password.length < 10) {
      final int index = random.nextInt(allowedChars.length);
      password.write(allowedChars[index]);
    }
    userPassword = password.toString();

    try {
      await Api().saveUser(email, userPassword, phoneNumber).then((value) {
        Map data = json.decode(value);
        daData["data"]["user_id"] = data["id"];
        daData["data"]["user_login"] = data["all"]["data"]["user_login"];
        daData["data"]["user_nicename"] = data["all"]["data"]["user_nicename"];
        daData["data"]["user_registered"] =
        data["all"]["data"]["user_registered"];
        daData["data"]["user_status"] = data["all"]["data"]["user_status"];
        daData["data"]["display_name"] = data["all"]["data"]["display_name"];
      });
    } catch(_) {}

    ///save computer
    daData["data"]["wkey"] = await ComputerInfoGetter().getWKey();
    daData["data"]["computerName"] = await ComputerInfoGetter().getComputerName();
    daData ["data"]["user_email"] = Api().emailCustomer;
    daData ["data"]["phone_number"] = Api().phoneNumber;

    await loadHardwareInfo();
    try {
      await Api().saveComputer(
          daData ["data"]["user_email"],
          daData["data"]["wkey"],
          Api().driveLetter[0],
          Api().driveHealth[0],
          Api().serialNumbers[0],
          Api().driveName[0],
          daData["data"]["computerName"],
          daData["data"]["cpu"],
          Api().driveCapacity[0],
          daData["data"]["os"],
          daData["data"]["cpuSpeed"],
          "${daData["data"]["ramCapacity"]}",
          daData["data"]["buildVersion"]).then((value) =>
      daData ["data"]["id_computer"] = (json.decode(value))["id_computer"]["id"]);
    } catch(_) {}

    if(Api().si != "") {
      daData ["data"]["siTag"]= Api().si;
      await Api().saveSITag(daData ["data"]["siTag"], "${daData["data"]["id_computer"]}");
    }

    ///save battery
    if(Api().batteryExists) {
      try {
        await Api().saveBattery(
            Api().batterycap, Api().batMaxCap, Api().batterycap,
            int.parse(daData["data"]["id_computer"]), daData["data"]["wkey"],
            Api().batteryHealth).then((value) {
          daData["data"]["battery_id"] = json.decode(value)["batteryId"];
        });
      } catch(_) {}
    }

    await writeFile("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/driveadviser.json", json.encode(daData));
  }
}

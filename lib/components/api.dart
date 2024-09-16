import 'dart:convert';
import 'dart:io';
import 'package:drive_adviser/lib2/util.dart';
import 'package:drive_adviser/screens/maindata.dart';
import 'package:http/http.dart' as http;
import 'package:ini/ini.dart';

class Api {
  static final Api _instance = Api._internal();
  static const _website = "schrockinnovations.com";
  static const _website2 = "api.schrockinnovations.com";
  static const _url = "api.driveadviser.com";
  static const _url4 = "/index.php/api/";
  static get url => _url;
  static get url4 => _url4;

  /* ******************************
    FUNCTIONS
   ****************************** */
  final bool test = true;
  String emailCustomer = "";
  String phoneNumber = "";
  String compID = "";
  String si = "";
  List<String> driveLetter = [];
  List<String> driveName = [];
  List<String> driveHealth = [];
  List<String> disk = [];
  List<String> driveCapacity = [];
  List<String> storageFree = [];
  List<String> totalAvailable = [];
  List<String> typeList = [];
  List<String> temperature = [];
  List<String> serialNumbers = [];
  List<String> issues = [];
  bool batteryExists = false;
  int batteryHealth = 0;
  int batterycap = 0;
  int batMaxCap = 0;
  int batteryID = 0;
  bool contactOptions = false;
  String driveType = "Unknown";
  Set<String> existingDataIdentifiers = {};

  Future saveLogToFile() async {
    if (Logger.getMessages().isNotEmpty) {
      final String contents = Logger.getMessages().join('\n');
      Logger.clearMessages();
      await writeFile(
          "${MyApp().PATH_PROGRAMDATA}/Drive Adviser/log.txt", contents,
          isAppend: true);
    }
  }

  ///todo important //////

  Future getMyIp() async {
    try {
      var response =
      await http.get(Uri.https('api.ipify.org', '/', {'format': 'json'}));
      if (response.statusCode == 200) {
        var x = jsonDecode(response.body) as Map<String, dynamic>;

        return {'ip': x['ip']};
      } else {
        return {'success': false};
      }
    }
    catch(e) {
   }
  }

  Future<bool> checkIp() async {
    try {
      Map<String, dynamic> bodyData = await getMyIp();
      String dataJson = json.encode(bodyData);
      var response = await http
          .get(Uri.https(_website2, "${_url4}checkIp", {"data": dataJson}));
      if (response.statusCode == 200) {
        Map<String, dynamic> apiResponse = json.decode(response.body);

        return apiResponse['success'] == true;
      } else {
        return false;
      }
    }
    catch(e) {
      return false;
    }
  }

  ///todo important //////
  Future getUpdateVersion() async {
    try {
      var response = await http.get(Uri.https(
          "driveadviser.com",
          '/driveAdviser_remake/download/${Api().test ? 'driveAdviserTest' : 'driveAdviser'}.xml'));
      String updateFile = response.body;
      List<String> updateList = updateFile.split('Version');
      updateList = updateList[1].split('<');
      return updateList[0].trim();
    }
    catch(e) {
      Logger.log("getUpdateVersion() is having this error\n$e");
    }
  }

  ///if the app does not have the folder path, this command creates the path
  Future<void> getOldDAInfo() async {
    try {
      ///this is the old Drive Adviser file
      final myDir = File(
        '${MyApp().PATH_PROGRAMDATA}/Drive Adviser/DriveAdviser.ini',
      );

      if (myDir.existsSync()) {
        // Read the lines from the file
        List<String> lines = await myDir.readAsLines();

        // Create a Config object from the lines
        Config config = Config.fromStrings(lines);

        // Access sections and keys
        compID = config.get('Computer', 'Id')!; // Note: 'Id' instead of 'ID'
        emailCustomer =
        config.get('User', 'EmailAddress')!; // Note: 'Id' instead of 'ID'

        try {
            compID = MyApp().daJSON["data"]["id_computer"];
            si = MyApp().daJSON["data"]["siTag"];
        } catch(_) {}

        await getSI(compID);
      }
    }
    catch(e) {}
  }

  Future<Map<dynamic, dynamic>> getUserData(String userEmail) async {
    var response = await http.get(Uri.https(_url,
        '${_url4}userExistsByUsername', {"data": '{"username":"$userEmail"}'}));
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> responsedata = json.decode(response.body);
      return responsedata;
    } else {
      return {'success': false};
    }
  }

  Future<void> getSI(String userID) async {
    try {
      Map<String, dynamic> bodyData = {"id": userID};
      var response =
      await http.get(Uri.https(_url, '${_url4}getComputerById', bodyData));
      if (response.statusCode == 200) {
        var computerInformation = jsonDecode(response.body);
        if (computerInformation["success"] == true) {
          String formattedComputerInfo =
              jsonEncode(computerInformation)
              .replaceAll("[", "")
              .replaceAll("]", "");
          Map edited = jsonDecode(formattedComputerInfo);
          si = edited["data"]["siTag"];
          emailCustomer = edited["data"]["user_email"];
          await checkSI(si);
          edited["data"]["phone_number"] = phoneNumber;

          // Write to file
          await writeFile("${MyApp().PATH_PROGRAMDATA}/Drive Adviser/driveadviser.json", jsonEncode(edited));
          MyApp().daJSON = edited;
        }
      }
    }
    catch(e) {}
  }

  Future saveSITag(String si, String userID) async {
    Map<String, String> bodyData = {"siTag": si, "id_computer": userID};
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    var response = await http
        .get(Uri.https(_url, '${_url4}doubleVerifyCustomerInfo', body));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }


  Future emailBadDrive(String driveLetter, int driveHealth) async {
    ///bad Drive email
    Map<String, dynamic> bodyData = {
      "type": 21,
      "driveLetter": driveLetter,
      "driveHealth": driveHealth,
      "computerID": Api().compID,
    };
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    var response = await http.get(Uri.https(_url, '${_url4}email', body));
    String apiResponse = response.body;
    return " $dataJson \n$apiResponse";
  }

  Future emailDriveCapacity(String driveLetter, int driveCapacity) async {
    ///drive capacity reaching its limit
    Map<String, dynamic> bodyData = {
      "type": 22,
      "driveLetter": driveLetter,
      "computerID": Api().compID,
      ///this is a percentage left
      "driveCapacity":driveCapacity
    };
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    var response = await http.get(Uri.https(_url, '${_url4}email', body));
    String apiResponse = response.body;
    return " $dataJson \n$apiResponse";
  }

  Future emailBatteryHealth(int batteryHealth) async {
    ///failing battery
    Map<String, dynamic> bodyData = {
      "type": 41,
      "driveLetter": "X",
      "driveHealth": batteryHealth,
      "computerID":Api().compID,
    };
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    if(batteryHealth != -1) {
      var response = await http.get(Uri.https(_url, '${_url4}email', body));
      String apiResponse = response.body;
      return " $dataJson \n$apiResponse";
    }
    else{
      batteryExists = false;
      return "battery does not exist";
    }
  }

  Future saveUser(
      String userEmail, String userPassword, String userphoneNumber) async {
    Map<String, dynamic> bodyData = {
      "username": userEmail,
      "password": userPassword,
      "email": userEmail,
      "phone": userphoneNumber
    };
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    var response = await http.get(Uri.https(_url, '${_url4}saveUser', body));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }

  Future updateUser(String id, String email, String userphoneNumber) async {
    try{
    Map<String, dynamic> bodyData = {
      "id": id,
      "email": email,
      "phone": userphoneNumber
    };
    String dataJson = json.encode(bodyData);
    Map<String, String> body = {"data": dataJson};
    var response = await http.get(Uri.https(_url, '${_url4}updateUser', body));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }
    catch(e){
    await Api().saveLogToFile();}
  }

  Future saveComputer(
      String userEmail,
      String wkey,
      String driveLetter,
      String health,
      String serial,
      String model,
      String computerName,
      String cpu,
      String capacity,
      String os,
      String cpuSpeed,
      String ram,
      String buildVersion) async {
    Map<String, dynamic> bodyData = {
      "username": userEmail,
      "computerName": computerName,
      "active": true,
      "ramCapacity": ram,
      "wkey": wkey,
      "driveLetter": driveLetter,
      "driveHealth": health,
      "model": model,
      "cpu": cpu,
      "hddCapacity": capacity,
      "os": os,
      "dateCreated": "${DateTime.now()}",
      "buildVersion": buildVersion,
      "cpuSpeed": cpuSpeed,
    };
    String dataJson = json.encode(bodyData);
    Map<String, dynamic> body = {"data": dataJson};
    var response =
    await http.get(Uri.https(_url, '${_url4}saveComputer', body));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }

  Future saveBattery(int chargeRate, int designCapacity, int fullChargeCapacity,
      int idComputer, String wkey, int batthealth) async {
    try {
    ///{"username":"josburn@schrockinnovations.com","wkey":"h2xqq-3cnqp-qhqd9-vbtgv-qpd93","batteryDetail":{"computerId":16941,"chargeRate":0,"designCapacity":48944,"fullChargeCapacity":42058,"batteryHealth":100}}
      Map<String, dynamic> bodyData = {
        "username": emailCustomer,
        "wkey": wkey,
        "batteryDetail": {
          "computerId": compID,
          "chargeRate": 0,
          "designCapacity": designCapacity,
          "fullChargeCapacity": fullChargeCapacity,
          "batteryHealth": batthealth
        }
      };
      String dataJson = json.encode(bodyData);
      Map<String, dynamic> body = {"data": dataJson};
      var response =
      await http.get(Uri.https(_url, '${_url4}saveBattery', body));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return response.statusCode;
      }
    } catch(e){}
  }

  Future saveComputerRecord(String driveLetter,
      String health, String serial, String model,String totalCapacity,String freeSpace, String driveType) async {
    try {
      Map daData = MyApp().daJSON;
      Map<String, dynamic> bodyData = {
        "username": daData["data"]["user_login"],
        "wkey": daData["data"]["wkey"],
        "driveLetter": driveLetter,
        "driveHealth": health,
        "serial": serial,
        "id_computer": daData["data"]["id_computer"],
        "model": model,
        "totalCapacity":totalCapacity ,
        "freeSpace": freeSpace,
        "driveType": driveType,
      };
      String dataJson = json.encode(bodyData);
      Map<String, String> body = {"data": dataJson};
      var response =
      await http.get(Uri.https(_url, '${_url4}saveComputerRecord', body));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return response.statusCode;
      }
    }
    catch(e) {}
  }

  Future checkSI(String siNumber) async {
    Map<String, String> body = {"siTag": siNumber};
    var response = await http
        .get(Uri.https(_website, '/account/api/scripts/getCustomerDA', body));
    if (response.statusCode == 200) {
      var computerInformation = jsonDecode(response.body);

      // Convert the decoded response to a pretty JSON string
      String formattedComputerInfo =
      ((const JsonEncoder.withIndent('  ').convert(computerInformation))
          .replaceAll("[", ""))
          .replaceAll("]", "");
      Map data = jsonDecode(formattedComputerInfo);
      if (data["all"]["PrimaryPhone"] == null) {
        phoneNumber = "0";
      } else if (data["all"]["PrimaryPhone"].length != 10) {
        phoneNumber = data["all"]["HomePhone"];
      } else {
        phoneNumber = data["all"]["PrimaryPhone"];
      }

      return response.body;
    } else {
      return response.statusCode;
    }
  }


  //GET
  factory Api() {
    return _instance;
  }

  Api._internal();
// rest of your class

/* ******************************
    HELPERS
   ****************************** */
}

class Logger {
  static final List<String> _messages = [];

  static void log(String message) {
    _messages.add(message);
  }

  static List<String> getMessages() {
    return _messages;
  }

  static void clearMessages() {
    _messages.clear();
  }
}

class DataLogger {
  // Change _messages to a list of Map<String, dynamic> to handle complex JSON data
  static final List<Map<String, dynamic>> _messages = [];

  // Modified to accept structured data
  static void log(Map<String, dynamic> message) {
    _messages.add(message);
  }

  static List<Map<String, dynamic>> getMessages() {
    return _messages;
  }

  static void clearMessages() {
    _messages.clear();
  }
}

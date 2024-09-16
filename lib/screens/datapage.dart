import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drive_adviser/components/universalAppBar.dart';
import 'package:drive_adviser/lib2/util.dart';
import 'package:drive_adviser/screens/maindata.dart';
import 'package:flutter/material.dart';
import '../components/api.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:ffi';

class HardwareInfoScreen extends StatefulWidget {
  const HardwareInfoScreen({super.key});

  @override
  _HardwareInfoScreenState createState() => _HardwareInfoScreenState();
}

class _HardwareInfoScreenState extends State<HardwareInfoScreen> {
  final PageController _pageController = PageController();
  bool _isArrowRight = true;
  int _totalMemory = 0;
  String _cpuSpeed = "Loading...";
  String _systemName = "...Loading";
  String _osVersionNumber = "...Loading";
  String _cpuName = "...loading";
  String _osVersionName = "...Loading";
  String _osVersionID = "Loading...";

  @override
  void initState() {
    super.initState();
    loadHardwareInfo(); // Call the method to load hardware info
    initializeAllDriveData(); // Make sure to call this method
    appWindow.maximize();
  }

  List<DriveData> allDriveData = [];
  List<String> serialNumbers = [];

  void initializeAllDriveData() {
    try{
      List<String> drivesList = MyFFI().receivedInitializedVisualStudio();
      allDriveData.clear(); // Clear existing data if re-initializing
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
      setState(() {}); // Notify the framework that the state has changed
    }catch(e){
      Logger.log("$e");
    }

  }

  List<Widget> _buildSpecificAttributeDisplays() {

    List<Widget> attributeDisplays = [];
    List<String> attributesToFind = [
      'Read Error Rate',
      'Critical Warning',
      'Power-On Hours',
      'Power On Hours',
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
      'Uncorrectable Sectors Count',
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
      'Temperature'
    ];
    Set<String> displayedAttributes = {}; // Keep track of displayed attributes
    List<String> fulldata = [];

    for (var driveData in allDriveData) {
      var foundAttributes = driveData.findAttributes(attributesToFind);
      for (var attribute in attributesToFind) {
        // Construct a unique key for each attribute based on drive and attribute name
        String uniqueKey = '${driveData.driveIdentifier}_$attribute';
        if (foundAttributes.containsKey(attribute) &&
            !displayedAttributes.contains(uniqueKey)) {
          // If the attribute is found and not already displayed, add a widget to display it
          displayedAttributes
              .add(uniqueKey); // Mark this attribute as displayed
          fulldata.add(
              '${driveData.driveIdentifier}: $attribute - Value: ${foundAttributes[attribute]['value']}, ID: ${foundAttributes[attribute]['id']}\n');
        }
      }
    }

    return attributeDisplays;
  }

  // The method to load hardware info goes here (as shown previously)
  void loadHardwareInfo() {
    try{
    final buffer = calloc<ffi.Int8>(4096); // Ensure the buffer is large enough
    MyFFI().getDriveInfo(buffer, 4096);
    final String allData = buffer.cast<Utf8>().toDartString();
    calloc.free(buffer);

    // Split the data into parts
    final parts = allData.split('|');
    final String allSerialNumbers = parts[0];
    final String totalMemory = parts.length > 1 ? parts[1] : "Unknown";
    final String cpuSpeed = parts.length > 2 ? parts[2] : "Unknown";
    final String systemName = MyApp().daJSON["data"]["computerName"];
    final String osNumber = parts.length > 4 ? parts[4] : "Unknown";
    final String cpuName = parts.length > 5 ? parts[5] : "Unknown";

    setState(() {
      serialNumbers = allSerialNumbers.split('\n').where((sn) => sn.isNotEmpty).toList();
      _totalMemory = int.parse(totalMemory) ~/ 1000000000;
      _cpuSpeed = cpuSpeed;
      _systemName = systemName;
      _osVersionNumber = osNumber;
      _cpuName = cpuName;
    });
    String osVersionID = "";
    String osVersionName = "";
    switch (osNumber) {
      case "4.0.950":
        osVersionID = "";
        break;
      case "5.1.2600":
        osVersionID = "";
        break;
      case "6.0.6002":
        osVersionID = "";
        break;
      case "6.1.7600.16385":
        osVersionID = "";
        break;
      case "6.2.9200.16384":
        osVersionID = "";
        break;
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
    _osVersionID = osVersionID;
    switch (osVersionID) {
      case "1507":
        osVersionName = "Windows 10";
        break;
      case "1511":
        osVersionName = "Windows 10";
        break;
      case "1607":
        osVersionName = "Windows 10";
        break;
      case "1703":
        osVersionName = "Windows 10";
        break;
      case "1709":
        osVersionName = "Windows 10";
        break;
      case "1803":
        osVersionName = "Windows 10";
        break;
      case "1809":
        osVersionName = "Windows 10";
        break;
      case "1903":
        osVersionName = "Windows 10";
        break;
      case "1909":
        osVersionName = "Windows 10";
        break;
      case "2004":
        osVersionName = "Windows 10";
        break;
      case "20H2":
        osVersionName = "Windows 10";
        break;
      case "21H1":
        {
          osVersionName = "Windows 10";
          break;
        }

      case "21H2":
        if (osNumber == "10.0.19044") {
          osVersionName = "Windows 10";
        } else {
          osVersionName = "Windows 11";
        }
        break;
      case "22H2":
        {
          if (osNumber == "10.0.19045") {
            osVersionName = "Windows 10";
          } else {
            osVersionName = "Windows 11";
          }
          break;
        }
      case "23H2":
        osVersionName = "Windows 11";
        break;
      default:
        osVersionName = "unknown";
    }
    _osVersionName = osVersionName;
  }
  catch(e){
  Logger.log("$e");
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar("dataPage"),
      body: PageView(
        controller: _pageController,
        children: [
          _buildListViewPage(),
          _buildSingleChildScrollViewPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          (_pageController.page == 0)
              ? _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                )
              : _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );

          setState(() {
            _isArrowRight = !_isArrowRight;
          });
        },
        child: Icon(!_isArrowRight ? Icons.arrow_back : Icons.arrow_forward),
      ),
      floatingActionButtonLocation: _isArrowRight
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildListViewPage() {
    // Define text styles for title and subtitle
    const titleTextStyle = TextStyle(
        fontSize: 35, fontWeight: FontWeight.bold); // Example style for titles
    const subtitleTextStyle =
        TextStyle(fontSize: 30); // Example style for subtitles
    const titleTextStyle2 = TextStyle(
        fontSize: 30, fontWeight: FontWeight.bold); // Example style for titles
    const subtitleTextStyle2 =
        TextStyle(fontSize: 25); // Example style for subtitles
    int index = Api().existingDataIdentifiers.length;
    return Center(
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _customListTile(
                  title: 'Computer Name',
                  subtitle: _systemName,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System',
                  subtitle: _osVersionName + _osVersionID,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'OS Version Number',
                  subtitle: _osVersionNumber,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Ram Installed',
                  subtitle: "$_totalMemory GB",
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'CPU Installed',
                  subtitle: _cpuName,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'CPU Speed',
                  subtitle: _cpuSpeed,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System Drive Letter',
                  subtitle: Api().driveLetter[0],
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System Drive Name',
                  subtitle: Api().driveName[0],
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System Drive Serial Number',
                  subtitle: serialNumbers[0],
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System Drive Capacity',
                  subtitle: Api().driveCapacity[0],
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Operating System Drive Type',
                  subtitle: Api().typeList[0],
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Customer Email',
                  subtitle: Api().emailCustomer,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                _customListTile(
                  title: 'Customer Phone Number',
                  subtitle: Api().phoneNumber,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(index, (i) {
                      return _customListTile(
                        title: 'Hard drive Disk: ${Api().disk[i]} ',
                        subtitle:
                            "Drive Letter: ${Api().driveLetter[i]}\nDrive Name: ${Api().driveName[i]}\nDrive Capacity: ${Api().driveCapacity[i]}\nDrive Free Space: ${Api().storageFree[i]}\nDrive Health: ${Api().driveHealth[i]}\nDrive Temperature: ${Api().temperature[i]}",
                        titleStyle: titleTextStyle2,
                        subtitleStyle: subtitleTextStyle2,
                      );
                    })),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper method to create a custom ListTile
  // Helper method to create a custom ListTile
  Widget _customListTile({
    required String title,
    required String subtitle,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Explicitly align text to the left
        children: [
          SelectableText(title, style: titleStyle),
          SelectableText(subtitle, style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildSingleChildScrollViewPage() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ..._buildDriveDataTables(),
          ..._buildSpecificAttributeDisplays(),
          // Display specific attributes below the tables
        ],
      ),
    ));
  }

  List<Widget> _buildDriveDataTables() {
    List<Widget> tables = [];
    for (var driveData in allDriveData) {
      // Add a header for each drive
      tables.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SelectableText(
          'Drive: ${driveData.driveIdentifier}',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ));

      // Build a table for the current drive
      tables.add(_buildDataTableForDrive(driveData));
    }
    return tables;
  }

  Widget _buildDataTableForDrive(DriveData driveData) {
    return DataTable(
      columns: const [
        DataColumn(
            label: SelectableText(
          "No",
          style: TextStyle(fontSize: 24),
        )),
        DataColumn(
            label: SelectableText(
          "Id",
          style: TextStyle(fontSize: 24),
        )),
        DataColumn(
            label: SelectableText(
          "Attribute Name",
          style: TextStyle(fontSize: 24),
        )),
        DataColumn(
            label: SelectableText(
          "Current Value",
          style: TextStyle(fontSize: 24),
        )),
        DataColumn(
            label: SelectableText(
          "Worst Value",
          style: TextStyle(fontSize: 24),
        )),
        // New column for worst values
        DataColumn(
            label: SelectableText(
          "Threshold",
          style: TextStyle(fontSize: 24),
        )),
        // New column for threshold values
        DataColumn(
            label: SelectableText(
          "Raw Value",
          style: TextStyle(fontSize: 24),
        )),
      ],
      rows: _buildRowsForDrive(driveData),
    );
  }

  List<DataRow> _buildRowsForDrive(DriveData driveData) {
    List<DataRow> rows = [];
    for (int index = 0; index < driveData.stringList.length; index++) {
      rows.add(DataRow(cells: [
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              '${index + 1}',
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.idList[index].toString(),
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.stringList[index],
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.intList[index].toString(),
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.worstList[index].toString(),
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.thresholdList[index].toString(),
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            height: 100,
            width: 100,
            child: AutoSizeText(
              driveData.rawvalueList[index].toString(),
              style: const TextStyle(fontSize: 40),
              minFontSize: 10, // Specify a minimum font size if needed
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // To avoid text spilling over
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ]));
    }
    return rows;
  }
}

class DriveData {
  String driveIdentifier;
  List<String> stringList;
  List<int> intList;
  List<int> idList;
  List<int> worstList; // Add this list for worst values
  List<int> thresholdList; // Add this list for threshold values
  List<String> rawvalueList;

  DriveData({
    required this.driveIdentifier,
    required this.stringList,
    required this.intList,
    required this.idList,
    required this.worstList, // Initialize in constructor
    required this.thresholdList, // Initialize in constructor
    required this.rawvalueList,
  });

  // Method to find specific attribute values
  Map<String, dynamic> findAttributes(List<String> attributes) {
    Map<String, dynamic> foundAttributes = {};
    for (var attribute in attributes) {
      int index = stringList.indexOf(attribute);
      if (index != -1) {
        // If attribute is found, store its value
        foundAttributes[attribute] = {
          'value': intList[index].toString(),
          'id': idList[index].toString()
        };
      }
    }
    return foundAttributes;
  }
}
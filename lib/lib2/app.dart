import 'dart:async';
import 'dart:io';
import 'package:drive_adviser/lib2/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../components/api.dart';
import '../screens/maindata.dart' as maindata;
import 'examples/document.dart';
import 'examples/smart.dart';

class CustomData {
  final List<DriveData> allDriveData;

  CustomData({required this.allDriveData});
}

const examples = <Example>[
  Example("Drive Adviser Information", "smart.dart", generateSmart),
  Example('S.M.A.R.T. Information', 'document.dart', generateDocument),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat, CustomData data);

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}

class MyApp2 extends StatefulWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  MyApp2State createState() {
    return MyApp2State();
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

  Map<String, dynamic> findAttributes(List<String> attributes) {
    Map<String, dynamic> foundAttributes = {};
    for (var attribute in attributes) {
      // Determine if the attribute is an ID (assuming IDs are numeric)
      bool isID = RegExp(r'^\d+$').hasMatch(attribute);

      int index = -1;
      if (!isID) {
        // Search by attribute name
        index = stringList.indexOf(attribute);
      } else {
        // Search by ID, assuming idList is a List<String> of attribute IDs
        index = idList.indexOf(int.parse(attribute));
      }

      if (index != -1) {
        // If attribute is found, store its details along with the attribute name
        String foundAttributeName =
            stringList[index]; // Attribute name found by index
        foundAttributes[foundAttributeName] = {
          'name': foundAttributeName,
          // Include the attribute name in the details
          'value': intList[index].toString(),
          'id': idList[index].toString(),
          'worst': worstList[index].toString(),
          'threshold': thresholdList[index].toString(),
          'raw': rawvalueList[index].toString(),
        };
      }
    }
    return foundAttributes;
  }

  Map<String, dynamic> calculateTemp(Map<String, dynamic> foundAttributes) {
    String temp = "";
    int hexToDecimal(String hexValue) {
      // Ensure we only take the last four characters of the hex string
      String lastTwoChars = hexValue.length > 4
          ? hexValue.substring(hexValue.length - 4)
          : hexValue;
      return int.parse(lastTwoChars, radix: 16);
    }

    foundAttributes.forEach((attribute, details) {
      var value = int.tryParse(details['value']) ??
          0; // Parse the value, defaulting to 0 if parsing fails
      var raw;
      try {
        raw = hexToDecimal(details['raw']);
      } catch (e) {
        raw = 0; // Default to 0 if parsing fails
      }

      switch (attribute) {
        case 'Temperature':
          temp = "$raw";
          break; // Make sure to add break statements to avoid fall-through
        case 'Disk Temperature':
          temp = "$raw";
          break;
        case 'Composite Temperature':
          temp = "${(value - 273.15).round()}";
          break;
        case 'Airflow Temperature':
          temp = "$raw";
          break;

        default:
      }
    });

    return {"Temperature": temp};
  }

  Map<String, dynamic> calculateHealth(Map<String, dynamic> foundAttributes) {
    int hexToDecimal2(String hexValue) {
      // Ensure we only take the last four characters of the hex string
      String lastTwoChars = hexValue.length > 4
          ? hexValue.substring(hexValue.length - 4)
          : hexValue;
      return int.parse(lastTwoChars, radix: 16);
    }
    String issues = "";
    String type = "";
    List<String> issuesList = [];
    double health = 100.0; // Start with a perfect health score
    int hexToDecimal(String hexValue) {
      return int.parse(hexValue, radix: 16);
    }

    foundAttributes.forEach((attribute, details) {
      var ids = int.tryParse(details['id']) ??
          0; // Parse the value, defaulting to 0 if parsing fails
      var value = int.tryParse(details['value']) ??
          0; // Parse the value, defaulting to 0 if parsing fails
      var worst = int.tryParse(details['worst']) ??
          0; // Parse the worst, defaulting to 0 if parsing fails
      var threshold = int.tryParse(details['threshold']) ??
          0; // Parse the threshold, defaulting to 0 if parsing fails
      var raw;
      var raw2;
      try {
        raw2 = hexToDecimal2(details['raw']);
      } catch (e) {
        raw = 0;
      } // Parse the threshold, defaulting to 0 if parsing fails
      try {
        raw = hexToDecimal(details['raw']);
      } catch (e) {
        raw = 0;
      } // Parse the threshold, defaulting to 0 if parsing fails

      var newValue = value - threshold;
      var newWorst = worst - threshold;
      // Guard against division by zero

      // Calculate the health impact
      double impact = 0;
      switch (attribute) {
        /// NVME
        case "Critical Warning":
          {
            Api().driveType = "Nvme SSD";
            if (value != 0) {
              issuesList.add("***$attribute is having an Issue\n");
              impact = value.toDouble();
            }
          }
        // print("Critical Warning$impact");
        case "Power On Hours":{

          if (value >= 10000 && value < 15000) {
            issuesList.add(
                "*This drive is getting old, the $attribute has reached $value\n");
            impact = 1;
          } else if (value >= 15000 && value < 20000) {
            issuesList.add(
                "**This drive is getting old, the $attribute has reached $value\n");
            impact = (value / 10000);
          } else if (value >= 20000) {
            issuesList.add(
                "***This drive is getting old, the $attribute has reached $value\n");
            impact = 1 + (value / 10000);
          } else {
            impact = 0;
          }}
        case "Power-on Hours":
          if (value >= 10000 && value < 15000) {
            issuesList.add(
                "*This drive is getting old, the $attribute has reached $value\n");
            impact = 1;
          } else if (value >= 15000 && value < 20000) {
            issuesList.add(
                "**This drive is getting old, the $attribute has reached $value\n");
            impact = (value / 10000);
          } else if (value >= 20000) {
            issuesList.add(
                "***This drive is getting old, the $attribute has reached $value\n");
            impact = 1 + (value / 10000);
          } else {
            impact = 0;
          }
        // print("Power On Hours $impact");
        case "Unsafe Shutdowns":
          {
            Api().driveType = "Nvme SSD";
            if (value >= 200000 && maindata
                .MyApp()
                .ip == true) {
              impact = (value - 200000) ~/ 25000 + 1;
              issuesList.add(
                  "*The number of $attribute has increased to $value. Be sure you are using the proper power off procedure in order to retain the health and performance of your drive.\n");
            } else {
              impact = 0;
            }
          }

        case "Media and Data Integrity Errors":
          {
            ///has been changes twice
            if (value != 0) {
              impact = 5;
              issuesList.add("$attribute is having an Issue\n");
            }
            // print("Media and Data Integrity Errors $impact");
          }

        ///always passing HDD
        case "Current Pending Sector Count":
          {
            // print("--------------------$raw-----------------");
            if (raw2 != 0 && raw2 < 1000) {
              issuesList.add("***$attribute is having an Issue\n");
              impact = (.6 * raw2).toDouble();
            } else if (raw2 > 10000) {
              issuesList.add("***$attribute is having an Issue\n");
              impact = (3 * raw2 / 1000).toDouble();
            } else {
              impact = 0;
            }
            // print("Current Pending Sector Count $impact");
          }
        case "Reallocation Event Count":
          {
            if (raw2 != 0 && raw2 < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = (.6 * raw2).toDouble();
            } else {
              impact = 0;
            }
            // print("Reallocation Event Count $impact");
          }
        case "Off-Line Uncorrectable Sector Count":
          {
            if (raw != 0) {
              impact = .6 * int.parse(raw.toString());
              issuesList.add("$attribute is having an Issue\n");
            }
            // print("Uncorrectable Sectors Count $impact");
          }
        case "Uncorrectable Sector Count":
          {
            if (raw != 0) {
              impact = .6 * int.parse(raw.toString());
              issuesList.add("$attribute is having an Issue\n");
            }
            // print("Uncorrectable Sectors Count $impact");
          }
        case "Power-On Hours":
          {
            if (raw2 >= 10000 && raw2 < 15000) {
              issuesList.add(
                  "*This drive is getting old, the $attribute has reached $raw2\n");
              impact = 1;
            } else if (raw2 >= 15000 && raw2 < 20000) {
              issuesList.add(
                  "**This drive is getting old, the $attribute has reached $raw2\n");
              impact = (raw2 / 10000);
            } else if (raw2 >= 20000) {
              issuesList.add(
                  "***This drive is getting old, the $attribute has reached $raw2\n");
              impact = raw2 / 10000 + 1;
            } else {
              impact = 0;
            }
          }
        case "Power on Hours":
          {
            if (raw2 >= 10000 && raw2 < 15000) {
              issuesList.add(
                  "*This drive is getting old, the $attribute has reached $raw2\n");
              impact = 1;
            } else if (raw2 >= 15000 && raw2 < 20000) {
              issuesList.add(
                  "**This drive is getting old, the $attribute has reached $raw2\n");
              impact = (raw2 / 10000);
            } else if (raw2 >= 20000) {
              issuesList.add(
                  "***This drive is getting old, the $attribute has reached $raw2\n");
              impact = raw2 / 10000 + 1;
            } else {
              impact = 0;
            }
          }
        case "Power-on Count":
          {
            if (raw2 >= 10000 && raw2 < 15000) {
              issuesList.add(
                  "*This drive is getting old, the $attribute has reached $raw2\n");
              impact = 1;
            } else if (raw2 >= 15000 && raw2 < 20000) {
              issuesList.add(
                  "**This drive is getting old, the $attribute has reached $raw2\n");
              impact = (raw2 / 10000);
            } else if (raw2 >= 20000) {
              issuesList.add(
                  "***This drive is getting old, the $attribute has reached $raw2\n");
              impact = raw2 / 10000 + 1;
            } else {
              impact = 0;
            }
          }
        case 'Media Wearout Indicator':
          {
            if (raw != 0) {
              issuesList.add("$attribute is having an Issue\n");
              impact = 3;
            }
          }
        case "Grown Bad Blocks":
          {
            Api().driveType = "SSD";
            if (raw2 != 0 && raw2 < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw2.toDouble();
            }
          }
        case "Reallocated Sectors Count":
          {
            if (raw2 != 0 && raw2 < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw2.toDouble();
            }
          }
        case "Reallocated Sector Count":
          {
            if (raw2 != 0 && raw2 < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw2.toDouble();
            }
          }
        case "Program Fail Count (Total)":
          {
            if (raw != 0 && raw < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw.toDouble();
            }
          }
        case "Runtime Bad Block (Total)":
          {
            if (raw != 0 && raw < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw.toDouble();
            }
          }
        case "Uncorrectable Error Count":
          {
            if (raw != 0 && raw < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw.toDouble();
            }
          }

        case "Used Reserved Block Count (Total)":
          {
            if (raw != 0 && raw < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = raw.toDouble();
            }
          }
        case "Used Reserved Block Count (Chip)":
          {
            if (raw != 0 && raw < 1000) {
              issuesList.add("$attribute is having an Issue\n");
              impact = .01 * raw.toDouble();
            }
          }
        case "Wear Leveling Count":
          {
            if (value != 100) {
              issuesList.add("$attribute is having an Issue\n");
              impact = (100 - value).toDouble();
            }
          }
        case "SSD Wear Indicator":
          {
            if (raw2 != 100) {
              impact = (100 - raw2).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }
        case "Remaining Life Percentage":
          {
            if (raw2 != 100) {
              impact = (100 - raw2).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }
        case "Vendor Specific":
          {
            if (ids == 231 && raw < 100) {
              impact = (raw2).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("SSD Life Left is having an Issue\n");
            }
          }
        case "Available Spare":
          {
            Api().driveType = "Nvme SSD";
            if (value != 100) {
              impact = (100 - value).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }
        case "Percentage Used":
          {
            Api().driveType = "Nvme SSD";
            if (value != 0) {
              impact = (value).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }

        case "Remain Life":
          {
            // print("---------remain life $raw2------------");
            if (raw2 != 100) {
              impact = (100 - raw2).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }
        case "SSD Life Left":
          {
            Api().driveType = "Sata SSD";
            ///changed twice
            if (value != 100) {
              impact = (100 - value).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            } else if (raw2 != 100) {
              impact = (100 - raw2).toDouble();
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          }
        default:
      }

      if (value != worst) {
        switch (attribute) {
          ///HDD
          case "Write Error Rate":
            {
              Api().driveType = "HDD";
              var percentagetillfailed = 100 - (newValue * 100.0) / newWorst;
              if (percentagetillfailed >= 100) {
                impact = 50;
                issuesList.add("$attribute is having an Issue\n");
              }
              // print("Write Error Rate $impact");
            }
          case "Spin Up Time":
            {
              Api().driveType = "HDD";
              var percentagetillfailed = 100 - (newValue * 100.0) / newWorst;
              if (percentagetillfailed >= 100) {
                impact = 20;
                issuesList.add("$attribute is having an Issue\n");
              }
              // print("Spin Up Time $impact");
            }
          case "Spin Retry Count":
            {
              Api().driveType = "HDD";
              var percentagetillfailed = (newValue * 100.0) / newWorst;
              if (percentagetillfailed <= 10) {
                impact = percentagetillfailed / 10;
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }
            }
          case "Seek Error Rate":
            {
              Api().driveType = "HDD";
              var percentagetillfailed = (newValue * 100.0) / newWorst;
              if (percentagetillfailed <= 0) {
                impact = 10;
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }

              // print("Seek Error Rate $impact");
            }
          case "Spin-Up Time":
            {
              Api().driveType = "HDD";
              var percentagetillfailed = (newValue * 100.0) / newWorst;
              if (percentagetillfailed <= 40) {
                impact = percentagetillfailed / 10;
                issuesList.add("$attribute is having an Issue\n");
              }
              // print("Spin-Up Time $impact");
            }

          case "Available Reserve Space":
            {
              Api().driveType = "HDD";
              if (value < threshold) {
                impact = (100 - raw).toDouble();
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }
            }
          case "End-to-End Error Count":
            {
              Api().driveType = "HDD";
              if (value < threshold) {
                impact = value / 100;
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }
            }
          case "End-to-End Error":
            {
              Api().driveType = "HDD";
              if (value < threshold) {
                impact = value / 100;
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }
              // print("End-to-End Error $impact");
            }

          ///SATA SSD

          case "Number of Valid Spare Blocks":
            {
              Api().driveType = "Sata SSD";
              impact = (newValue * 100.0) / newWorst;
              // print("Number of Valid Spare Blocks $impact");
              issuesList.add("$attribute is having an Issue\n");
            }

          case "Super cap Status":
            {
              Api().driveType = "Sata SSD";
              impact = (newValue * 100.0) / newWorst;
              // print("Super cap Status $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          case "Bad Block Count":
            {
              Api().driveType = "Sata SSD";
              impact = (newValue * 100.0) / newWorst;
              // print("Bad Block Count $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          case "Remaining Life Percentage":
            {
              Api().driveType = "Sata SSD";
              impact = (newValue * 100.0) / newWorst;
              // print("Remaining Life Percentage $impact");
              issuesList.add("$attribute is having an Issue\n");
            }
          case "Number of CRC Error":
            {
              Api().driveType = "Sata SSD";
              impact = (newValue * 100.0) / newWorst;
              // print("Number of CRC Error $impact");
              issuesList.add("$attribute is having an Issue\n");
            }

          ///Both sata SSD and HDD
          case "Read Error Rate":
            {
              if (value < threshold) {
                impact = value / 100;
                issuesList.add("$attribute is having an Issue\n");
              } else {
                impact = 0;
              }
            }

          default:{

          }
        }
      }

      health = health - impact;
    });
    type = Api().driveType;
    Api().typeList.add(type);
    if (issuesList.isEmpty) {
      issues =
          "There are no issues with your drive. The drive is in perfect health. Always be sure to back up your data regardless of the displayed Hard drive health";
    } else {
      issues =
          "There are some issues with your hard drive. Be sure to check in with your local technician with this drive\n\nThe issues listed with a * are critical and should be addressed.\n\nHere are the list of issues:\n\n$issuesList";
    }
    return {
      "health": health.clamp(1, 100),
      "Issues": issues,
      "type":type
    }; // Ensure health doesn't go below 0 or above 100
  }
}

class MyApp2State extends State<MyApp2> with SingleTickerProviderStateMixin {
  int _tab = 0;
  TabController? _tabController;

  PrintingInfo? printingInfo;

  CustomData _data = CustomData(allDriveData: []);

  @override
  void initState() {
    super.initState();
    initializeAllDriveData(); // Make sure to call this method
    _data = CustomData(allDriveData: allDriveData);
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<DriveData> allDriveData = [];

  void initializeAllDriveData() {
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
        // Use the returned value
        intList: List.from(MyFFI().dartIntArray),
        // Make a copy of the current state
        idList: List.from(MyFFI().dartIdArray),
        // Make a copy of the current state
        worstList: List.from(MyFFI().dartWorstArray),
        thresholdList: List.from(MyFFI().dartThresholdArray),
        rawvalueList: List.from(MyFFI().dartRawValueList),
      );
      allDriveData.add(driveData);
    }
    setState(() {}); // Notify the framework that the state has changed
  }

  String? dropdownValue;
  int selectedIndex = -1;

  Future<void> _init() async {
    final info = await Printing.info();

    _tabController = TabController(
      vsync: this,
      length: examples.length,
      initialIndex: _tab,
    );
    _tabController!.addListener(() {
      if (_tab != _tabController!.index) {
        setState(() {
          _tab = _tabController!.index;
        });
      }
    });

    setState(() {
      printingInfo = info;
    });
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document processed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File('$appDocPath/Drive Adviser Data.pdf');
    // print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Adviser'),
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: examples.map<Tab>((e) => Tab(text: e.name)).toList(),
          isScrollable: true,
        ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) => examples[_tab].builder(format, _data),
        actions: actions,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }
}

import 'package:drive_adviser/components/api.dart';
import 'package:drive_adviser/components/startup.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import '../../screens/maindata.dart';
import '../app.dart';
import '../util.dart';


class HardwareInfo {
  final String computerName;
  final String operatingSystem;
  final int ramInstalled;
  final String cpuInstalled;
  final String cpuSpeed;
  final String osDriveLetter;
  final String osDriveName;
  final String osDriveSerialNumber;
  final String osDriveCapacity;
  final String osDriveType;
  final String osDriveFreeSpace;
  final String customerEmail;
  final String customerPhoneNumber;

  HardwareInfo({
    this.computerName = "",
    this.operatingSystem = "",
    this.ramInstalled = 0,
    this.cpuInstalled = "",
    this.cpuSpeed = "",
    this.osDriveLetter = "",
    this.osDriveName = "",
    this.osDriveSerialNumber = "",
    this.osDriveCapacity = "",
    this.osDriveType = "",
    this.osDriveFreeSpace = "",
    this.customerEmail = "",
    this.customerPhoneNumber = "",
  });
}

Future<Uint8List> generateSmart(pdf.PdfPageFormat format,
    CustomData data) async {

  String _serialNumbers = "Loading...";
  int _totalMemory = 0;
  String _cpuSpeed = "Loading...";
  String _systemName = "...Loading";
  String _cpuName = "...loading";
  String _osVersionName = "...Loading";
  String _osVersionID = "Loading...";
  void loadHardwareInfo() {
    final buffer = calloc<ffi.Int8>(4096); // Ensure the buffer is large enough
    MyFFI().getDriveInfo(buffer, 4096);
    final String allData = buffer.cast<Utf8>().toDartString();
    calloc.free(buffer);

    // Split the data into parts
    final parts = allData.split('|');
    final String allSerialNumbers = parts[0];
    final String totalMemory = parts.length > 1 ? parts[1] : "Unknown";
    final String cpuSpeed = parts.length > 2 ? parts[2] : "Unknown";
    final String osNumber = parts.length > 4? parts[4] : "Unknown";
    final String cpuName = parts.length > 5? parts[5] : "Unknown";

    _serialNumbers = allSerialNumbers.split('\n').where((sn) => sn.isNotEmpty).toList()[0];
    _totalMemory = int.parse(totalMemory)~/1000000000;
    _cpuSpeed = cpuSpeed;
    _cpuName = cpuName;
    _systemName = MyApp().daJSON["data"]["computerName"];

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
        osVersionName = "Windows 10";
        break;
      case "21H2":
        if(osNumber =="10.0.19044")
        {
          osVersionName = "Windows 10";
        }
        else {
          osVersionName = "Windows 11";
        }
        break;
      case "22H2":
        if(osNumber == "10.0.19045") {
          osVersionName = "Windows 10";
        }
        else {
          osVersionName = "Windows 11";
        }
        break;
      case "23H2":
        osVersionName = "Windows 11";
        break;
      default:
        osVersionName = "unknown";
    }
    _osVersionName = osVersionName;
  }

  loadHardwareInfo();
  String version = Startup().currentVersion;

  HardwareInfo hardwareInfo = HardwareInfo(
      computerName
      :_systemName,
      cpuInstalled
      :_cpuName,
      cpuSpeed
      :_cpuSpeed,
      customerEmail
      :Api().emailCustomer,
      customerPhoneNumber
      :Api().phoneNumber,
      operatingSystem
      :_osVersionName + _osVersionID,
      osDriveCapacity
      :Api().driveCapacity[0],
      osDriveFreeSpace
      :Api().storageFree[0],
      osDriveLetter
      :Api().driveLetter[0],
      osDriveName
      :Api().driveName[0],
      osDriveSerialNumber
      :_serialNumbers,
      osDriveType
      :Api().typeList[0],
      ramInstalled
      :_totalMemory);
  // Load your image data
  final ByteData image = await rootBundle.load(
      'assets/drive Adviser Logo pin.jpg');
  Uint8List imageData = image.buffer.asUint8List();

  // Prepare your document
  final doc = pw.Document(pageMode: pdf.PdfPageMode.outlines);

  // Generate PDF content
  doc.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(
      ),
      pageFormat: format.copyWith(marginBottom: 1.5 * pdf.PdfPageFormat.cm),
      orientation: pw.PageOrientation.portrait,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(
                bottom: 3.0 * pdf.PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(
                bottom: 3.0 * pdf.PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(
                        width: 0.5, color: pdf.PdfColors.grey))),
            child: pw.Text('Computer information',
                style: pw.Theme
                    .of(context)
                    .defaultTextStyle
                    .copyWith(color: pdf.PdfColors.grey)));
      },
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * pdf.PdfPageFormat.cm),
            child: pw.Text(
                'Drive Adviser version ${version}\n Page ${context
                    .pageNumber} of ${context.pagesCount}',
                style: pw.Theme
                    .of(context)
                    .defaultTextStyle
                    .copyWith(color: pdf.PdfColors.grey)));
      },
      build: (pw.Context context) =>
      <pw.Widget>[
        pw.Header(
            level: 0,
            title: 'Drive Adviser Information',
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Drive Adviser Information', textScaleFactor: 2),
                  pw.Container(
                      width: 50.0,
                      height: 50.0,
                      child: pw.Image(pw.MemoryImage(imageData))),
                ])),
        pw.Header(
            level: 1,
            child: pw.Text("Computer Information",
                textScaleFactor: 1.5, textAlign: pw.TextAlign.center)),
        pw.Paragraph(
            text:
            "Here is the list of all of the data we collect to ensure your computer is happy and healthy:\n"),
        // Inserting hardware information
        _buildHardwareInfoText(hardwareInfo),
      ]));

  // Save the document
  return await doc.save();
}

// Helper function to generate hardware information text widgets
pw.Widget _buildHardwareInfoText(HardwareInfo info) {
  return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text("Computer Name: ${info.computerName}"),
        pw.Text("Operating System: ${info.operatingSystem}"),
        pw.Text("RAM Installed: ${info.ramInstalled} GB"),
        pw.Text("CPU Installed: ${info.cpuInstalled}"),
        pw.Text("CPU Speed: ${info.cpuSpeed}"),
        pw.Text("Operating System Drive Letter: ${info.osDriveLetter}"),
        pw.Text("Operating System Drive Name: ${info.osDriveName}"),
        pw.Text("Operating System Drive Serial Number: ${info.osDriveSerialNumber}"),
        pw.Text("Operating System Drive Capacity: ${info.osDriveCapacity}"),
        pw.Text("Operating System Drive Type: ${info.osDriveType}"),
        pw.Text("Operating System Drive: ${info.osDriveFreeSpace}"),
        pw.Text("Customer Email: ${info.customerEmail}"),
        pw.Text("Customer Phone Number: ${info.customerPhoneNumber}"),
        // Continue for each piece of information...
      ]);
}
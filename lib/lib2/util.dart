import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import '../screens/maindata.dart';

Future<String> readFile(String filePath) async {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  }
  else {
    return "";
  }
}

Future<File> writeFile(String filePath, String content, { bool isAppend = false }) async {
  final file = File(filePath);
  file.writeAsStringSync(content, mode: isAppend ? FileMode.append : FileMode.write);
  return file;
}

typedef ProcessDataFromFlutterC = Void Function(Int32 data);
typedef ProcessDataFromFlutterDart = void Function(int data);

typedef SendDynamicCDataArrayToFlutterC = Pointer<CDataArray> Function(
    Int32 selectDisk);
typedef SendDynamicCDataArrayToFlutterDart = Pointer<CDataArray> Function(
    int selectDisk);

typedef InitializeCDataArrayToFlutterC = Pointer<CDataArray> Function();
typedef InitializeCDataArrayToFlutterDart = Pointer<CDataArray> Function();

typedef FreeMultipleArraysC = Void Function(Pointer<CDataArray> dataArrays);
typedef FreeMultipleArraysDart = void Function(Pointer<CDataArray> dataArrays);

typedef FreeInitializeCDataArrayC = Void Function(
    Pointer<CDataArray> cDataArray);
typedef FreeInitializeCDataArrayDart = void Function(
    Pointer<CDataArray> cDataArray);

typedef GetDriveInfoC = Void Function(Pointer<Int8>, Int32);
typedef GetDriveInfoDart = void Function(Pointer<Int8>, int);

final class CDataArray extends Struct {
  external Pointer<Pointer<Utf8>> strings;
  external Pointer<Int32> intArray;
  external Pointer<Int32> idArray;
  external Pointer<Int32> worstArray;
  external Pointer<Int32> thresholdArray;

  // Add a pointer for raw value strings if you're passing them as strings
  external Pointer<Pointer<Utf8>> rawValueStrings;
  @Int32()
  external int length;
}

class MyFFI {
  late DynamicLibrary dynamicLibrary;
  late DynamicLibrary harddriveLibrary;

  List<String> dartRawValueList = const [];
  List<String> dartStringList = const [];
  List<int> dartIntArray = const [];
  List<int> dartIdArray = const [];
  List<int> dartWorstArray = const [];
  List<int> dartThresholdArray = const [];

  MyFFI._internal() {
    dynamicLibrary = DynamicLibrary.open('${MyApp().PATH_PROGRAMDATA}/Drive Adviser/working.dll');
    harddriveLibrary = DynamicLibrary.open('${MyApp().PATH_PROGRAMDATA}/Drive Adviser/harddrive_info.dll');
  }
  static final MyFFI _instance = MyFFI._internal();

  factory MyFFI() {
    return _instance;
  }

  void processDataFromFlutter(int data) {
    final ProcessDataFromFlutterDart processDataFromFlutter = dynamicLibrary
        .lookupFunction<ProcessDataFromFlutterC, ProcessDataFromFlutterDart>(
        'processDataFromFlutter');
    processDataFromFlutter(data);
  }

  List<String> receivedInitializedVisualStudio() {
    final InitializeCDataArrayToFlutterDart initializeCDataArrayToFlutter =
    dynamicLibrary.lookupFunction<InitializeCDataArrayToFlutterC,
        InitializeCDataArrayToFlutterDart>('initializeDrives');
    final FreeInitializeCDataArrayDart freeInitializeArrays = dynamicLibrary
        .lookupFunction<FreeInitializeCDataArrayC, FreeInitializeCDataArrayDart>(
        'freeInitializeCDataArray');
    // Call the C++ function
    Pointer<CDataArray> cDriveListsPointer = initializeCDataArrayToFlutter();

    int length = cDriveListsPointer.ref.length;
    Pointer<Pointer<Utf8>> drivesArrayPointer = cDriveListsPointer.ref.strings;
    // Retrieve the values from the C++ struct6

    // Convert the C-style string array to Dart List<String>
    List<String> drivesList = List.generate(
      length,
          (index) => (drivesArrayPointer + index).value.toDartString(),
    );

    freeInitializeArrays(cDriveListsPointer);
    return drivesList;
  }

  List<String> receivedDiskInformations(int selectDisk) {
    final SendDynamicCDataArrayToFlutterDart sendDynamicCStringArrayToFlutter =
    dynamicLibrary.lookupFunction<SendDynamicCDataArrayToFlutterC,
        SendDynamicCDataArrayToFlutterDart>('sendDynamicCDataArrayToFlutter');

    final FreeMultipleArraysDart freeMultipleArrays = dynamicLibrary
        .lookupFunction<FreeMultipleArraysC, FreeMultipleArraysDart>(
        'freeDynamicCDataArray');
    // Call the C++ function
    Pointer<CDataArray> cStringArrayPointer = sendDynamicCStringArrayToFlutter(selectDisk);
    int length = cStringArrayPointer.ref.length;

    Pointer<Pointer<Utf8>> dataArrayPointer = cStringArrayPointer.ref.strings;
    Pointer<Pointer<Utf8>> rawValueArrayPointer =
        cStringArrayPointer.ref.rawValueStrings;
    Pointer<Int32> intArrayPointer = cStringArrayPointer.ref.intArray;
    Pointer<Int32> idArrayPointer = cStringArrayPointer.ref.idArray;
    Pointer<Int32> worstArrayPointer = cStringArrayPointer.ref.worstArray;
    Pointer<Int32> thresholdArrayPointer = cStringArrayPointer.ref.thresholdArray;

    List<String> dataStringList = List.generate(
      length,
          (index) => (dataArrayPointer + index).value.toDartString(),
    );
    List<String> rawValueStringList = List.generate(
      length,
          (index) => (rawValueArrayPointer + index).value.toDartString(),
    );
    dartIntArray = intArrayPointer.asTypedList(length);
    dartIdArray = idArrayPointer.asTypedList(length);
    dartWorstArray = worstArrayPointer.asTypedList(length);
    dartThresholdArray = thresholdArrayPointer.asTypedList(length);
    dartRawValueList = rawValueStringList;
    freeMultipleArrays(cStringArrayPointer);
    return dataStringList;
  }

  void getDriveInfo(buffer, size) {
    final GetDriveInfoDart func= harddriveLibrary.lookupFunction<GetDriveInfoC, GetDriveInfoDart>('GetDriveInfo');
    func(buffer, size);
  }
}
import 'dart:io';
import 'dart:convert';

class BatteryInfoGetter{
  Future<String> batteryInfoMain(String command) async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get',command
      ],
      null
    );
  }

  Future<String> batteryInfo() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get EstimatedChargeRemaining',
      ],
      null
    );
  }

  Future<String> batteryInfoTwo() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get BatteryStatus',
      ],
      null
    );
  }

  Future<String> availability() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Availability',
      ],
      null
    );
  }

  Future<String> batteryRechargeTime() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get BatteryRechargeTime',
      ],
      null
    );
  }

  Future<String> batteryStatus() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get BatteryStatus',
      ],
      null
    );
  }

  Future<String> caption() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Caption',
      ],
      null
    );
  }

  Future<String> chemistry() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Chemistry',
      ],
      null
    );
  }

  Future<String> configManagerErrorCode() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get ConfigManagerErrorCode',
      ],
      null
    );
  }

  Future<String>  configManagerUserConfig() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get  ConfigManagerUserConfig',
      ],
      null
    );
  }

  Future<String> creationClassName() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get CreationClassName',
      ],
      null
    );
  }

  Future<String> description() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Description',
      ],
      null
    );
  }

  Future<String> designCapacity() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get DesignCapacity',
      ],
      null
    );
  }

  Future<String> designVoltage() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get DesignVoltage',
      ],
      null
    );
  }

  Future<String> deviceID() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get DeviceID',
      ],
      null
    );
  }

  Future<String> errorCleared() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get ErrorCleared',
      ],
      null
    );
  }

  Future<String> errorDescription() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get ErrorDescription',
      ],
      null
    );
  }

  Future<String> estimatedChargeRemaining() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get EstimatedChargeRemaining',
      ],
      null
    );
  }

  Future<String> estimatedRunTime() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get EstimatedRunTime',
      ],
      null
    );
  }

  Future<String> expectedBatteryLife() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get ExpectedBatteryLife',
      ],
      null
    );
  }

  Future<String> expectedLife() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get ExpectedLife',
      ],
      null
    );
  }

  Future<String> fullChargeCapacity() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get FullChargeCapacity',
      ],
      null
    );
  }

  Future<String> installDate() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get InstallDate',
      ],
      null
    );
  }

  Future<String> lastErrorCode() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get LastErrorCode',
      ],
      null
    );
  }

  Future<String> maxRechargeTime() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get MaxRechargeTime',
      ],
      null
    );
  }

  Future<String> name() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Name',
      ],
      null
    );
  }

  Future<String> pNPDeviceID() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get PNPDeviceID',
      ],
      null
    );
  }

  Future<String> powerManagementCapabilities() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get PowerManagementCapabilities',
      ],
      null
    );
  }

  Future<String> powerManagementSupported() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get PowerManagementSupported',
      ],
      null
    );
  }

  Future<String> smartBatteryVersion() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get SmartBatteryVersion',
      ],
      null
    );
  }

  Future<String> status() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get Status',
      ],
      null
    );
  }

  Future<String> statusInfo() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get StatusInfo',
      ],
      null
    );
  }

  Future<String> systemCreationClassName() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get SystemCreationClassName',
      ],
      null
    );
  }

  Future<String> systemName() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get SystemName',
      ],
      null
    );
  }

  Future<String> timeOnBattery() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get TimeOnBattery',
      ],
      null
    );
  }

  Future<String> timeToFullCharge() async {
    return runcmd(
      'powershell.exe',
      [
        'wmic PATH Win32_Battery Get TimeToFullCharge',
      ],
      null
    );
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

      final lines = output.split("\r\n");
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


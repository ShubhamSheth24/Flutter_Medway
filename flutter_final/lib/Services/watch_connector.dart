import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WatchConnector {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _heartRateCharacteristic;
  ValueNotifier<String> heartRate = ValueNotifier<String>("97");
  bool _isFetching = false;

  WatchConnector() {
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    if (!(await FlutterBluePlus.isOn)) {
      debugPrint("Bluetooth is off. Please turn it on.");
      heartRate.value = "Bluetooth Off";
      return;
    }
    _connectToWatch();
  }

  Future<void> _connectToWatch() async {
    _isFetching = true;
    heartRate.value = "Scanning...";

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        debugPrint("Found: ${result.device.name} (ID: ${result.device.id})");
        if (result.device.name == "CB-ARMOUR") {
          debugPrint("Attempting to connect to CB-ARMOUR");
          await _connectToDevice(result.device);
          break;
        }
      }
    });

    await Future.delayed(const Duration(seconds: 10), () {
      FlutterBluePlus.stopScan();
      if (_connectedDevice == null) {
        heartRate.value = "CB-ARMOUR Not Found";
        _isFetching = false;
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      debugPrint("Connected to ${device.name}");

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        debugPrint("Service found: ${service.uuid}");
        if (service.uuid.toString() == "0000180d-0000-1000-8000-00805f9b34fb") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            debugPrint("Characteristic found: ${characteristic.uuid}");
            if (characteristic.uuid.toString() == "00002a37-0000-1000-8000-00805f9b34fb") {
              _heartRateCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                if (value.isNotEmpty) {
                  _isFetching = false;
                  heartRate.value = _parseHeartRate(value);
                  debugPrint("Heart Rate: ${heartRate.value}");
                }
              });
              break;
            }
          }
          break;
        }
      }
      if (_heartRateCharacteristic == null) {
        heartRate.value = "No Heart Rate Service on CB-ARMOUR";
        _isFetching = false;
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      heartRate.value = "Error: $e";
      _isFetching = false;
    }
  }

  String _parseHeartRate(List<int> value) {
    if (value.isNotEmpty) {
      bool is16Bit = (value[0] & 0x01) == 1;
      if (is16Bit && value.length >= 3) {
        return ((value[2] << 8) + value[1]).toString();
      } else if (!is16Bit && value.length >= 2) {
        return value[1].toString();
      }
    }
    return "N/A";
  }

  bool get isFetching => _isFetching;

  void dispose() {
    _connectedDevice?.disconnect();
    FlutterBluePlus.stopScan();
  }
}
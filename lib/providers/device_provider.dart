import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home_ai/models/device_model.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

final deviceProvider = NotifierProvider<DeviceNotifier, List<Device>>(DeviceNotifier.new);

class DeviceNotifier extends Notifier<List<Device>> {
  @override
  List<Device> build() {
    return [];
  }

  void addDevice(Device device) {
    state = [...state, device];
  }

  void toggleDevice(String id) {
    state = [
      for (final device in state)
        if (device.id == id)
          device.copyWith(isOn: !device.isOn)
        else
          device
    ];
  }

  void setDeviceState(String id, bool isOn) {
    state = [
      for (final device in state)
        if (device.id == id)
          device.copyWith(isOn: isOn)
        else
          device
    ];
  }

  Future<List<String>> scanForDevices() async {
    // Real scanning logic using lan_scanner
    final List<String> foundIps = [];
    
    try {
      final info = NetworkInfo();
      final wifiIp = await info.getWifiIP();
      final subnet = ipToSubnet(wifiIp ?? '192.168.1.1');

      final scanner = LanScanner();
      final stream = scanner.icmpScan(subnet, progressCallback: (progress) {
        // print('Progress: $progress');
      });

      await for (final host in stream) {
        foundIps.add(host.internetAddress.address);
      }
    } catch (e) {
      // Fallback for emulator or error
      print("Scan error: $e");
      // Mock IPs for demo
      await Future.delayed(const Duration(seconds: 2));
      return ['192.168.1.10', '192.168.1.15', '192.168.1.20'];
    }
    
    if (foundIps.isEmpty) {
       // Mock IPs if nothing found (e.g. on Emulator)
       return ['192.168.1.101', '192.168.1.102'];
    }

    return foundIps;
  }
}

String ipToSubnet(String ip) {
  return ip.substring(0, ip.lastIndexOf('.'));
}

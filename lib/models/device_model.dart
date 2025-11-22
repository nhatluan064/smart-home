import 'package:flutter/material.dart';

enum DeviceType {
  light,
  fan,
  ac,
  tv,
  pc,
  other,
}

class Device {
  final String id;
  final String homeId; // New: Link to Home
  final String name;
  final DeviceType type;
  final String ipAddress;
  bool isOn;

  Device({
    required this.id,
    required this.homeId,
    required this.name,
    required this.type,
    required this.ipAddress,
    this.isOn = false,
  });

  IconData get icon {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.fan:
        return Icons.wind_power;
      case DeviceType.ac:
        return Icons.ac_unit;
      case DeviceType.tv:
        return Icons.tv;
      case DeviceType.pc:
        return Icons.computer;
      case DeviceType.other:
        return Icons.devices_other;
    }
  }

  Device copyWith({
    String? id,
    String? homeId,
    String? name,
    DeviceType? type,
    String? ipAddress,
    bool? isOn,
  }) {
    return Device(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      name: name ?? this.name,
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      isOn: isOn ?? this.isOn,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home_ai/models/device_model.dart';
import 'package:smart_home_ai/providers/device_provider.dart';
import 'package:smart_home_ai/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:uuid/uuid.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  DeviceType? _selectedType;
  bool _isScanning = false;
  List<String> _foundIps = [];
  String? _selectedIp;
  final _nameController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'type': DeviceType.light, 'icon': Icons.lightbulb, 'label': 'Light'},
    {'type': DeviceType.fan, 'icon': Icons.wind_power, 'label': 'Fan'},
    {'type': DeviceType.ac, 'icon': Icons.ac_unit, 'label': 'AC'},
    {'type': DeviceType.tv, 'icon': Icons.tv, 'label': 'TV'},
    {'type': DeviceType.pc, 'icon': Icons.computer, 'label': 'PC'},
    {'type': DeviceType.other, 'icon': Icons.devices_other, 'label': 'Other'},
  ];

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _foundIps = [];
      _selectedIp = null;
    });

    final ips = await ref.read(deviceProvider.notifier).scanForDevices();

    if (mounted) {
      setState(() {
        _isScanning = false;
        _foundIps = ips;
      });
    }
  }

  void _addDevice() {
    if (_selectedType != null && _selectedIp != null && _nameController.text.isNotEmpty) {
      final authState = ref.read(authProvider);
      final homeId = authState.currentHome?.id ?? 'default_home';

      final newDevice = Device(
        id: const Uuid().v4(),
        homeId: homeId,
        name: _nameController.text,
        type: _selectedType!,
        ipAddress: _selectedIp!,
      );
      
      ref.read(deviceProvider.notifier).addDevice(newDevice);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Add New Device', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Category', style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedType == cat['type'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = cat['type'];
                        _nameController.text = cat['label']; // Default name
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.cyanAccent : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: Colors.cyanAccent, width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'], color: isSelected ? Colors.black : Colors.white),
                          SizedBox(height: 5),
                          Text(
                            cat['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (_selectedType != null) ...[
              SizedBox(height: 30),
              FadeInUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Device Name',
                        labelStyle: TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select IP Address', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        TextButton.icon(
                          onPressed: _scanDevices,
                          icon: _isScanning 
                              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                              : Icon(Icons.refresh),
                          label: Text(_isScanning ? 'Scanning...' : 'Scan Network'),
                          style: TextButton.styleFrom(foregroundColor: Colors.cyanAccent),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _foundIps.isEmpty && !_isScanning
                          ? Center(child: Text('No devices found. Try scanning.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _foundIps.length,
                              itemBuilder: (context, index) {
                                final ip = _foundIps[index];
                                return ListTile(
                                  title: Text(ip, style: TextStyle(color: Colors.white)),
                                  leading: Icon(Icons.wifi, color: Colors.white),
                                  trailing: _selectedIp == ip ? Icon(Icons.check_circle, color: Colors.cyanAccent) : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedIp = ip;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],

            Spacer(),
            
            if (_selectedIp != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ADD DEVICE',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

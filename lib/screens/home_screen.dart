import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home_ai/providers/auth_provider.dart';
import 'package:smart_home_ai/providers/device_provider.dart';
import 'package:smart_home_ai/providers/voice_provider.dart';
import 'package:smart_home_ai/screens/add_device_screen.dart';
import 'package:smart_home_ai/screens/share_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final devices = ref.watch(deviceProvider);
    final voiceState = ref.watch(voiceProvider);
    final voiceNotifier = ref.read(voiceProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authState.ownerName ?? "User"}',
              style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white),
            ),
            Text(
              '${devices.length} Active Devices',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.purpleAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShareHomeScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Voice Assistant Status
            if (voiceState.isListening || voiceState.isSpeaking)
              FadeInDown(
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        voiceState.isListening ? Icons.mic : Icons.volume_up,
                        color: Colors.cyanAccent,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          voiceState.isListening
                              ? "Listening..."
                              : (voiceState.isSpeaking ? "Speaking..." : ""),
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Device Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ZoomIn(
                    delay: Duration(milliseconds: index * 100),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(deviceProvider.notifier).toggleDevice(device.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: device.isOn ? Colors.cyanAccent : Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (device.isOn)
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              device.icon,
                              size: 40,
                              color: device.isOn ? Colors.black : Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              device.name,
                              style: TextStyle(
                                color: device.isOn ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              device.isOn ? "ON" : "OFF",
                              style: TextStyle(
                                color: device.isOn ? Colors.black54 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onLongPress: () {
          voiceNotifier.startListening();
        },
        onLongPressUp: () {
          voiceNotifier.stopListening();
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: voiceState.isListening ? Colors.redAccent : Colors.cyanAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (voiceState.isListening ? Colors.redAccent : Colors.cyanAccent)
                    .withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Icon(
            voiceState.isListening ? Icons.mic : Icons.mic_none,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
    );
  }
}

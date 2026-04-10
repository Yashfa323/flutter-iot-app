import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceScreen extends StatefulWidget {
  final String deviceName;
  final bool isOnline;

  const DeviceScreen({
    super.key,
    required this.deviceName,
    required this.isOnline,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {

  String lastEvent = "";

  // 🔥 SEND COMMAND
  Future<void> sendCommand(String cmd, BuildContext context) async {
    try {
      final ref = FirebaseDatabase.instance.ref("devices/${widget.deviceName}");

      await ref.update({
        "command": cmd,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Command Sent: $cmd")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send command")),
      );
    }
  }

  void showEventPopup(String event) {
    if (event.isEmpty || event == lastEvent) return;

    lastEvent = event;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 Event Triggered"),
        content: Text(event),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final ref = FirebaseDatabase.instance.ref("devices/${widget.deviceName}");

    return Scaffold(
      appBar: AppBar(title: Text(widget.deviceName)),

      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;

          if (data == null) {
            return const Center(child: Text("No data"));
          }

          final device = Map<String, dynamic>.from(data as dynamic);

          final bool online = device["isOnline"] ?? false;
          final String status = device["status"] ?? "UNKNOWN";
          final String event = device["event"] ?? "";

          // 🔥 SHOW POPUP WHEN EVENT CHANGES
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showEventPopup(event);
          });

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // 🔥 ONLINE STATUS
                Text(
                  online ? "ONLINE" : "OFFLINE",
                  style: TextStyle(
                    fontSize: 20,
                    color: online ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 DEVICE STATUS
                Text(
                  "Status: $status",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 10),

                // 🔥 EVENT DISPLAY
                Text(
                  event.isEmpty ? "No Event" : "Event: $event",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔥 TURN ON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => sendCommand("ON", context),
                    child: const Text("TURN ON"),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 TURN OFF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => sendCommand("OFF", context),
                    child: const Text("TURN OFF"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
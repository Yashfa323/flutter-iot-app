import 'package:flutter/material.dart';
import 'add_device_screen.dart';
import 'device_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    // ✅ UPDATED PATH
    final ref = FirebaseDatabase.instance.ref("devices");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Devices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;

          if (data == null) {
            return const Center(child: Text("No devices added"));
          }

          final devices = Map<String, dynamic>.from(data as dynamic);

          return ListView(
            children: devices.entries.map((entry) {

              final device = Map<String, dynamic>.from(entry.value);

              return DeviceCard(
                name: device["name"] ?? entry.key,
                isOnline: device["isOnline"] ?? false,
              );

            }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddDeviceScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final String name;
  final bool isOnline;

  const DeviceCard({
    super.key,
    required this.name,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeviceScreen(
                deviceName: name,
                isOnline: isOnline,
              ),
            ),
          );
        },
        leading: Icon(
          Icons.memory,
          color: isOnline ? Colors.green : Colors.red,
        ),
        title: Text(name),
        subtitle: Text(
          isOnline ? "Online" : "Offline",
          style: TextStyle(
            color: isOnline ? Colors.green : Colors.red,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
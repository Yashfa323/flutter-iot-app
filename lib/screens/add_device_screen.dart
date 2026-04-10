import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {

  String token = "";

  @override
  void initState() {
    super.initState();
    generateToken();
  }

  void generateToken() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    final rand = Random();
    token = List.generate(12, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> addDevice() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref();

      // ✅ UPDATED PATH
      await ref.child("devices/$token").set({
        "name": token,
        "isOnline": false,
        "command": "OFF",
        "status": "OFF",
        "event": "",
      });

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add device")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Device")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text("Device Token", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            SelectableText(
              token,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addDevice,
                child: const Text("Add Device"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
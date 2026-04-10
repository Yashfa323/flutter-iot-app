import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passController = TextEditingController();

  final auth = FirebaseAuth.instance;

  bool isLogin = true;
  bool isLoading = false;

  Future<void> submit() async {

    String email = emailController.text.trim();
    String password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMsg("Enter email & password");
      return;
    }

    setState(() => isLoading = true);

    try {

      if (isLogin) {
        // 🔹 LOGIN
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // 🔹 SIGNUP
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      showMsg(e.message ?? "Error");
    }

    setState(() => isLoading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Login" : "Signup"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isLogin ? "Login" : "Signup"),
              ),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? "Create new account"
                    : "Already have account?",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
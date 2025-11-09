import 'package:admin_web_portal/functions/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../homeScreen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  bool isPasswordVisible = false; // Track password visibility

  // Regular expression to validate password strength
  final RegExp passwordRegExp = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Function to validate the password against the required conditions
  bool validatePassword(String password) {
    return passwordRegExp.hasMatch(password);
  }

  allowAdminToLogin() async {
    if (email == "" || password == "") {
      showReusableSnackBar(context, "Please provide email & password.");
    } else if (!validatePassword(password)) {
      showReusableSnackBar(context,
          "Password must be at least 8 characters long and contain uppercase, lowercase, digits, and special characters.");
    } else {
      //allow admin to login
      User? currentAdmin;
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        currentAdmin = value.user;
      }).catchError((error) {
        showReusableSnackBar(context, "Error Occurred: " + error.toString());
      });

      //check in database if admin record exists
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(currentAdmin!.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => HomeScreen()));
        } else {
          showReusableSnackBar(
              context, "No record found, you are not an admin.");
        }
      });
    }
  }

  Future<void> resetPassword() async {
    if (email.isEmpty) {
      showReusableSnackBar(context, "Please enter your email address.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showReusableSnackBar(context, "Password reset email sent!");
    } catch (e) {
      showReusableSnackBar(context, "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("images/admin.png"),

                  TextField(
                    onChanged: (value) {
                      email = value;
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurpleAccent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: 2,
                        ),
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      icon: Icon(
                        Icons.email,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  TextField(
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: !isPasswordVisible, // Toggle visibility
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurpleAccent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: 2,
                        ),
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.grey,),
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.deepPurpleAccent,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.deepPurpleAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible; // Toggle state
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: () {
                      showReusableSnackBar(
                          context, "Checking Credentials, Please wait...");

                      allowAdminToLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 20),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  // Forgot Password hyperlink
                  GestureDetector(
                    onTap: () {
                      resetPassword(); // Call the reset password function
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline, // Underline text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  String newPassword = "";
  bool isPasswordVisible = false;
  String warningMessage = ""; // For displaying warning messages

  // Regular expression to validate password strength
  final RegExp passwordRegExp = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Function to validate the password against the required conditions
  bool validatePassword(String password) {
    return passwordRegExp.hasMatch(password);
  }

  void updatePassword() async {
    // Reset the warning message
    setState(() {
      warningMessage = "";
    });

    if (!validatePassword(newPassword)) {
      setState(() {
        warningMessage =
        "Password must be at least 8 characters long and contain uppercase, lowercase, digits, and special characters.";
      });
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(newPassword);
      showReusableSnackBar(context, "Password updated successfully!");
      Navigator.pop(context); // Go back to login
    } catch (e) {
      showReusableSnackBar(context, "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  newPassword = value;
                },
                obscureText: !isPasswordVisible,
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
                  hintText: "New Password",
                  hintStyle: const TextStyle(color: Colors.grey,),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              // Display warning message if any
              if (warningMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    warningMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 10,),

              ElevatedButton(
                onPressed: updatePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 20),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                child: const Text(
                  "Update Password",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utility function to show SnackBars
void showReusableSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
}

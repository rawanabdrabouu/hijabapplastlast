import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hijaby_app/screens/signUpPage.dart';
import 'package:hijaby_app/screens/home_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sign In',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  "Start by signing in using your email and password",
                  textAlign: TextAlign.center,
                ),
                SignInForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  String email = "";
  String password = "";

  void addError(String error) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError(String error) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<String> loginUser(String email, String password) async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> users = json.decode(response.body);
        bool userExists = users.values.any((user) =>
            user['email'] == email && user['password'] == password);

        if (userExists) {
          // to keep track of logged in user
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isLoggedIn", true);
          prefs.setString("email", email);

          print('User found');
          return 'User found';
        } else {
          print('User not found');
          return 'User not found';
        }
      } else {
        print('Failed to load users');
        return 'Failed to load users';
      }
    } catch (err) {
      if (err.toString().contains('Failed host lookup')) {
        return 'Connection issues';
      }
      print("Error: " + err.toString());
      return 'Error: $err';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue!,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError("Please enter your email");
                removeError("User not found");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError("Please enter your email");
                return "Please enter your email";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.purpleAccent),
                gapPadding: 10,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.purpleAccent),
                gapPadding: 10,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => password = newValue!,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError("Please enter your password");
                removeError("User not found");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError("Please enter your password");
                return "Please enter your password";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.purpleAccent),
                gapPadding: 10,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.purpleAccent),
                gapPadding: 10,
              ),
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: List.generate(
              errors.length,
              (index) => formErrorText(error: errors[index]),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Sign In"),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                String response = await loginUser(email, password);
                if (response == 'User not found') {
                  addError("User not found");
                } else if (response == 'User found') {
                  // Navigate to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen())
                  );
                } else if (response == 'Connection issues' || response == "Error: ClientException: XMLHttpRequest error., uri=https://e-commerce-mobile-proj-default-rtdb.firebaseio.com/users.json") {
                  addError("There are connection issues. Please try again later.");
                } else {
                  addError(response);
                }
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Sign Up Instead"),
            onPressed: () async {
              // Navigate to the next screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage())
              );
            },
          ),
        ],
      ),
    );
  }

  Row formErrorText({required String error}) {
    return Row(
      children: [
        SvgPicture.asset(
          "icons/Error.svg",
          height: 14,
          width: 14,
        ),
        SizedBox(width: 10),
        Text(error),
      ],
    );
  }
}

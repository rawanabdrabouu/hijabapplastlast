import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijaby_app/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sign Up',
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
                  "Welcome!",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  "Start by registering using your user information",
                  textAlign: TextAlign.center,
                ),
                SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  String name = "";
  String email = "";
  String password = "";
  String role = "";

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

  Future<String> registerUser(String name, String email, String password, String role) async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.post(
      url,
      body: json.encode({
        'name': name,
        'role': role,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      print('User registered successfully');
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // to keep track of logged in user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", true);
      prefs.setString("email", email);

      return 'registered ${responseData['name']}';
    } else {
      print('Failed to register user');
      return 'Failed to register user';
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
            keyboardType: TextInputType.name,
            onSaved: (newValue) => name = newValue!,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError("Please enter your name");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError("Please enter your name");
                return "Please enter your name";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Name",
              hintText: "Enter your name",
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
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue!,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError("Please enter your email");
                removeError("Failed to register user");
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
                removeError("Failed to register user");
              }
              if (value.length >= 8) {
                removeError("Please enter a longer password");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError("Please enter your password");
                return "Please enter your password";
              } else if (value.length < 8) {
                addError("Please enter a longer password");
                return "Please enter a longer password";
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
            child: Text("Sign Up"),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                String response = await registerUser(name, email, password, "user");
                if (response == 'Failed to register user') {
                  addError("Failed to register user");
                } else if (response.contains('registered')) {
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
            child: Text("Sign In Instead"),
            onPressed: () async {
              // Navigate to the prev screen
              Navigator.pop(
                context
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

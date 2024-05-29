import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijaby_app/screens/signInPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hijaby_app/screens/Vendor/choose_product_discount.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var name = '';
  var email = '';
  var password = '';
  var role = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  var loginStatus = "";
  var loggedInEmail = "";
  var loggedInId = "";
  var loggedInRole = "";

  Future<void> initializesharedPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      loginStatus = _prefs.getBool('isLoggedIn').toString();
      loggedInEmail = _prefs.getString('email').toString();
    });
  }

  Future<void> getUserInfo() async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        responseData.forEach((key, value) {
          if (value['email'] == loggedInEmail) {
            loggedInId = key;
            nameController.text = value['name'];
            emailController.text = value['email'];
            passwordController.text = value['password'];
            roleController.text = value['role'];
            loggedInRole = value['role'];
          }
        });
      } else {
        print('Failed to get users data');
      }
    } catch (err) {
      print("Error: " + err.toString());
    }
  }

  Future<void> updateUserInfo(String newName, String newPassword) async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users/${loggedInId}.json');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'email': emailController.text,
          'name': newName,
          'password': newPassword,
          'role': roleController.text,
        }),
      );
      if (response.statusCode == 200) {
        print('User info updated successfully');
      } else {
        print('Failed to update users data');
      }
    } catch (err) {
      print("Error: " + err.toString());
    }
  }

  Future<void> updateUserRole(String newRole) async{
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users/${loggedInId}.json');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'email': emailController.text,
          'name': nameController.text,
          'password': passwordController.text,
          'role': newRole,
        }),
      );
      if (response.statusCode == 200) {
        print('User info updated successfully');
      } else {
        print('Failed to update users data');
      }
    } catch (err) {
      print("Error: " + err.toString());
    }
  }
  
  @override
  void initState() {
    super.initState();
    initializesharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Hijab Boutique',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Hijab Boutique',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text("Logout"),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Implement edit name functionality
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Implement edit password functionality
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: roleController,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var newName = nameController.text;
                            var newPass = passwordController.text;
                            await updateUserInfo(newName, newPass);
                          },
                          child: Text('Update Data'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        if (loggedInRole == 'user')
                          ElevatedButton(
                            onPressed: () async{
                              var newRole = "vendor";
                              await updateUserRole(newRole);
                            },
                            child: Text('Are you a seller?'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        if (loggedInRole == 'vendor')
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductListScreen())
                              );
                            },
                            child: Text('Announce a discount'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

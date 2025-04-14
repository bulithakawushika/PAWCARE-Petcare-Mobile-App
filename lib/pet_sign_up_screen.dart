import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_screen.dart';

class PetSignUpScreen extends StatefulWidget {
  @override
  _PetSignUpScreenState createState() => _PetSignUpScreenState();
}

class _PetSignUpScreenState extends State<PetSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  String? _type;
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _birthdayController.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _registerPet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user in Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _ownerEmailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store pet details in Firebase Realtime Database
        await _database.child('users').child(userCredential.user!.uid).set({
          'type': 'pet',
          'petName': _petNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'ownerEmail': _ownerEmailController.text.trim(),
          'birthday': _birthdayController.text.trim(),
          'petType': _type,
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        print('Error during registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFfff2d9),
              Color(0xFFfff2d9),
              Color(0xFFfcd262),
            ],
            stops: [0.0, 0.33, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Image.asset(
                          'images/vetsign.png',
                          height: 100,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Pet Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _ownerNameController,
                          decoration: InputDecoration(labelText: 'Owner Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your owner name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _ownerEmailController,
                          decoration: InputDecoration(labelText: 'Owner Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your owner email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _petNameController,
                          decoration: InputDecoration(labelText: 'Pet Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your pet name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _birthdayController,
                          decoration: InputDecoration(labelText: 'Birthday'),
                          readOnly: true,
                          onTap: () => _selectBirthday(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your birthday';
                            }
                            return null;
                          },
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            popupMenuTheme: PopupMenuThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Type'),
                            value: _type,
                            items: <String>['Cat', 'Dog']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _type = newValue!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your pet type';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_type != null)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text('White Pop Thing Content'),
                          ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _registerPet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFffbc0b),
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                          child: Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

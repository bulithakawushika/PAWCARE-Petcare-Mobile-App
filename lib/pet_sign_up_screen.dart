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
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _ownerEmailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _database.child('users').child(userCredential.user!.uid).set({
          'type': 'pet',
          'petName': _petNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'ownerEmail': _ownerEmailController.text.trim(),
          'birthday': _birthdayController.text.trim(),
          'petType': _type,
        });

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

  Widget _buildPetTypeInfo() {
    if (_type == null) {
      return SizedBox.shrink(); // <<< this makes sure no white space
    }

    String message = '';
    if (_type == 'Cat') {
      message =
          '🐱 You selected Cat! Make sure to provide proper vaccinations and a cozy environment.';
    } else if (_type == 'Dog') {
      message =
          '🐶 You selected Dog! Make sure to ensure regular walks and healthy meals.';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _ownerNameController,
                            decoration:
                                InputDecoration(labelText: 'Owner Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your owner name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _ownerEmailController,
                            decoration:
                                InputDecoration(labelText: 'Owner Email'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your owner email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
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
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Type'),
                            value: _type,
                            items: ['Cat', 'Dog'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Center(
                                  child: Text(
                                    type,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _type = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your pet type';
                              }
                              return null;
                            },
                          ),
                          _buildPetTypeInfo(),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
      ),
    );
  }
}

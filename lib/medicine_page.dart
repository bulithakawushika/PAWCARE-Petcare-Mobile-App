import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'medicine_history_page.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  String medicineName = '';
  String reason = '';

  DateTime? vaccinatedOn;
  DateTime? nextDose;

  int _selectedIndex = 0;
  String _petName = 'My Dog'; // Default pet name
  String _petType = ''; // Default pet type
  final _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchMedicines();
    _fetchPetData();
  }

  Future<void> _fetchPetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _database.child('users').child(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _petName = snapshot.child('petName').value as String? ?? 'My Dog';
          _petType = snapshot.child('petType').value as String? ?? 'Cat';
        });
      } else {
        print('No data available.');
      }
    }
  }

  List<Map<dynamic, dynamic>> medicines = [];

  Future<void> fetchMedicines() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    if (email != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("medicines");
      ref.orderByChild("ownerEmail").equalTo(email).onValue.listen((event) {
        print('Data from Firebase: ${event.snapshot.value}');
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          medicines.clear();
          data.forEach((key, value) {
            medicines.add(value);
          });

          // Sort medicines by nextDose
          medicines.sort((a, b) {
            DateTime? nextDoseA = DateTime.tryParse(a['nextDose'] ?? '');
            DateTime? nextDoseB = DateTime.tryParse(b['nextDose'] ?? '');

            if (nextDoseA == null && nextDoseB == null) {
              return 0;
            } else if (nextDoseA == null) {
              return 1; // Treat null as later date
            } else if (nextDoseB == null) {
              return -1; // Treat null as later date
            } else {
              return nextDoseA.compareTo(nextDoseB);
            }
          });

          print('Medicines list: $medicines');
          setState(() {});
        } else {
          medicines.clear();
          print('No data found for this user.');
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      appBar: AppBar(
        title: const Text('Set Medicine'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            child: Card(
              color: const Color(0xFFffbc0b),
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _petName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _petType,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    ClipOval(
                      child: Image.asset(
                        'images/my_dog.jpeg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                if (medicines[index]['nextDose'] != null) {
                  try {
                    DateTime nextDoseDate =
                        DateTime.parse(medicines[index]['nextDose']);
                    print('Next Dose Date: $nextDoseDate');
                    print('Today: ${DateTime.now()}');
                    print('Is After: ${nextDoseDate.isAfter(DateTime.now())}');
                    if (nextDoseDate.isAfter(DateTime.now())) {
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicines[index]['medicineName'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    medicines[index]['reason'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Next Dose: ${DateFormat('yyyy-MM-dd').format(nextDoseDate)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.yellow,
                                      Colors.green,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    nextDoseDate
                                        .difference(DateTime.now())
                                        .inDays
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  } catch (e) {
                    print('Error parsing date: $e');
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFffbc0b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MedicineHistoryPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Text(
                'History',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFfff2d9),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add a medicine/vaccine",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Medicine/Vaccine',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            medicineName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025, 12, 31),
                          );
                          if (picked != null) {
                            setState(() {
                              vaccinatedOn = picked;
                            });
                            setState(() {}); // Explicitly call setState again
                          }
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: vaccinatedOn != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(vaccinatedOn!)
                                  : 'Vaccinated On',
                              labelStyle: const TextStyle(color: Colors.grey),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2026, 12, 31),
                          );
                          if (picked != null) {
                            setState(() {
                              nextDose = picked;
                            });
                            setState(() {}); // Explicitly call setState again
                          }
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: nextDose != null
                                  ? DateFormat('yyyy-MM-dd').format(nextDose!)
                                  : 'Next Dose',
                              labelStyle: const TextStyle(color: Colors.grey),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Reason',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            reason = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () async {
                          final User? user = FirebaseAuth.instance.currentUser;
                          final String? email = user?.email;

                          if (email != null) {
                            DatabaseReference ref =
                                FirebaseDatabase.instance.ref("medicines");
                            await ref.push().set({
                              "ownerEmail": email,
                              "medicineName": medicineName,
                              "vaccinatedOn": vaccinatedOn?.toString(),
                              "nextDose": nextDose?.toString(),
                              "reason": reason,
                            });
                            Navigator.of(context).pop();
                            setState(() {
                              medicineName = '';
                              reason = '';
                              vaccinatedOn = null;
                              nextDose = null;
                            });
                          } else {
                            print('User email is null');
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Add',
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.arrow_right, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}

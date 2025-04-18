import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class MedicineHistoryPage extends StatefulWidget {
  @override
  _MedicineHistoryPageState createState() => _MedicineHistoryPageState();
}

class _MedicineHistoryPageState extends State<MedicineHistoryPage> {
  List<Map<dynamic, dynamic>> medicines = [];

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Future<void> fetchMedicines() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    if (email != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("medicines");
      ref.orderByChild("ownerEmail").equalTo(email).onValue.listen((event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          medicines.clear();
          data.forEach((key, value) {
            medicines.add(value);
          });

          // Filter medicines where nextDose is before today
          medicines = medicines.where((medicine) {
            DateTime? nextDose = DateTime.tryParse(medicine['nextDose'] ?? '');
            return nextDose != null && nextDose.isBefore(DateTime.now());
          }).toList();

          // Sort medicines by nextDose
          medicines.sort((a, b) {
            DateTime? nextDoseA = DateTime.tryParse(a['nextDose'] ?? '');
            DateTime? nextDoseB = DateTime.tryParse(b['nextDose'] ?? '');

            if (nextDoseA == null && nextDoseB == null) {
              return 0;
            } else if (nextDoseA == null) {
              return 1;
            } else if (nextDoseB == null) {
              return -1;
            } else {
              int daysA = nextDoseA.difference(DateTime.now()).inDays;
              int daysB = nextDoseB.difference(DateTime.now()).inDays;
              return daysB.compareTo(daysA); // largest days at the top
            }
          });
          setState(() {});
        } else {
          medicines.clear();
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
        title: const Text('Medicine History'),
      ),
      body: medicines.isEmpty
          ? const Center(
              child: Text('No medicine history found.'),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
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
                              'Next Dose: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(medicines[index]['nextDose']))}',
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
                                const Color(0xffFFBC0B),
                                const Color(0xffFFBC0B),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              DateTime.parse(medicines[index]['nextDose'])
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
              },
            ),
    );
  }
}

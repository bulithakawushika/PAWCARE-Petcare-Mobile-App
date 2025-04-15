import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<Goal> goals = [];
  final databaseReference = FirebaseDatabase.instance.ref().child('goals');

  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _scheduleDailyRenewal();
  }

  Future<void> _fetchGoals() async {
    DatabaseEvent event = await databaseReference.once();
    DataSnapshot dataSnapshot = event.snapshot;

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> data = dataSnapshot.value as Map;
      List<Goal> fetchedGoals = [];
      data.forEach((key, value) {
        final lastUpdated = value['lastUpdated'] ?? "";
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        bool? isComplete = value['isComplete'];

        if (lastUpdated != currentDate) {
          isComplete = null; // Reset if the date doesn't match
        }

        fetchedGoals.add(Goal(
          goalId: key,
          title: value['title'],
          isComplete: isComplete,
          lastUpdated: lastUpdated,
        ));
      });
      setState(() {
        goals = fetchedGoals;
      });
    } else {
      // If no data exists, create default goals in Firebase
      _createDefaultGoals();
    }
  }

  Future<void> _createDefaultGoals() async {
    List<String> defaultGoalTitles = [
      'Provide morning meal',
      'Provide lunch meal',
      'Provide dinner meal',
      'Provide fresh water',
    ];

    for (String title in defaultGoalTitles) {
      DatabaseReference newGoalRef = databaseReference.push();
      await newGoalRef.set({
        'title': title,
        'isComplete': null,
        'lastUpdated': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
    }
    _fetchGoals(); // Fetch the newly created goals
  }

  void _scheduleDailyRenewal() {
    final now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    Duration timeUntilMidnight = midnight.difference(now);
    Timer(timeUntilMidnight, () {
      setState(() {
        for (var goal in goals) {
          goal.isComplete = null;
          goal.lastUpdated = DateFormat('yyyy-MM-dd').format(DateTime.now());
          _updateGoalInFirebase(goal);
        }
      });
      _scheduleDailyRenewal(); // Schedule the next renewal
    });
  }

  Future<void> _updateGoalInFirebase(Goal goal) async {
    await databaseReference.child(goal.goalId!).update({
      'isComplete': goal.isComplete,
      'lastUpdated': goal.lastUpdated ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFffeecc),
        child: Stack(
          children: [
            ClipPath(
              clipper: HalfCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                color: const Color(0xFFfff2d9),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 8 - 75,
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: 150,
                child: Image.asset(
                  'images/goals.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
              color: const Color(0xFFffeecc),
              height: MediaQuery.of(context).size.height * 3 / 4,
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  Color statusColor;
                  String statusText = "";

                  if (goal.isComplete == true) {
                    statusColor = Colors.green;
                    statusText = "Complete";
                  } else if (goal.isComplete == false) {
                    statusColor = Colors.red;
                    statusText = "Incomplete";
                  } else {
                    statusColor = Colors.black;
                  }

                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: goal.isComplete != null ? Colors.grey[300] : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              goal.title,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    setState(() {
                                      goal.isComplete = true;
                                      goal.lastUpdated = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                      _updateGoalInFirebase(goal);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      goal.isComplete = false;
                                      goal.lastUpdated = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                      _updateGoalInFirebase(goal);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (goal.isComplete != null)
                          Text(
                            "Status: $statusText",
                            style: TextStyle(color: statusColor, fontSize: 16),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Goal {
  String? goalId;
  String title;
  bool? isComplete;
  TimeOfDay? time;
  String? lastUpdated;

  Goal({
    this.goalId,
    required this.title,
    this.isComplete,
    this.time,
    this.lastUpdated,
  });
}

class HalfCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

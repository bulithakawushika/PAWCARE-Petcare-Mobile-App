import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userGoalsRef;
  late DatabaseReference defaultGoalsRef;
  List<Goal> goals = [];

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userGoalsRef =
          FirebaseDatabase.instance.ref().child('users/${user!.uid}/goals');
      defaultGoalsRef = FirebaseDatabase.instance.ref().child('default_goals');
      _ensureDefaultGoals();
      _fetchGoals();
      _scheduleDailyRenewal();
    } else {
      print('User not logged in');
    }
  }

  Future<void> _ensureDefaultGoals() async {
    List<String> defaultGoalTitles = [
      'Provide morning meal',
      'Provide lunch meal',
      'Provide dinner meal',
      'Provide fresh water',
    ];

    final defaultSnapshot = await defaultGoalsRef.once();
    if (defaultSnapshot.snapshot.value == null) {
      for (String title in defaultGoalTitles) {
        await defaultGoalsRef.child(title).set(true);
      }
    }

    for (String title in defaultGoalTitles) {
      String goalKey = 'default_goal_${title.replaceAll(" ", "_")}';
      final userSnapshot = await userGoalsRef.child(goalKey).once();
      if (userSnapshot.snapshot.value == null) {
        await userGoalsRef.child(goalKey).set({
          'title': title,
          'isComplete': null,
          'lastUpdated': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
      }
    }
  }

  Future<void> _fetchGoals() async {
    final event = await userGoalsRef.once();
    final dataSnapshot = event.snapshot;
    List<Goal> fetchedGoals = [];

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> data = dataSnapshot.value as Map;
      List<Goal> defaultGoals = [];
      List<Goal> customGoals = [];

      data.forEach((key, value) {
        final title = value['title'];
        final isComplete = value['isComplete'];
        final lastUpdated = value['lastUpdated'] ?? "";
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final isDefault = key.startsWith('default_goal_');

        Goal goal = Goal(
          goalId: key,
          title: title,
          isComplete: lastUpdated == currentDate ? isComplete : null,
          lastUpdated: lastUpdated,
          isDefault: isDefault,
        );

        if (isDefault) {
          defaultGoals.add(goal);
        } else {
          customGoals.add(goal);
        }
      });

      List<String> sortedDefaultTitles = [
        'Provide fresh water',
        'Provide morning meal',
        'Provide lunch meal',
        'Provide dinner meal',
      ];

      List<Goal> sortedDefaultGoals = [];
      for (var title in sortedDefaultTitles) {
        final match = defaultGoals.firstWhere((g) => g.title == title,
            orElse: () => Goal(title: '', isDefault: true));
        if (match.title != '') sortedDefaultGoals.add(match);
      }

      fetchedGoals.addAll(sortedDefaultGoals);
      fetchedGoals.addAll(customGoals);

      setState(() => goals = fetchedGoals);
    }
  }

  void _scheduleDailyRenewal() {
    final now = DateTime.now();
    DateTime midnight =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    Duration timeUntilMidnight = midnight.difference(now);
    Timer(timeUntilMidnight, () {
      setState(() {
        for (var goal in goals) {
          goal.isComplete = null;
          goal.lastUpdated = DateFormat('yyyy-MM-dd').format(DateTime.now());
          _updateGoalInFirebase(goal);
        }
      });
      _scheduleDailyRenewal();
    });
  }

  Future<void> _updateGoalInFirebase(Goal goal) async {
    await userGoalsRef.child(goal.goalId!).update({
      'isComplete': goal.isComplete,
      'lastUpdated':
          goal.lastUpdated ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });
  }

  Future<void> _saveGoalToFirebase(String title, TimeOfDay time) async {
    DatabaseReference newGoalRef = userGoalsRef.push();
    await newGoalRef.set({
      'title': title,
      'time': '${time.hour}:${time.minute}',
      'isComplete': null,
      'lastUpdated': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });
    _fetchGoals();
  }

  Future<void> _deleteGoal(Goal goal) async {
    await userGoalsRef.child(goal.goalId!).remove();
    _fetchGoals();
  }

  void _showGoalDialog(BuildContext context) {
    String goalTitle = '';
    TimeOfDay? goalTime;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFfff2d9),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add a goal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Goal Name',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                onChanged: (val) => goalTitle = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (selectedTime != null) goalTime = selectedTime;
                },
                child: const Text('Set Goal Time',
                    style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  if (goalTitle.isNotEmpty && goalTime != null) {
                    _saveGoalToFirebase(goalTitle, goalTime!);
                    Navigator.pop(context);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add', style: TextStyle(color: Colors.black)),
                    Icon(Icons.arrow_right, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals', style: TextStyle(fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFffbc0b)),
                  ),
                  onPressed: () => _showGoalDialog(context),
                  child: const Text('Set Goal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
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
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: 150,
                child: Image.asset('images/goals.png', fit: BoxFit.contain),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
              height: MediaQuery.of(context).size.height * 3 / 4,
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (_, index) {
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
                      color: goal.isComplete != null
                          ? Colors.grey[300]
                          : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goal.title,
                                    style: const TextStyle(color: Colors.grey)),
                                if (goal.isDefault)
                                  const Text('Default',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold))
                                else
                                  GestureDetector(
                                    onTap: () => _deleteGoal(goal),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                if (goal.isComplete != null)
                                  Text("Status: $statusText",
                                      style: TextStyle(
                                          color: statusColor, fontSize: 16)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    setState(() {
                                      goal.isComplete = true;
                                      goal.lastUpdated =
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now());
                                      _updateGoalInFirebase(goal);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      goal.isComplete = false;
                                      goal.lastUpdated =
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now());
                                      _updateGoalInFirebase(goal);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
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
  String? lastUpdated;
  bool isDefault;

  Goal({
    this.goalId,
    required this.title,
    this.isComplete,
    this.lastUpdated,
    this.isDefault = false,
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

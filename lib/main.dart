import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Services'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? selectedDateTime;
  @override
  void initState() {
    super.initState();
  }

  // static void dataToFirebase() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp();
  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   final city = <String, dynamic>{
  //     "name": "Los Angeles",
  //     "state": "CA",
  //     "country": "USA",
  //     "date": DateTime.now(),
  //   };
  //   print("in firebase");
  //   await db
  //       .collection("cities")
  //       .doc()
  //       .set(city)
  //       .then((value) => print("Success"))
  //       .onError((error, stackTrace) => print("$error"));
  // }

  // void _scheduleOneShotAlarm() async {
  //   await AndroidAlarmManager.oneShotAt(selectedDateTime!, 1, dataToFirebase);
  // }

  void sendSms() async {
    String _result = await sendSMS(
            message: "This is Test Sms",
            recipients: ["03096915024"],
            sendDirect: true)
        .catchError((onError) {
      print(onError);
      
    });
    print(_result);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime!.year,
          selectedDateTime!.month,
          selectedDateTime!.day,
          picked.hour,
          picked.minute,
        );
      });
      await AndroidAlarmManager.oneShotAt(selectedDateTime!, 1, sendSms);
    }
  }

  Future<void> _chooseDate() async {
    DateTime? chosenDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022, 7),
        lastDate: DateTime(2101));

    if (chosenDate != null) {
      setState(() {
        selectedDateTime = chosenDate;
      });
      _selectTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 170,
              height: 50,
              child: ElevatedButton.icon(
                  onPressed: () {
                    _chooseDate();
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("oneShotAt")),
            ),
          ],
        ),
      ),
    );
  }
}

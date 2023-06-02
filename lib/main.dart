import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();
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

  static void showNotification() async {
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: android);
    flip.initialize(settings);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'Sms Reminder', 'Sms',
        channelDescription: 'Notifications Used For Sms Reminder',
        importance: Importance.max,
        priority: Priority.high);

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flip.show(0, 'Arbisoft', 'You are welcome to join us from june 5',
        platformChannelSpecifics,
        payload: 'Default_Sound');
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
      bool isSchedule = await AndroidAlarmManager.oneShotAt(
          selectedDateTime!, 1, showNotification);
      print(isSchedule);
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

  void sheduledNotification() async {
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: android);
    flip.initialize(settings);
    await flip.zonedSchedule(
        0,
        'Arbisoft',
        'You are welcome to join us from june 5',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'Sms Reminder',
            'Sms',
            channelDescription: 'Notifications Used For Sms Reminder',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<List<Contact>> getContacts() async {
    return await FlutterContacts.requestPermission()
        .then((value) => FlutterContacts.getContacts());
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenHeight = screenSize.height;
    var bodyHeight = screenHeight - kToolbarHeight;
    // var width = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: bodyHeight * 0.1,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _chooseDate();
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("oneShotAt"),
                ),
              ),
            ),
            SizedBox(
              height: bodyHeight * 0.1,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: sheduledNotification,
                  icon: const Icon(Icons.notifications),
                  label: const Text("Notify"),
                ),
              ),
            ),
            Container(
              height: bodyHeight * 0.764,
              decoration:  BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius:const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: FutureBuilder(
                future: getContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(index.toString()),
                            ),
                            title: Text(
                                snapshot.data![index].displayName.toString()),
                            subtitle: Text(
                                'Phone number : ${snapshot.data![index].phones.isNotEmpty ? snapshot.data![index].phones.first.number : '(none)'}'),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

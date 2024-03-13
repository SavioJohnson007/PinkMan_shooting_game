import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:robo_combat/Create_room.dart';
import 'package:robo_combat/firebase_options.dart';
import 'package:robo_combat/maps.dart';
import 'package:robo_combat/robo_combat.dart';
import 'package:robo_combat/server/server.dart';


import 'join_room.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  runApp(MyApp());
  // runApp(GameWidget(game:RoboCombat()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home_screen(),
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
    );
  }
}

class PlayerDetails {
  String name = "player";
  int ID = 0;
  double x = 0;
  bool jump = false;
}
PlayerDetails playerDetails = PlayerDetails();

class Home_screen extends StatefulWidget {
  @override
  State<Home_screen> createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {
  String s = playerDetails.name;
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 100,
                  child: Center(
                    child: Text(
                      s,
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black12),
                ),
              ),
              IconButton(onPressed: updateName, icon: Icon(Icons.edit,color: Colors.black,))
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 60,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12),
                child: TextButton(
                  child: Text(
                    'Play',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Create_or_join()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
  TextEditingController controller = TextEditingController();

  void updateName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange),
          content: TextField(
            decoration: InputDecoration(
              hintText: PlayerDetails().name,
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent,width: 10),borderRadius: BorderRadius.circular(10))
            ),
            controller: controller,
          ),
          shadowColor: Colors.black26,
          surfaceTintColor: Colors.blueGrey,
          backgroundColor: Colors.blueGrey.shade900,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),


            ),
            MaterialButton(
              onPressed: () {
                playerDetails.name = controller.text;
                setState(() {
                  s = playerDetails.name;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class Create_or_join extends StatefulWidget {
  @override
  State<Create_or_join> createState() => _Create_or_joinState();
}

class _Create_or_joinState extends State<Create_or_join> {


  Future<void> join() async {
    for (int i = 1; i <= 4; i++) {
      dynamic o = await Server().fetchData(i, 'joined');
      if (o is bool) {
        bool occupied = o;
        if (!occupied) {
          Server().updatePlayerData(i.toString(), 'joined', true);
          Server().updatePlayerData(i.toString(), 'name', playerDetails.name);
          playerDetails.ID = i;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Join_room()),
          );
          break;
        }
      }
    }
  }

  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => Create_room()));
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white70),
                  )),
              height: 60,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black12),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              child: TextButton(
                  onPressed: () {
                    join();
                  },
                  child: Text(
                    'Join',
                    style: TextStyle(color: Colors.white70),
                  )),
              height: 60,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black12),
            )
          ],
        ),
      ),
    ));
  }
}

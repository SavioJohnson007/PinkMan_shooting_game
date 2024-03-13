
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robo_combat/main.dart';
import 'package:robo_combat/robo_combat.dart';
import 'dart:async';

import 'package:robo_combat/server/server.dart';

class Join_room extends StatefulWidget {
  @override
  State<Join_room> createState() => _Create_roomState();
}
bool start_game = false;

class _Create_roomState extends State<Join_room> {

  @override
  void initState() {
    super.initState();

    // Start a periodic timer to simulate data changes
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(!start_game) {
        checkplayerstats();
        check_if_allready();
      }
      else
        _timer.cancel();
    });
  }

  late Timer _timer;


  String player1 = 'waiting..';
  String player2 = 'waiting..';
  String player3 = 'waiting..';
  String player4 = 'waiting..';

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Demo Room",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  Container(
                    height: 40,
                    width: 80,
                    child: Center(
                        child: Text(
                          player1,
                          style: TextStyle(color: Colors.white),
                        )),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                        border: Border.all(color: p1, width: 3)
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    width: 80,
                    child: Center(
                        child: Text(player2,
                            style: TextStyle(color: Colors.white))),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                        border: Border.all(color: p2, width: 3)
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    width: 80,
                    child: Center(
                        child: Text(player3,
                            style: TextStyle(color: Colors.white))),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                        border: Border.all(color: p3, width: 3)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 40,
                    width: 80,
                    child: Center(
                        child: Text(player4,
                            style: TextStyle(color: Colors.white))),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                        border: Border.all(color: p4, width: 3)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                  child: Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black12,
                            image: DecorationImage(
                              image: AssetImage('assets/PinkMan.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,)
                        ),
                      ))),
              Column(
                children: [
                  Container(
                    height: 70,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 3),
                        color: Colors.black12,
                        image: DecorationImage(
                          image: AssetImage('assets/greenyard.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: r),
                    child: TextButton(onPressed: ready,
                        child: Text(
                          'Ready', style: TextStyle(color: Colors.white70),)),
                  ),
                ],
              ),
              SizedBox(
                width: 40,
              )
            ],
          )
        ],
      ),
    ));
  }

  bool all_joined = false;

  Color r = Colors.indigoAccent;
  Color p1 = Colors.red;
  Color p2 = Colors.red;
  Color p3 = Colors.red;
  Color p4 = Colors.red;

  bool all_ready = false;

  void ready() {
    setState(() {
      r = Colors.grey;
    });
    Server().updatePlayerData(playerDetails.ID.toString(), 'ready', true);
  }

  void checkplayerstats() async {
    for (int i = 1; i <= 4; i++) {
      dynamic j = await Server().fetchData(i, 'joined');
      dynamic s = await Server().fetchData(i, 'name');
      dynamic r = await Server().fetchData(i, 'ready');
      bool rdy = r is bool? r : false;
      if (j is bool) {
        bool joined = j;
        if (joined) {
          setState(() {
            switch (i) {
              case 1:
                player1 = s is String? s:"err";
                p1 = rdy? Colors.green : Colors.red;
                break;
              case 2:
                player2 = s is String? s:"err";
                p2 = rdy? Colors.green : Colors.red;
                break;
              case 3:
                player3 = s is String? s:"err";
                p3 = rdy? Colors.green : Colors.red;
                break;
              case 4:
                player4 = s is String? s:"err";
                p4 = rdy? Colors.green : Colors.red;
                break;
            }
          });
        }
      }
    }
  }

  void check_if_allready() async {
    dynamic r1 = await Server().fetchData(1, 'ready');
    bool rdy1 = r1 is bool? r1:false;
    dynamic r2 = await Server().fetchData(2, 'ready');
    bool rdy2 = r2 is bool? r2:false;
    dynamic r3 = await Server().fetchData(3, 'ready');
    bool rdy3 = r3 is bool? r3:false;
    dynamic r4 = await Server().fetchData(4, 'ready');
    bool rdy4 = r4 is bool? r4:false;

    if(rdy1 && rdy2 && rdy3 && rdy4) {
      start_game = true;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameWidget(game:RoboCombat())),
      );
    }

  }
}


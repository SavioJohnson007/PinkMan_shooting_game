import 'dart:async';
import 'dart:io';
import 'dart:ui';


import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robo_combat/health_bar.dart';
import 'package:robo_combat/join_room.dart';
import 'package:robo_combat/main.dart';
import 'package:robo_combat/maps.dart';
import 'package:robo_combat/player.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:robo_combat/server/server.dart';

class RoboCombat extends FlameGame with DragCallbacks {
  @override
  // TODO: implement debugMode
  bool get debugMode => false;

  late final CameraComponent cam;
  final myworld = GameWorld();
  late JoystickComponent joystick;
  late ButtonComponent jumpButton;
  late ButtonComponent fireButton;
  late HealthBar healthbar;

  int jstate = 0;


  String winner ='';
  TextComponent victory = TextComponent();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
        width: 1920, height: 1080, world: myworld);
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;
    myworld.priority = 1;
    addAll([cam, myworld]);

    victory = TextComponent(
        textRenderer: TextPaint(style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.7450980392156863),
            fontSize: 40,
            shadows: [Shadow(color: Colors.black,blurRadius: 100,offset: Offset.fromDirection(3)),Shadow(color: Colors.black)],
            background: (BasicPalette.black.paint()
              ..style = PaintingStyle.fill)
              ..strokeWidth = 2
              ..color = Color.fromRGBO(145, 145, 145, 0.0),
        )),
        anchor: Anchor.center,
        priority: 5,
        position: canvasSize/2,

    );

    addJoystick();
    addJumpButton();
    addFireButton();
    addHealthBar();


    return super.onLoad();
  }


  @override
  void update(double dt) {

    if(alive_players.length == 1){
      winner = alive_players[0].playername;
      victory.text = '$winner won';
      add(victory);
      Future.delayed(Duration(seconds: 3));
      start_game = false;
      for(int i = 1;i<=4;i++)
        {
          Server().updatePlayerData(i.toString(), 'ready', false);
        }
      SystemNavigator.pop;
    }

    updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
        knob: CircleComponent(
            radius: (size.x) / 40,
            paint: (BasicPalette.black.paint()
              ..style = PaintingStyle.stroke)
              ..strokeWidth = 2),
        background: CircleComponent(radius: (size.x) / 20,
            paint: (BasicPalette.black.paint()
              ..style = PaintingStyle.fill)
              ..strokeWidth = 2
              ..color = Color.fromRGBO(255, 255, 255, 0.3803921568627451)),
        margin: EdgeInsets.only(left: 96, bottom: 32),
        priority: 3);
    add(joystick);
  }

  void updateJoystick() async{
    switch (joystick.direction) {
      case JoystickDirection.left:
        if(jstate != -1) {
          all_players[playerDetails.ID-1].horizontalMovement=-1;
          jstate = -1;
        }
        break;
      case JoystickDirection.upLeft:
        if(jstate != -1) {
          all_players[playerDetails.ID-1].horizontalMovement=-1;
          jstate = -1;
        }
        break;
      case JoystickDirection.downLeft:
        if(jstate != -1) {
          all_players[playerDetails.ID-1].horizontalMovement=-1;
          jstate = -1;
        }
        break;
      case JoystickDirection.right:
        if(jstate != 1) {
          all_players[playerDetails.ID-1].horizontalMovement=1;
          jstate = 1;
        }
        break;
      case JoystickDirection.upRight:
        if(jstate != 1) {
          all_players[playerDetails.ID-1].horizontalMovement=1;
          jstate = 1;
        }
        break;
      case JoystickDirection.downRight:
        if(jstate != 1) {
          all_players[playerDetails.ID-1].horizontalMovement=1;
          jstate = 1;
        }
        break;
      case JoystickDirection.up:
        break;
      case JoystickDirection.down:
        break;
      default:{
        if(jstate != 0) {
          all_players[playerDetails.ID-1].horizontalMovement=0;
          jstate = 0;
        }
      }

    }
  }

  // void updateJoystick() async{
  //   switch (joystick.direction) {
  //     case JoystickDirection.left:
  //       if(jstate != -1) {
  //         myworld.myplayer.horizontalMovement =-1;
  //         jstate = -1;
  //       }
  //       break;
  //     case JoystickDirection.upLeft:
  //       if(jstate != -1) {
  //         myworld.myplayer.horizontalMovement =-1;
  //         jstate = -1;
  //       }
  //       break;
  //     case JoystickDirection.downLeft:
  //       if(jstate != -1) {
  //         myworld.myplayer.horizontalMovement =-1;
  //         jstate = -1;
  //       }
  //       break;
  //     case JoystickDirection.right:
  //       if(jstate != 1) {
  //         myworld.myplayer.horizontalMovement =1;
  //         jstate = 1;
  //       }
  //       break;
  //     case JoystickDirection.upRight:
  //       if(jstate != 1) {
  //         myworld.myplayer.horizontalMovement =1;
  //         jstate = 1;
  //       }
  //       break;
  //     case JoystickDirection.downRight:
  //       if(jstate != 1) {
  //         myworld.myplayer.horizontalMovement =1;
  //         jstate = 1;
  //       }
  //       break;
  //     case JoystickDirection.up:
  //       break;
  //     case JoystickDirection.down:
  //       break;
  //     default:{
  //       if(jstate != 0) {
  //         myworld.myplayer.horizontalMovement =0;
  //         jstate = 0;
  //       }
  //     }
  //
  //   }
  // }

  void addJumpButton() async{
    jumpButton = ButtonComponent(

      button: SpriteComponent(sprite: Sprite(images.fromCache('jump.png')),size: Vector2(size.x/20, size.y/9.5),),
      priority: 3,
      position: size - Vector2(150,80),
      onPressed: ()async {
        all_players[playerDetails.ID-1].hasJumped=true;
        // myworld.myplayer.hasJumped = true;
      }
    );
    add(jumpButton);
  }

  void addFireButton() async{
    fireButton = ButtonComponent(
        button: SpriteComponent(sprite: Sprite(images.fromCache('shoot.png')),size: Vector2(size.x/20, size.y/9.5),),
        priority: 3,
        position: size - Vector2(120,140),
        onPressed: ()async {
          Database().updateData(playerDetails.ID, 'fire', true);
          // myworld.myplayer.fire = true;
        }
    );
    add(fireButton);
  }
  void addHealthBar(){
    Player myplayer = Player(playerID: 0);
    switch(playerDetails.ID){
      case 1 :
        myplayer = myworld.player1;
        break;
      case 2 :
        myplayer = myworld.player2;
        break;
      case 3 :
        myplayer = myworld.player3;
        break;
      case 4 :
        myplayer = myworld.player4;
        break;
    }
    healthbar = HealthBar(player: myplayer,position: Vector2(canvasSize.x/2,0));
    add(healthbar);
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:robo_combat/player.dart';

class HealthBar extends PositionComponent with HasGameRef{
  final double maxWidth = 100.0; // Adjust this based on your design
  final double barHeight = 10.0; // Adjust this based on your design

  HealthBar({required this.player,position}):super(position: position);

  final Player player;
  double W= 103;
  double H= 20;
  double w= 100;
  double h= 17;

  Color barColor = Color.fromRGBO(32, 250, 2, 0.7019607843137254);

  @override
  // TODO: implement priority
  int get priority => 3;

  @override
  FutureOr<void> onLoad() {
    position.x += -W/2;
    position.y += 5;

    return super.onLoad();
  }
  @override
  void render(Canvas canvas) {

    canvas.drawDRRect(RRect.fromLTRBR(0, 0, W, H,Radius.circular(6)), RRect.fromLTRBR(3, 3, W-3, H-3,Radius.circular(3)), (BasicPalette.white.paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(56, 56, 56, 0.7137254901960784)
    ),);
    canvas.drawRRect(RRect.fromLTRBR(3, 3, w, h, Radius.circular(3)), (BasicPalette.green.paint()
      ..style = PaintingStyle.fill
      ..color = barColor));


    super.render(canvas);
  }


  @override
  void update(double dt) {

    w = player.health;
    if(player.health < 40)
      barColor = Color.fromRGBO(250, 2, 2, 0.7019607843137254);

    super.update(dt);
  }

}
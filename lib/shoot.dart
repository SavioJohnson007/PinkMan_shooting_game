import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:robo_combat/player.dart';

class Fireshot extends PositionComponent with CollisionCallbacks{

  Fireshot({ position, required this.dir }) : super( position: position,size: Vector2(30,10));

  int dir;
  int bulletSpeed = 1300;


  @override
  FutureOr<void> onLoad() {

    if(dir==-1)
      position.x = position.x -size.x;

    RectangleHitbox hitbox = RectangleHitbox(size: size);
    RectangleComponent component = RectangleComponent(size: size,paint: BasicPalette.white.paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black);
    print(hitbox.size);
    add(hitbox);
    add(component);

    return super.onLoad();
  }
  @override
  void update(double dt) {
    position.x += dir*bulletSpeed*dt;
    super.update(dt);
  }
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    parent?.remove(this);
    super.onCollision(intersectionPoints, other);
  }

}
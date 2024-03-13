import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:robo_combat/robo_combat.dart';

class CollisionBlock extends PositionComponent with HasGameRef<RoboCombat>,CollisionCallbacks{
  CollisionBlock({position, size,this.is_water=false,required this.obj}) : super(position: position,size: size,);
  bool is_water ;
  TiledObject obj;
  List<Vector2> vertices = [];
  List<Vector2> vertices_ = [];


  @override
  FutureOr<void> onLoad() {
    if(obj.isPolygon){
      for(int i = 0; i < obj.polygon.length ; i++){
        vertices.add(Vector2(obj.polygon[i].x, obj.polygon[i].y ));
      }
      vertices.reverse();
      PolygonHitbox hitbox = PolygonHitbox(vertices);
      add(hitbox);
      vertices_ = vertices.map((Vector2 vertices) => vertices + position).toList();
    }
    if(obj.isRectangle){
      RectangleHitbox hitbox = RectangleHitbox();
      add(hitbox);
    }
  }

}
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:robo_combat/collision_blocks.dart';
import 'package:robo_combat/main.dart';
import 'package:robo_combat/player.dart';
import 'package:robo_combat/robo_combat.dart';
import 'package:robo_combat/server/server.dart';


List<Player> alive_players = [];
List<Player> all_players = [];
class GameWorld extends World with HasGameRef<RoboCombat>,TapCallbacks,HasCollisionDetection {


  var spawnpoint;
  bool spawn = false;
  var touchpoint;
  List<CollisionBlock> collision_blocks = [];




  Player player1 = Player(playerID: 1);

  Player player2 = Player(playerID: 2);

  Player player3 = Player(playerID: 3);

  Player player4 = Player(playerID: 4);


  late TiledComponent map;
  int num_spawnpoints = 1;
  List<Vector2> player_spawnpoints = [];


  @override
  FutureOr<void> onLoad() async {

    all_players = [player1,player2,player3,player4];

    map = await TiledComponent.load('greenyard.tmx', Vector2.all(16),);
    add(map);

    Database().listenToData([player1,player2,player3,player4]);

    final collisions = map.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisions != null) {
      for (final collision in collisions.objects) {
        switch (collision.class_) {
          case 'platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                obj: collision);
            collision_blocks.add(platform);
            add(platform);
            break;
          case 'water':
            final water = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                is_water: true,
                obj: collision);
            collision_blocks.add(water);
            add(water);
            break;
          case 'wall':
            final wall = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                obj: collision);
            collision_blocks.add(wall);
            add(wall);
          default:
        }
      }
    }

    final spawnpoints = map.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for(final spawnpoint in spawnpoints!.objects){
      switch (spawnpoint.class_){
        case 'player':
          num_spawnpoints += 1;
          player_spawnpoints.add(Vector2(spawnpoint.x, spawnpoint.y));
          break;
        default:
      }
    }

    player1.position = player_spawnpoints[0];
    player1.collisionBlocks = collision_blocks;
    add(player1);
    alive_players.add(player1);

    player2.position = player_spawnpoints[1];
    player2.collisionBlocks = collision_blocks;
    add(player2);
    alive_players.add(player2);


    player3.position = player_spawnpoints[2];
    player3.collisionBlocks = collision_blocks;
    add(player3);
    alive_players.add(player3);


    player4.position = player_spawnpoints[3];
    player4.collisionBlocks = collision_blocks;
    add(player4);
    alive_players.add(player4);




    return super.onLoad();
  }
  @override
  void update(double dt) {

  Database().updateData(1, 'position', [player1.position.x,player1.position.y]);
  Database().updateData(2, 'position', [player2.position.x,player2.position.y]);
  Database().updateData(3, 'position', [player3.position.x,player3.position.y]);
  Database().updateData(4, 'position', [player4.position.x,player4.position.y]);

    super.update(dt);
  }


}
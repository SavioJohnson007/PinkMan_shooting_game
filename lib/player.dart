import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:robo_combat/collision.dart';
import 'package:robo_combat/collision_blocks.dart';
import 'package:robo_combat/main.dart';
import 'package:robo_combat/maps.dart';
import 'package:robo_combat/robo_combat.dart';
import 'package:robo_combat/server/server.dart';
import 'package:robo_combat/shoot.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
}

enum PlayerMovement { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with
        HasWorldReference<GameWorld>,
        HasGameRef<RoboCombat>,
        CollisionCallbacks {
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 400;
  int horizontalMovement = 0;
  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool fire = false;
  double health = 100;

  int playerID;
  String playername = '';
  TextComponent name = TextComponent();


  List<CollisionBlock> collisionBlocks = [];

  PlayerMovement movement = PlayerMovement.none;

  RectangleHitbox hitbox = RectangleHitbox();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  Player({position, required this.playerID,})
      : super(
          position: position,
        );

  @override
  FutureOr<void> onLoad() async{
    dynamic s = await Server().fetchData(playerID, 'name');
    playername = s is String? s : 'layer';

    _loadAllAnimations();
    hitbox.size = size - Vector2(10, 10);
    add(hitbox);
    name = TextComponent(
        text: playername,
        textRenderer: TextPaint(
            style: TextStyle(
          color: Color.fromRGBO(1, 0, 0, 0.5),
          fontWeight: FontWeight.bold,
          fontSize: 30,
        )),
      anchor: Anchor.center,
      position: Vector2(65,-10)
    );
    add(name);
    return super.onLoad();
  }

  void _fire() {
    Vector2 bulletpos;
    int shootDir;

    if (isFlippedHorizontally) {
      shootDir = -1;
      bulletpos = position + Vector2(-width - 10, 48);
    } else {
      shootDir = 1;
      bulletpos = position + Vector2(width + 10, 48);
    }
    Fireshot fireshot = Fireshot(dir: shootDir, position: bulletpos);
    parent?.add(fireshot);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    if (fire) {
      _fire();
      fire = false;
      Database().updateData(playerID, 'fire', false);
    }


    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }


      accumulatedTime -= fixedDeltaTime;
    }
    if (health <= 0) {
      parent?.remove(this);
      alive_players.remove(this);
    }


      super.update(dt);

  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('players/Pink Man/$state (128).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(128),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
      name.flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
      name.flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // check if Falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Checks if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped) _playerJump(dt);

    // if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
    Database().updateData(playerID, 'jump', false);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.is_water) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.x;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block)) {
        if (block.is_water) {
          parent?.remove(this);
        }
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.y;
          isOnGround = true;
          break;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitbox.y;
        }
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fireshot) {
      health += -10;
    }
    super.onCollision(intersectionPoints, other);
  }
}

import 'package:flutter/material.dart';
import 'package:kemo/control/Painter.dart';
import 'dart:math' as math;

class Vector2 {
  double x, y;
  Vector2(this.x, this.y);

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);

  static Vector2 zero() => Vector2(0, 0);
}

class Player {
  Vector2 position;
  Vector2 velocity = Vector2(0, 0);
  final Vector2 size;
  static const double gravity = 0.8;
  static const double jumpForce = -20.0;
  static const double moveSpeed = 5.0;

  Player({
    required this.position,
    required this.size,
  });

  void update(double moveDirection) {
    velocity.y += gravity;
    velocity.x = moveDirection * moveSpeed;
    position = position + velocity;
  }

  void jump() {
    velocity.y = jumpForce;
  }

  bool collidesWith(GameObject other) {
    return position.x < other.position.x + other.size.x &&
        position.x + size.x > other.position.x &&
        position.y < other.position.y + other.size.y &&
        position.y + size.y > other.position.y;
  }

  Widget build(double animation, double gameWidth, double gameHeight,
      double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: CustomPaint(
        size: Size(size.x / 800 * gameWidth, size.y / 600 * gameHeight),
        painter: PlayerPainter(animation),
      ),
    );
  }
}

class GameObject {
  Vector2 position;
  final Vector2 size;

  GameObject({
    required this.position,
    required this.size,
  });

  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Container(
        width: size.x / 800 * gameWidth,
        height: size.y / 600 * gameHeight,
        color: Colors.white,
      ),
    );
  }
}

class Platform extends GameObject {
  bool isMoving;
  double movementRange;
  double movementSpeed;
  double initialY;
  double time = 0;

  Platform({
    required Vector2 position,
    required Vector2 size,
    this.isMoving = false,
    this.movementRange = 0,
    this.movementSpeed = 0,
  })  : initialY = position.y,
        super(position: position, size: size);

  void update() {
    if (isMoving) {
      time += 0.016; // Assuming 60 FPS
      position.y = initialY + math.sin(time * movementSpeed) * movementRange;
    }
  }

  @override
  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Container(
        width: size.x / 800 * gameWidth,
        height: size.y / 600 * gameHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

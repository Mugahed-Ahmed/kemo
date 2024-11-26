import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:kemo/secrean/dashboard.dart';
import 'package:kemo/secrean/registration/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelDevilApp());
}

class LevelDevilApp extends StatelessWidget {
  const LevelDevilApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Level Devil',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'PixelFont',
      ),
      home: const LoginScreen(),
    );
  }
}

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B4E),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SafeArea(
            child: Stack(
              children: [
                CustomPaint(
                  painter: BackgroundPainter(),
                  size: Size.infinite,
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'LEVEL DEVIL',
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      orientation == Orientation.portrait
                                          ? 2
                                          : 4,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: 7,
                                itemBuilder: (context, levelIndex) {
                                  return LevelCard(
                                    levelNumber: levelIndex + 1,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GameScreen(
                                          level: levelIndex + 1,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: orientation == Orientation.portrait
                                ? double.infinity
                                : 200,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Dashboard(
                                      players: [
                                        PlayerStats(
                                            name: 'Player 1',
                                            level: 2,
                                            stage: 3,
                                            isActive: true),
                                        PlayerStats(
                                            name: 'Player 2',
                                            level: 1,
                                            stage: 5,
                                            isActive: false),
                                        PlayerStats(
                                            name: 'Player 3',
                                            level: 3,
                                            stage: 1,
                                            isActive: true),
                                      ],
                                      totalPlayers: 100,
                                      totalAttempts: 500,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'View Dashboard',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: orientation == Orientation.portrait
                                ? double.infinity
                                : 200,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final VoidCallback onTap;

  const LevelCard({
    Key? key,
    required this.levelNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: Text(
            'Level $levelNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({
    Key? key,
    required this.level,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Player player;
  late List<Platform> platforms;
  late List<Obstacle> obstacles;
  late ExitGate exitGate;
  late AnimationController playerAnimationController;
  late Timer gameLoop;
  bool isJumping = false;
  bool isDead = false;
  double moveDirection = 0;
  double cameraOffset = 0;
  double levelWidth = 15000; // Increased level width for more challenge

  late AudioPlayer backgroundMusicPlayer;
  late AudioPlayer jumpSoundPlayer;
  late AudioPlayer victorySoundPlayer;

  @override
  void initState() {
    super.initState();
    initializeGame();
    startGameLoop();
    initializeAudio();
  }

  void initializeAudio() {
    backgroundMusicPlayer = AudioPlayer();
    jumpSoundPlayer = AudioPlayer();
    victorySoundPlayer = AudioPlayer();

    backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    backgroundMusicPlayer.play(AssetSource('background_music.mp3'));
  }

  void initializeGame() {
    platforms = [];
    obstacles = [];

    generateLevel();

    player = Player(
      position: Vector2(platforms[0].position.x, platforms[0].position.y - 60),
      size: Vector2(40, 60),
    );

    playerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  void generateLevel() {
    final random = math.Random();
    final platformCount = 50 + widget.level * 5;
    double lastPlatformX = 0;

    for (int i = 0; i < platformCount; i++) {
      final platformWidth = 100.0 + random.nextDouble() * 100;
      final platformGap =
          150.0 + random.nextDouble() * (50 + widget.level * 10);
      final isMoving = random.nextDouble() < widget.level * 0.05;

      platforms.add(
        Platform(
          position: Vector2(
            lastPlatformX + platformGap,
            300 + random.nextDouble() * 200,
          ),
          size: Vector2(platformWidth, 20),
          isMoving: isMoving,
          movementRange: isMoving ? 100 + random.nextDouble() * 100 : 0,
          movementSpeed: isMoving ? 1 + random.nextDouble() * 2 : 0,
        ),
      );

      lastPlatformX += platformWidth + platformGap;

      if (widget.level > 1 && random.nextDouble() < 0.3) {
        obstacles.add(
          Obstacle(
            position: Vector2(
              lastPlatformX - platformWidth / 2,
              200 + random.nextDouble() * 200,
            ),
            size: Vector2(30, 30),
            type: random.nextBool() ? ObstacleType.spike : ObstacleType.saw,
          ),
        );
      }
    }

    exitGate = ExitGate(
      position: Vector2(lastPlatformX, 200),
      size: Vector2(80, 120),
    );
  }

  void startGameLoop() {
    const fps = 60;
    gameLoop = Timer.periodic(
      Duration(milliseconds: (1000 / fps).round()),
      (timer) {
        if (!isDead) {
          updateGame();
        }
      },
    );
  }

  void updateGame() {
    setState(() {
      player.update(moveDirection);

      if (player.position.x > cameraOffset + 400) {
        cameraOffset = player.position.x - 400;
      }

      bool isOnPlatform = false;
      for (final platform in platforms) {
        platform.update();
        if (player.collidesWith(platform)) {
          player.velocity.y = 0;
          player.position.y = platform.position.y - player.size.y;
          isOnPlatform = true;
          isJumping = false;
        }
      }

      if (!isOnPlatform) {
        isJumping = true;
      }

      for (final obstacle in obstacles) {
        if (player.collidesWith(obstacle)) {
          handleDeath();
        }
        if (obstacle.type == ObstacleType.saw) {
          obstacle.update();
        }
      }

      if (player.collidesWith(exitGate)) {
        handleVictory();
      }

      if (player.position.y > 800) {
        handleDeath();
      }
    });
  }

  void handleDeath() {
    setState(() {
      isDead = true;
      gameLoop.cancel();
      backgroundMusicPlayer.stop();
      showDeathDialog();
    });
  }

  void handleVictory() {
    gameLoop.cancel();
    backgroundMusicPlayer.stop();
    victorySoundPlayer.play(AssetSource('victory_sound.mp3'));
    showVictoryDialog();
  }

  void showDeathDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Game Over',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Try again?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Quit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    restartGame();
                  },
                  child: const Text('Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Victory!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You completed Level ${widget.level}!',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Level Selection'),
            ),
          ],
        ),
      ),
    );
  }

  void restartGame() {
    setState(() {
      isDead = false;
      initializeGame();
      startGameLoop();
      backgroundMusicPlayer.play(AssetSource('background_music.mp3'));
    });
  }

  void handleJump() {
    if (!isJumping && !isDead) {
      setState(() {
        player.jump();
        isJumping = true;
        jumpSoundPlayer.play(AssetSource('jump_sound.mp3'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getLevelColor(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Please rotate your device to landscape mode to play the game.',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final gameHeight = constraints.maxHeight;
              final gameWidth = constraints.maxWidth;

              return Stack(
                children: [
                  Container(
                    width: gameWidth,
                    height: gameHeight,
                    child: CustomPaint(
                      painter: BackgroundPainter(),
                      child: Stack(
                        children: [
                          ...platforms.map((platform) => platform.build(
                              gameWidth, gameHeight, cameraOffset)),
                          ...obstacles.map((obstacle) => obstacle.build(
                              gameWidth, gameHeight, cameraOffset)),
                          exitGate.build(gameWidth, gameHeight, cameraOffset),
                          AnimatedBuilder(
                            animation: playerAnimationController,
                            builder: (context, child) {
                              return player.build(
                                  playerAnimationController.value,
                                  gameWidth,
                                  gameHeight,
                                  cameraOffset);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Text(
                      'Level ${widget.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        ControlButton(
                          icon: Icons.arrow_back,
                          onPressed: () => moveDirection = -1,
                          onReleased: () => moveDirection = 0,
                        ),
                        const SizedBox(width: 10),
                        ControlButton(
                          icon: Icons.arrow_forward,
                          onPressed: () => moveDirection = 1,
                          onReleased: () => moveDirection = 0,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ControlButton(
                      icon: Icons.arrow_upward,
                      onPressed: handleJump,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    playerAnimationController.dispose();
    gameLoop.cancel();
    backgroundMusicPlayer.dispose();
    jumpSoundPlayer.dispose();
    victorySoundPlayer.dispose();
    super.dispose();
  }

  Color getLevelColor() {
    switch (widget.level) {
      case 1:
        return const Color(0xFFD2691E);
      case 2:
        return const Color(0xFF556B2F);
      case 3:
        return const Color(0xFF4B0082);
      case 4:
        return const Color(0xFF800000);
      case 5:
        return const Color(0xFF2F4F4F);
      case 6:
        return const Color(0xFF8B4513);
      case 7:
        return const Color(0xFF4A148C);
      default:
        return Colors.black;
    }
  }
}

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

enum ObstacleType { spike, saw }

class Obstacle extends GameObject {
  final ObstacleType type;
  double angle = 0;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.type,
  }) : super(position: position, size: size);

  void update() {
    if (type == ObstacleType.saw) {
      angle += 0.1;
      position.y += math.sin(angle) * 2;
    }
  }

  @override
  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Transform.rotate(
        angle: type == ObstacleType.saw ? angle : 0,
        child: CustomPaint(
          size: Size(size.x / 800 * gameWidth, size.y / 600 * gameHeight),
          painter: ObstaclePainter(type),
        ),
      ),
    );
  }
}

class ExitGate extends GameObject {
  ExitGate({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Container(
        width: size.x / 800 * gameWidth,
        height: size.y / 600 * gameHeight,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.exit_to_app,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }
}

class PlayerPainter extends CustomPainter {
  final double animation;

  PlayerPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.2 + math.sin(animation * 2 * math.pi) * 2,
        size.width * 0.6,
        size.height * 0.6,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        size.height * 0.2 + math.sin(animation * 2 * math.pi) * 2,
      ),
      size.width * 0.15,
      paint,
    );

    final limbOffset = math.sin(animation * 2 * math.pi) * 5;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.3 + limbOffset,
        size.width * 0.2,
        size.height * 0.1,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.3 - limbOffset,
        size.width * 0.2,
        size.height * 0.1,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.8 + limbOffset,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.55,
        size.height * 0.8 - limbOffset,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ObstaclePainter extends CustomPainter {
  final ObstacleType type;

  ObstaclePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = type == ObstacleType.spike ? Colors.red : Colors.purple
      ..style = PaintingStyle.fill;

    if (type == ObstacleType.spike) {
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        paint,
      );

      final teethPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        canvas.drawLine(
          Offset(
            size.width / 2 + math.cos(angle) * size.width / 3,
            size.height / 2 + math.sin(angle) * size.height / 3,
          ),
          Offset(
            size.width / 2 + math.cos(angle) * size.width / 2,
            size.height / 2 + math.sin(angle) * size.height / 2,
          ),
          teethPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (var i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onReleased;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.onReleased,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

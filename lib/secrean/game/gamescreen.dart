import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kemo/control/Painter.dart';
import 'package:kemo/control/gameibjects.dart';

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
        cameraOffset = 0 - 400;
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
      isDead = true;
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

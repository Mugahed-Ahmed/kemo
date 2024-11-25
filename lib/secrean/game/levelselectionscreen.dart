import 'package:flutter/material.dart';
import 'package:kemo/control/Painter.dart';
import 'package:kemo/secrean/dashboard.dart';
import 'package:kemo/secrean/game/gamescreen.dart';
import 'package:kemo/secrean/registration/login_screen.dart';

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

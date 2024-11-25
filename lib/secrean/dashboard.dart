import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final List<PlayerStats> players;
  final int totalPlayers;
  final int totalAttempts;

  const Dashboard({
    Key? key,
    required this.players,
    required this.totalPlayers,
    required this.totalAttempts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Devil Dashboard'),
        backgroundColor: const Color(0xFF2D1B4E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B4E), Color(0xFF1A1A2E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Active Players',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          player.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Level: ${player.level} - Stage: ${player.stage}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(
                          Icons.star,
                          color: player.isActive ? Colors.yellow : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'General Statistics',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total Players', totalPlayers.toString()),
                  _buildStatCard('Total Attempts', totalAttempts.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerStats {
  final String name;
  final int level;
  final int stage;
  final bool isActive;

  PlayerStats({
    required this.name,
    required this.level,
    required this.stage,
    required this.isActive,
  });
}

import 'package:flutter/material.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _border = Color(0xFF2B3C42);
const _textTitle = Color(0xFFD7DADC);
const _textSub = Color(0xFF8B9DA4);

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Wellbeing Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: _textTitle,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'Understand your energy, track your mood, and take things one step at a time.',
              style: TextStyle(color: _textSub, fontSize: 15),
            ),
            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return SizedBox(
                    height: 600,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _buildAIChat()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _buildHealthAnalytics()),
                        const SizedBox(width: 24),
                        Expanded(flex: 4, child: _buildRoadmapCard()),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      _buildHealthAnalytics(),
                      const SizedBox(height: 24),
                      SizedBox(height: 500, child: _buildAIChat()),
                      const SizedBox(height: 24),
                      _buildRoadmapCard(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIChat() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 12),
                Text(
                  "Your AI Companion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textTitle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _chatBubble(
                    "Hi! I noticed your recent posts in #AcademicBurnout. It seems like you've been running on low energy this week. Do you want to vent about it, or look at some study tools?",
                    isUser: false,
                  ),
                  const SizedBox(height: 12),
                  _chatBubble(
                    "I'm just so overwhelmed with my assignments right now.",
                    isUser: true,
                  ),
                  const SizedBox(height: 12),
                  _chatBubble(
                    "That is completely valid. It's a huge workload. Should we break it down into 3 smaller tasks for today, or do you need a completely screen-free break first?",
                    isUser: false,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Type a response...",
                      hintStyle: const TextStyle(color: _textSub),
                      suffixIcon: const Icon(Icons.send, color: _accent),
                      filled: true,
                      fillColor: _bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? _accent.withOpacity(0.2) : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUser ? _accent.withOpacity(0.5) : _border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : _textTitle,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CARD 1: MENTAL BATTERY
        Expanded(
          flex: 4,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.battery_3_bar_rounded,
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Mental Battery",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.35,
                    color: Colors.orangeAccent,
                    backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Critically Low (35%). It might be a good idea to avoid heavy tasks today.",
                    style: TextStyle(fontSize: 13, color: _textSub),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // CARD 2: SLEEP TRACKER
        // FIX: removed "synced Apple Health data" — we don't have that
        // feature and our platform is fully anonymous. Using in-app
        // activity timestamps only, which we do actually track.
        Expanded(
          flex: 4,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bedtime, color: Colors.purpleAccent),
                      SizedBox(width: 8),
                      Text(
                        "Sleep Pattern Alert",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    // FIX: no Apple Health mention — uses only anonymous
                    // in-app activity (timestamp of posts/scrolling sessions)
                    "We noticed high app activity between 2 AM and 5 AM over the last 3 nights. Disrupted sleep can directly affect your mood and energy levels.",
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSub,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        // FIX: honest, anonymous-safe source description
                        "Based on anonymous in-app usage timestamps only.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // CARD 3: MOOD TREND
        Expanded(
          flex: 5,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How you've been feeling",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textTitle,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar("M", 0.6, Colors.green),
                      _bar("T", 0.8, Colors.green),
                      _bar("W", 0.4, Colors.orange),
                      _bar("T", 0.3, Colors.redAccent),
                      _bar("F", 0.2, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(String day, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 60 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: _textSub, fontSize: 12)),
      ],
    );
  }

  Widget _buildRoadmapCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: const Row(
              children: [
                Icon(Icons.route, color: Colors.tealAccent),
                SizedBox(width: 12),
                Text(
                  "Your Step-by-Step Guide",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textTitle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Goal: Get through finals without burning out.",
                    style: TextStyle(
                      color: _textTitle,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "We adjusted your timeline to give you room to breathe.",
                    style: TextStyle(fontSize: 13, color: Colors.orangeAccent),
                  ),
                  const Divider(height: 40, color: _border),
                  _step(
                    Icons.check_circle_rounded,
                    Colors.greenAccent,
                    "1. Submit Draft Proposal",
                    "Completed on Tuesday. You did it!",
                  ),
                  _step(
                    Icons.pause_circle_filled,
                    Colors.orangeAccent,
                    "2. Rest Day (Scheduled)",
                    "Take a walk, watch a movie. No studying allowed today.",
                  ),
                  _step(
                    Icons.radio_button_unchecked,
                    _textSub,
                    "3. Apply to 3 Local Internships",
                    "Pushed to tomorrow so you can recover your energy first.",
                  ),
                  _step(
                    Icons.radio_button_unchecked,
                    _textSub,
                    "4. Update Resume",
                    "Pending.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: icon == Icons.check_circle_rounded
                        ? _textSub
                        : _textTitle,
                    decoration: icon == Icons.check_circle_rounded
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: _textSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

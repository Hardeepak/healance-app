import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:frontend/services/ai_service.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _border = Color(0xFF2B3C42);
const _textTitle = Color(0xFFD7DADC);
const _textSub = Color(0xFF8B9DA4);

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local state for the UI bubbles
  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Hi! I'm Héalance, your AI sidekick. I noticed you've been exploring the community lately. How are you feeling today?",
      "isUser": false,
    },
  ];

  // Persistent history for the Gemini SDK context
  final List<Content> _chatHistory = [];
  bool _isTyping = false;

  // 1. ADDED: Interactive State for the Step-by-Step Guide
  final List<Map<String, dynamic>> _roadmapSteps = [
    {
      "title": "1. Submit Draft Proposal",
      "subtitle": "Completed on Tuesday. You did it!",
      "isCompleted": true,
      "isRestDay": false,
    },
    {
      "title": "2. Rest Day (Scheduled)",
      "subtitle": "Take a walk, watch a movie. No studying allowed today.",
      "isCompleted": false,
      "isRestDay": true,
    },
    {
      "title": "3. Apply to 3 Local Internships",
      "subtitle": "Pushed to tomorrow so you can recover your energy first.",
      "isCompleted": false,
      "isRestDay": false,
    },
    {
      "title": "4. Update Resume",
      "subtitle": "Pending.",
      "isCompleted": false,
      "isRestDay": false,
    },
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    setState(() {
      _messages.add({"text": text, "isUser": true});
      _isTyping = true;
    });
    _scrollToBottom();

    // Get response from our hardened AI Service
    // Pass the user's emotional history (last 3 posts) for deep context!
    final response = await HelanceAIService.getChatbotResponse(
      text,
      history: _chatHistory,
      recentUserPosts: UserActivityTracker.lastThreePosts,
    );

    // Update local UI state
    setState(() {
      _messages.add({"text": response, "isUser": false});
      _isTyping = false;

      // Update persistent history for next turn context
      _chatHistory.add(Content.text(text));
      _chatHistory.add(Content.model([TextPart(response)]));
    });
    _scrollToBottom();
  }

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
                        Expanded(flex: 4, child: _buildAIChat()),
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
        side: const BorderSide(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                const Text(
                  "Héalance Sidekick",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textTitle,
                  ),
                ),
                const Spacer(),
                if (_isTyping)
                  const Text(
                    "typing...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _chatBubble(m['text'], isUser: m['isUser']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _msgController,
              onSubmitted: (_) => _handleSend(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Talk to Helance...",
                hintStyle: const TextStyle(color: _textSub),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: _accent),
                  onPressed: _handleSend,
                ),
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
              side: const BorderSide(color: _border),
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
        Expanded(
          flex: 4,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _border),
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
              side: const BorderSide(color: _border),
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
        side: const BorderSide(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(bottom: BorderSide(color: _border)),
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

                  // 2. UPDATED: Generates the list dynamically and passes the index
                  // FIX: Removed Expanded and added shrinkWrap/NeverScrollableScrollPhysics 
                  // to prevent infinite height crashes on mobile screens.
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _roadmapSteps.length,
                    itemBuilder: (context, index) {
                      return _step(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. UPDATED: Made the step widget interactive and linked to state
  Widget _step(int index) {
    final step = _roadmapSteps[index];
    final bool isCompleted = step['isCompleted'];
    final bool isRestDay = step['isRestDay'];

    IconData icon;
    Color color;

    // Determine visual style based on current state
    if (isCompleted) {
      icon = Icons.check_circle_rounded;
      color = Colors.greenAccent;
    } else if (isRestDay) {
      icon = Icons.pause_circle_filled;
      color = Colors.orangeAccent;
    } else {
      icon = Icons.radio_button_unchecked;
      color = _textSub;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _roadmapSteps[index]['isCompleted'] = !isCompleted;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Icon(icon, color: color, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _roadmapSteps[index]['isCompleted'] = !isCompleted;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        // Greys out the text and adds strikethrough if checked
                        color: isCompleted ? _textSub : _textTitle,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['subtitle'],
                      style: TextStyle(fontSize: 13, color: _textSub),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

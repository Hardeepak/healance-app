import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

// --- GLOBAL ACTIVITY TRACKER ---
// Stores the last 3 posts made by the user in this session.
class UserActivityTracker {
  static final List<Map<String, String>> lastThreePosts = [];

  static void addPost(String text) {
    final now = DateTime.now();
    final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(now);
    
    lastThreePosts.insert(0, {'text': text, 'time': timeStr});
    if (lastThreePosts.length > 3) {
      lastThreePosts.removeLast();
    }
    print("🧠 Activity Saved: $timeStr | Count: ${lastThreePosts.length}");
  }
}

class HelanceAIService {
  // 1. GRAB THE HIDDEN VAULT KEY
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // ── FUNCTION 1: THE SAFETY INTERCEPTOR ──
  // Checks if a feed post contains severe self-harm language.
  static Future<bool> isPostSafe(String text) async {
    final result = await analyzePost(text);
    return result['isSafe'] as bool;
  }

  // ── FUNCTION 3: THE ANALYZER (SAFETY + CATEGORY) ──
  // Determines if a post is safe AND what category it belongs to.
  static Future<Map<String, dynamic>> analyzePost(String text) async {
    if (_apiKey.isEmpty) {
      return {'isSafe': true, 'category': 'General'};
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);

    final prompt = '''
    SYSTEM: You are an AI moderator and classifier for a university mental health forum.
    TASK: Analyze the USER_TEXT and return a JSON object.
    
    CATEGORIES: [Academic Burnout, Loneliness, Overthinking, Bullying, Friendship Drama, Financial Anxiety, Career Anxiety, Dark Thoughts, Body Insecurity, Family Issues, Social Media Trap, Future Doubts, Trauma, Phone Addiction, Procrastination, Feeling Unattractive, No One To Talk To, Identity & Self-Worth, Sleep Struggles, Relationships]

    RULES:
    1. Determine if the text indicates immediate, severe risk of self-harm or violence (isSafe: true/false).
    2. Select the most relevant category from the list above.
    3. Return ONLY the JSON object.

    Example Safe: {"isSafe": true, "category": "Academic Burnout"}
    Example Unsafe: {"isSafe": false, "category": "Dark Thoughts"}

    USER_TEXT: "$text"
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final cleanJson = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '';
      
      // Basic manual parsing to avoid heavy dependencies in a hackathon
      final bool isSafe = !cleanJson.contains('"isSafe": false');
      String category = 'General';
      
      final catMatch = RegExp(r'"category":\s*"([^"]+)"').firstMatch(cleanJson);
      if (catMatch != null) {
        category = catMatch.group(1) ?? 'General';
      }

      return {'isSafe': isSafe, 'category': category};
    } catch (e) {
      print('🚨 AI Analysis Error: $e');
      return {'isSafe': true, 'category': 'General'};
    }
  }

  // ── FUNCTION 2: THE CHATBOT ──
  // Generates warm, empathetic replies for the tools_screen.dart Chat UI.
  // Now supports conversation history AND the user's emotional history (last 3 posts).
  static Future<String> getChatbotResponse(
    String userMessage, {
    List<Content>? history,
    List<Map<String, String>>? recentUserPosts,
  }) async {
    if (_apiKey.isEmpty) return "Error: AI vault key is missing.";

    // Format the emotional context for the AI
    String activityContext = "";
    if (recentUserPosts != null && recentUserPosts.isNotEmpty) {
      activityContext = "\n\nUSER'S EMOTIONAL HISTORY (Last 3 Posts):\n";
      for (var post in recentUserPosts) {
        activityContext += "- [${post['time']}]: \"${post['text']}\"\n";
      }
      activityContext += "\nINSTRUCTION: Use this history to provide more personal help. If you notice a pattern (e.g. posting late at night or recurring themes), mention it supportively.";
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are Helance, an empathetic mental health AI sidekick for university students. '
        'YOUR PERSONALITY: Warm, validating, and observant. '
        'YOUR BOUNDARIES: You are NOT a doctor. You CANNOT diagnose or prescribe. '
        'KEEP RESPONSES UNDER 3 SENTENCES. Always prioritize validating feelings over giving advice.'
        '$activityContext'
      ),
    );

    try {
      // Start a chat session with the provided history
      final chat = model.startChat(history: history ?? []);
      final response = await chat.sendMessage(Content.text(userMessage));
      
      return response.text ??
          "I'm here for you, but my words are getting a bit tangled. Let's try that again.";
    } catch (e) {
      print('🚨 AI Chat Error: $e');
      return "I'm having a little trouble connecting right now, but I'm still here in spirit. Take a deep breath with me.";
    }
  }
}

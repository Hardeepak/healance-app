import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  // Now supports conversation history for context!
  static Future<String> getChatbotResponse(String userMessage, {List<Content>? history}) async {
    if (_apiKey.isEmpty) return "Error: AI vault key is missing.";

    // ROLE 3: Refined persona with strict medical boundaries and conversational empathy.
    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite', // Using 2.5-flash-lite for validated persona performance
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are Helance, an empathetic mental health AI sidekick for university students. '
        'YOUR PERSONALITY: Warm, validating, concise, and professional but approachable. '
        'YOUR BOUNDARIES: You are NOT a doctor. You CANNOT diagnose or prescribe. '
        'If a user is in acute crisis, you MUST provide help resources immediately. '
        'KEEP RESPONSES UNDER 3 SENTENCES. Always prioritize validating feelings over giving advice.'
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

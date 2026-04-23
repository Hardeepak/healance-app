import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HelanceAIService {
  // 1. GRAB THE HIDDEN VAULT KEY
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // ── FUNCTION 1: THE SAFETY INTERCEPTOR ──
  // Checks if a feed post contains severe self-harm language.
  static Future<bool> isPostSafe(String text) async {
    if (_apiKey.isEmpty) {
      print("🚨 GEMINI KEY MISSING!");
      return true; // Let post through if AI is broken
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);

    // ROLE 3: Refined prompt for high-precision safety detection.
    final prompt = '''
    SYSTEM: You are a high-precision safety classifier for a university mental health forum.
    TASK: Analyze the USER_TEXT below for immediate, severe risks of:
    1. Suicidal ideation or self-harm.
    2. Intent to perform violence against others.
    3. Severe clinical crisis requiring immediate intervention.

    CRITICAL INSTRUCTIONS:
    - Respond with ONLY the word "YES" if a risk is detected.
    - Respond with ONLY the word "NO" if the text is safe or contains general venting without self-harm intent.
    - Do not provide explanations. Do not use punctuation.
    - Example of "NO": "I failed my exam and I want to cry."
    - Example of "YES": "I don't want to be here anymore, I have a plan for tonight."

    USER_TEXT: "$text"
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final answer = response.text?.trim().toUpperCase() ?? 'NO';

      // If AI says YES (danger), return false (not safe). Otherwise true.
      // We check if it starts with YES or contains YES to be robust against "YES." or "YES\n"
      return !answer.startsWith('YES');
    } catch (e) {
      print('🚨 AI Safety Error: $e');
      return true;
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

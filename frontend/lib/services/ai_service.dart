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

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

    // ROLE 3: This is the prompt you can tweak!
    final prompt =
        '''
    Analyze the following text from an anonymous mental health forum. 
    Does this text indicate an immediate, severe risk of self-harm, suicide, or violence?
    Answer with ONLY "YES" or "NO".
    
    Text: "$text"
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final answer = response.text?.trim().toUpperCase() ?? 'NO';

      // If AI says YES (danger), return false (not safe). Otherwise true.
      return answer != 'YES';
    } catch (e) {
      print('🚨 AI Safety Error: $e');
      return true;
    }
  }

  // ── FUNCTION 2: THE CHATBOT ──
  // Generates warm, empathetic replies for the tools_screen.dart Chat UI.
  static Future<String> getChatbotResponse(String userMessage) async {
    if (_apiKey.isEmpty) return "Error: AI vault key is missing.";

    // ROLE 3: You can tweak the systemInstruction to change the bot's personality!
    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are Helance, an empathetic, supportive mental health AI sidekick. '
        'Keep responses brief, warm, and helpful. You are talking to a stressed university student. '
        'Do not give official medical diagnoses.',
      ),
    );

    try {
      final response = await model.generateContent([Content.text(userMessage)]);
      return response.text ??
          "I'm here for you, but I'm having trouble connecting right now.";
    } catch (e) {
      print('🚨 AI Chat Error: $e');
      return "Sorry, my circuits are a bit overwhelmed. Take a deep breath and try again in a moment!";
    }
  }
}

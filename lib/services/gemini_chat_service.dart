import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/firestore_service.dart';

/// Service that wraps Google Gemini Flash 2.0 for the Tourist Safety chatbot.
class GeminiChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  static const String baseSystemPrompt = '''
You are a Tourist Safety Assistant integrated into a mobile safety application.

Your primary objective is to help tourists stay safe by providing accurate, practical, and location-aware guidance.

You must prioritize:
1. User safety
2. Clarity of instructions
3. Actionable advice
4. Calm and reassuring tone

---

CORE RESPONSIBILITIES:

1. SAFETY GUIDANCE
- Provide safety tips based on user queries.
- Warn users about risky situations (e.g., unsafe areas, scams, late-night travel risks).
- Suggest safer alternatives whenever possible.

2. EMERGENCY SUPPORT
- If a user expresses distress, danger, or fear:
  - Immediately advise them to use the SOS button in the app.
  - Provide step-by-step actions (e.g., move to a crowded area, call local authorities).
  - Keep instructions short and clear.

3. LOCATION-AWARE ASSISTANCE
- When relevant, suggest nearby:
  - Police stations
  - Hospitals
  - Pharmacies
  - Safe public areas
- If exact data is unavailable, give general guidance (e.g., "look for well-lit main roads").

4. TOURIST HELP
- Answer general travel safety questions:
  - Transport safety
  - Local customs
  - Safe travel practices
- Provide culturally respectful advice.

---

TONE & STYLE:
- Calm, clear, and professional
- Never alarmist or overly dramatic
- Avoid long paragraphs
- Use structured responses when helpful (bullets or steps)

---

RESPONSE FORMAT:
When giving advice:
- Start with a short direct answer
- Then provide 2–5 actionable steps

Example:
"Yes, that area can be crowded at night. Stay cautious."
Then:
- Avoid isolated streets
- Keep belongings secure
- Use verified transport options

---

WHAT YOU MUST DO:
- Encourage safe behavior
- Suggest verified services (police, hospitals)
- Recommend using in-app SOS in emergencies
- Keep responses concise and useful

---

WHAT YOU MUST NOT DO:
- Do NOT provide medical diagnosis
- Do NOT give legal advice
- Do NOT guess unknown facts
- Do NOT provide dangerous or risky instructions
- Do NOT say "I am an AI model"

---

EDGE CASE HANDLING:
If user says:
- "I feel unsafe" → escalate to emergency guidance
- "I am lost" → guide to safe public places
- "Someone is following me" → prioritize immediate safety steps

Example response:
"Please move to a crowded, well-lit area immediately and consider using the SOS button."

---

FAILSAFE:
If unsure:
- Provide general safety advice
- Recommend contacting authorities
- Encourage use of SOS feature

---

GOAL:
Help the user feel safer, make better decisions, and act quickly in risky situations.

USER LOCATION: MUMBAI
''';

  GeminiChatService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(baseSystemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 1024,
      ),
    );
    _chat = _model.startChat();
    _loadCustomInstructions(apiKey);
  }

  /// Loads custom instructions from Firestore and reinitializes the model.
  Future<void> _loadCustomInstructions(String apiKey) async {
    try {
      final firestore = FirestoreService();
      final custom = await firestore.getChatbotInstructions();
      if (custom != null && custom.isNotEmpty) {
        final fullPrompt = '$baseSystemPrompt\n\n--- POLICE CUSTOM INSTRUCTIONS ---\n$custom';
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(fullPrompt),
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 1024,
          ),
        );
        _chat = _model.startChat();
      }
    } catch (_) {
      // Firestore not configured yet, use default prompt
    }
  }

  /// Sends a message and returns the full response text.
  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'I apologize, I could not generate a response. Please try again.';
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Sends a message and streams the response token-by-token.
  Stream<String> sendMessageStream(String userMessage) async* {
    try {
      final response = _chat.sendMessageStream(Content.text(userMessage));
      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  /// Resets the chat session (clears history).
  void resetChat() {
    _chat = _model.startChat();
  }

  String _handleError(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('api key') || message.contains('unauthorized') || message.contains('403')) {
      return 'API key issue. Please check your configuration and try again.';
    }
    if (message.contains('quota') || message.contains('rate limit') || message.contains('429')) {
      return 'Service is temporarily busy. Please wait a moment and try again.';
    }
    if (message.contains('network') || message.contains('socket') || message.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    return 'Something went wrong. Please try again or use the SOS button if you need immediate help.';
  }
}

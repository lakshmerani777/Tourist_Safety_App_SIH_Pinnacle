import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/gemini_chat_service.dart';

/// AI Safety Assistant overlay — powered by Gemini Flash 2.0.
class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final List<ChatBubble> _messages = [];
  final FocusNode _inputFocusNode = FocusNode();

  GeminiChatService? _geminiService;
  bool _isLoading = false;
  bool _isInitialised = false;
  String? _initError;

  // Typing indicator animation
  late AnimationController _dotAnimController;

  @override
  void initState() {
    super.initState();
    _dotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _initGemini();
  }

  Future<void> _initGemini() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        setState(() {
          _initError = 'Gemini API key not found. Please add GEMINI_API_KEY to your .env file.';
        });
        return;
      }
      _geminiService = GeminiChatService(apiKey: apiKey);
      setState(() => _isInitialised = true);
    } catch (e) {
      setState(() => _initError = 'Failed to initialise AI service: $e');
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _listScrollController.dispose();
    _inputFocusNode.dispose();
    _dotAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onAssistOptionTap(String text) {
    HapticFeedback.lightImpact();
    _sendToGemini(text);
  }

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;
    HapticFeedback.lightImpact();
    _inputController.clear();
    _sendToGemini(text);
  }

  Future<void> _sendToGemini(String userMessage) async {
    if (_geminiService == null) return;

    setState(() {
      _messages.add(ChatBubble(text: userMessage, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Add a placeholder bot message for streaming
    final botBubble = ChatBubble(text: '', isUser: false);
    setState(() => _messages.add(botBubble));
    _scrollToBottom();

    try {
      final stream = _geminiService!.sendMessageStream(userMessage);
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(chunk);
        setState(() {
          botBubble.text = buffer.toString();
        });
        _scrollToBottom();
      }

      // If we got an empty response, show a fallback
      if (buffer.isEmpty) {
        setState(() {
          botBubble.text =
              'I apologize, I could not generate a response. Please try again or use the SOS button if you need immediate help.';
        });
      }
    } catch (e) {
      setState(() {
        botBubble.text =
            'Something went wrong. Please try again or use the SOS button if you need immediate help.';
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _resetChat() {
    HapticFeedback.mediumImpact();
    _geminiService?.resetChat();
    setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_initError != null) _buildErrorBanner(),
            Expanded(
              child: CustomScrollView(
                controller: _listScrollController,
                slivers: [
                  if (_messages.isEmpty)
                    SliverToBoxAdapter(child: _buildAssistOptions()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final msg = _messages[index];
                          // Show typing indicator for last bot message while loading
                          final isStreamingBubble = _isLoading &&
                              !msg.isUser &&
                              index == _messages.length - 1 &&
                              msg.text.isEmpty;

                          if (isStreamingBubble) {
                            return _TypingIndicator(
                                animation: _dotAnimController);
                          }

                          return _MessageBubble(
                            text: msg.text,
                            isUser: msg.isUser,
                          );
                        },
                        childCount: _messages.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red.withValues(alpha: 0.15),
      child: Text(
        _initError!,
        style: AppTypography.caption.copyWith(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.accentBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety Assistant',
                    style: AppTypography.h2.copyWith(fontSize: 18)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isInitialised
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isInitialised
                          ? 'Powered by Gemini AI'
                          : 'Connecting...',
                      style: AppTypography.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: _resetChat,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.textSecondary, size: 22),
              tooltip: 'New chat',
            ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistOptions() {
    const sections = _AssistSections.all;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick assist',
              style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: section.options
                          .map((opt) => _AssistChip(
                                label: opt,
                                onTap: _isLoading
                                    ? null
                                    : () => _onAssistOptionTap(opt),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: 44, maxHeight: 120),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                style: AppTypography.body,
                maxLines: null,
                enabled: _isInitialised && !_isLoading,
                decoration: InputDecoration(
                  hintText: _isInitialised
                      ? 'Ask about safety, travel, emergencies...'
                      : 'Connecting to AI...',
                  hintStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppColors.accentBlue),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _isLoading
                ? AppColors.accentBlue.withValues(alpha: 0.4)
                : AppColors.accentBlue,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: _isLoading ? null : _onSend,
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _AssistChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _AssistChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.accentBlue.withValues(alpha: 0.25)
              : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: isUser
            ? Text(text, style: AppTypography.body.copyWith(fontSize: 14))
            : SelectableText(text,
                style: AppTypography.body.copyWith(fontSize: 14)),
      ),
    );
  }
}

/// Animated "typing…" dots shown while waiting for the first chunk.
class _TypingIndicator extends StatelessWidget {
  final AnimationController animation;

  const _TypingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.25;
                final t = ((animation.value - delay) % 1.0).clamp(0.0, 1.0);
                final scale = 0.6 + 0.4 * (1.0 - (2 * t - 1).abs());
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue
                            .withValues(alpha: 0.4 + 0.6 * scale),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class ChatBubble {
  String text;
  final bool isUser;
  ChatBubble({required this.text, required this.isUser});
}

class _AssistSections {
  _AssistSections._();

  static const List<({String title, List<String> options})> all = [
    (
      title: 'Emergency & SOS',
      options: [
        'Emergency help now',
        'Activate SOS',
        'Nearest hospital',
        'Nearest police station',
        'Share my location',
        'Local emergency numbers',
        'Contact embassy / consulate',
      ]
    ),
    (
      title: 'Safety & Incidents',
      options: [
        'Report an incident',
        'Is it safe to travel here?',
        'Safe routes to my destination',
        'Scam & fraud alerts',
        'Women safety tips',
        'LGBTQ+ friendly areas',
        'Recent safety alerts',
      ]
    ),
    (
      title: 'Travel & Navigation',
      options: [
        'Weather in my area',
        'Road conditions',
        'Public transport info',
        'Taxi / cab safety',
        'Lost and found',
        'Travel advisories',
        'Visa & immigration help',
      ]
    ),
    (
      title: 'Health & Medical',
      options: [
        'Medical assistance',
        'Nearest pharmacy',
        'Travel insurance help',
        'Vaccination requirements',
        'Accessibility information',
      ]
    ),
    (
      title: 'Local Info',
      options: [
        'Local customs & tips',
        'Currency exchange',
        'Safe dining areas',
        'Pet travel info',
        'Check-in with my contacts',
        'Language / translation help',
      ]
    ),
  ];
}

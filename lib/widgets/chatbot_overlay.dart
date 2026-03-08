import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// AI Safety Assistant overlay — opens as a full-screen modal.
/// Backend integration can be added later.
class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final List<ChatBubble> _messages = [];
  @override
  void dispose() {
    _inputController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onAssistOptionTap(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(ChatBubble(text: text, isUser: true));
      // Placeholder: backend will replace this with bot response
      _messages.add(ChatBubble(
        text: 'I’ll help you with that. (Backend coming soon.)',
        isUser: false,
      ));
    });
    _inputController.text = text;
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

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(ChatBubble(text: text, isUser: true));
      _messages.add(ChatBubble(
        text: 'Thanks for your message. AI responses will appear here once the backend is connected.',
        isUser: false,
      ));
    });
    _inputController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: CustomScrollView(
                controller: _listScrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildAssistOptions()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final msg = _messages[index];
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
            child: const Icon(Icons.smart_toy_rounded, color: AppColors.accentBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety Assistant', style: AppTypography.h2.copyWith(fontSize: 18)),
                Text('Ask anything about travel & safety', style: AppTypography.caption.copyWith(fontSize: 12)),
              ],
            ),
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
          Text('Quick assist', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                                onTap: () => _onAssistOptionTap(opt),
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
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              child: TextField(
                controller: _inputController,
                style: AppTypography.body,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Ask about safety, travel, emergencies...',
                  hintStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.accentBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: _onSend,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AssistChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accentBlue.withValues(alpha: 0.25) : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: AppTypography.body.copyWith(fontSize: 14),
        ),
      ),
    );
  }
}

class ChatBubble {
  final String text;
  final bool isUser;
  ChatBubble({required this.text, required this.isUser});
}

class _AssistSections {
  _AssistSections._();

  static const List<({String title, List<String> options})> all = [
    (title: 'Emergency & SOS', options: [
      'Emergency help now',
      'Activate SOS',
      'Nearest hospital',
      'Nearest police station',
      'Share my location',
      'Local emergency numbers',
      'Contact embassy / consulate',
    ]),
    (title: 'Safety & Incidents', options: [
      'Report an incident',
      'Is it safe to travel here?',
      'Safe routes to my destination',
      'Scam & fraud alerts',
      'Women safety tips',
      'LGBTQ+ friendly areas',
      'Recent safety alerts',
    ]),
    (title: 'Travel & Navigation', options: [
      'Weather in my area',
      'Road conditions',
      'Public transport info',
      'Taxi / cab safety',
      'Lost and found',
      'Travel advisories',
      'Visa & immigration help',
    ]),
    (title: 'Health & Medical', options: [
      'Medical assistance',
      'Nearest pharmacy',
      'Travel insurance help',
      'Vaccination requirements',
      'Accessibility information',
    ]),
    (title: 'Local Info', options: [
      'Local customs & tips',
      'Currency exchange',
      'Safe dining areas',
      'Pet travel info',
      'Check-in with my contacts',
      'Language / translation help',
    ]),
  ];
}

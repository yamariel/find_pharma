import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_provider.dart';
import '../widgets/chat_bubble.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _promptController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiChat = ref.watch(aiChatProvider);
    final colorScheme = Theme.of(context).colorScheme;
    ref.listen(aiChatProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Find Pharma AI")),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(Icons.privacy_tip, color: colorScheme.error),
                  title: const Text("Avertissement déontologique"),
                  titleTextStyle: TextStyle(color: colorScheme.error),
                  subtitle: const Text(
                    "Cet assistant fournit des informations générales et vous oriente vers les officines disponibles. "
                    "Il ne pose aucun diagnostic médical ni ne remplace une consultation d'urgence.",
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: aiChat.messages.length + (aiChat.isLoading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == aiChat.messages.length) {
                    return ChatBubble(
                      isUser: false,
                      text: "Find Pharma AI est en train de réfléchir...",
                      time: DateTime.now(),
                    );
                  }
                  final message = aiChat.messages[i];
                  return ChatBubble(
                    isUser: message.isUser,
                    text: message.text,
                    time: message.timestamp,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Posez votre question...",
                        border: InputBorder.none,
                      ),
                      controller: _promptController,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: colorScheme.primary,
                    child: Icon(Icons.send, color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/pharmacie_card.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PlatformFile? _selectedImage;
  Uint8List? _selectedImageBytes;

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

  Future<void> _pickFile() async {
    List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'webp'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = file;
        _selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de lire ce type de fichier.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiChat = ref.watch(aiChatProvider);
    final colorScheme = Theme.of(context).colorScheme;
    ref.listen(aiChatProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (previous?.messages.length != next.messages.length ||
          (previous?.isLoading == true && next.isLoading == false)) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("FindPharma AI")),
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
                    return const ChatTypingIndicator();
                  }
                  final message = aiChat.messages[i];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatBubble(
                          isUser: message.isUser,
                          text: message.text,
                          time: message.timestamp,
                        ),

                        if (!message.isUser)
                          ...aiChat.pharmacies
                              .where(
                                (pharmacy) => message.text
                                    .toLowerCase()
                                    .contains(pharmacy.name.toLowerCase()),
                              )
                              .map(
                                (pharmacy) => Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: PharmacyCardWidget(
                                    pharmacyId: pharmacy.id,
                                    name: pharmacy.name,
                                    district: pharmacy.district,
                                    phone: pharmacy.phone,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_selectedImage != null && _selectedImageBytes != null)
              Row(
                children: [
                  Image.memory(
                    _selectedImageBytes!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedImage!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: "Retirer l'image",
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _selectedImageBytes = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  InkWell(onTap: _pickFile, child: Icon(Icons.attach_file)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
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

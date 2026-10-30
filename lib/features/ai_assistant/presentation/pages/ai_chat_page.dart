import 'package:file_picker/file_picker.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_provider.dart';
import '../widgets/area_select_file.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/pharmacie_card.dart';
import '../widgets/warning_zone.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<PlatformFile> _selectedFiles = [];
  List<Uint8List?> _selectedFileBytes = [];

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
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'webp', 'docx', 'pdf', 'doc'],
    );

    if (files.isEmpty) return;

    const imageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

    try {
      final bytesByFile = await Future.wait(
        files.map((file) async {
          final extension = file.extension?.toLowerCase();

          if (!imageExtensions.contains(extension)) {
            return null;
          }
          return file.readAsBytes();
        }),
      );

      if (!mounted) return;

      setState(() {
        _selectedFiles = [..._selectedFiles, ...files];
        _selectedFileBytes = [..._selectedFileBytes, ...bytesByFile];
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de lire ce type de fichier")),
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
              child: WarningZone(),
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
            if (_selectedFiles.isNotEmpty)
              AreaSelectFile(
                selectedFiles: _selectedFiles,
                selectedFileBytes: _selectedFileBytes,
                onRemoveFile: (index) {
                  setState(() {
                    _selectedFiles.removeAt(index);
                    _selectedFileBytes.removeAt(index);
                  });
                },
                onRemoveAll: () {
                  setState(() {
                    _selectedFiles.clear();
                    _selectedFileBytes.clear();
                  });
                },
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

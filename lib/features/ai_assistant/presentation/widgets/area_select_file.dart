import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AreaSelectFile extends StatelessWidget {
  final List<PlatformFile> selectedFiles;
  final List<Uint8List?> selectedFileBytes;
  final ValueChanged<int> onRemoveFile;
  final VoidCallback onRemoveAll;

  const AreaSelectFile({
    super.key,
    required this.selectedFiles,
    required this.selectedFileBytes,
    required this.onRemoveFile,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Fichiers joints (${selectedFiles.length})",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: onRemoveAll,
                child: const Text("Tout retirer"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: selectedFiles.length > 3 ? 216 : selectedFiles.length * 72,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: selectedFiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = selectedFiles[index];
                final bytes = selectedFileBytes[index];
                final extension = file.extension?.toLowerCase();
                final isImage = {
                  'jpg',
                  'jpeg',
                  'png',
                  'webp',
                }.contains(extension);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: isImage && bytes != null
                              ? Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.broken_image_outlined,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  extension == 'pdf'
                                      ? Icons.picture_as_pdf
                                      : Icons.description,
                                  size: 34,
                                  color: colorScheme.primary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Retirer ${file.name}",
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onRemoveFile(index),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

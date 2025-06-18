import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VenueImageViewer extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final List<Widget>? actions;

  const VenueImageViewer({
    super.key,
    required this.title,
    required this.imageUrl,
    this.actions,
  });

  Widget _buildFallbackImage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No image available for $title',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dimensions for landscape layout
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          // For landscape images, we want to use more width
          final maxWidth = screenWidth * 0.95;
          final maxHeight = screenHeight * 0.5;

          return Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          softWrap: true,
                          maxLines: 5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Image viewer
                Flexible(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    child: imageUrl == null
                        ? _buildFallbackImage(context)
                        : PhotoView(
                            imageProvider: CachedNetworkImageProvider(
                              imageUrl!,
                              errorListener: (error) {},
                            ),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            initialScale: PhotoViewComputedScale.contained,
                            backgroundDecoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            loadingBuilder: (context, event) {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: event == null
                                      ? 0
                                      : event.cumulativeBytesLoaded /
                                          event.expectedTotalBytes!,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage(context);
                            },
                          ),
                  ),
                ),
                if (actions != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dialogBackgroundColor,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

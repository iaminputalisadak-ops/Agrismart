import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Product tiles use this so CDNs receive a normal mobile browser [User-Agent].
class AgriCachedProductImage extends StatelessWidget {
  const AgriCachedProductImage({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    required this.errorWidget,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.fadeInDuration,
  });

  static const Map<String, String> kImageHttpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.9',
  };

  final String imageUrl;
  final PlaceholderWidgetBuilder placeholder;
  final LoadingErrorWidgetBuilder errorWidget;
  final BoxFit fit;
  final int? memCacheWidth;
  final Duration? fadeInDuration;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: kImageHttpHeaders,
      fit: fit,
      memCacheWidth: memCacheWidth,
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 200),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

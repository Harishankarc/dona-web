import 'dart:typed_data';

import 'package:LeLaundrette/helpers/theme/admin_theme.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ImageBuilder extends StatefulWidget {
  final String? imageuri;
  final Uint8List? bytes;
  final bool? isPath;
  final Size? errorImagesize;

  const ImageBuilder(
      {super.key, this.imageuri, this.bytes, this.isPath, this.errorImagesize})
      : assert(!(bytes == null && isPath == true)),
        assert(!(imageuri == null && isPath == false));

  @override
  State<ImageBuilder> createState() => _ImageBuilderState();
}

class _ImageBuilderState extends State<ImageBuilder> with UIMixin {
  @override
  Widget build(BuildContext context) {
    return widget.isPath ?? false
        ? Image.memory(
            widget.bytes!,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(LucideIcons.file, size: 20),
          )
        : Container(
            color: Colors.white,
            child: CachedNetworkImage(
                imageUrl: widget.imageuri!,
                placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: AdminTheme.theme.contentTheme.primary,
                        ),
                      ),
                    ),
                errorWidget: (context, url, error) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: widget.errorImagesize?.width,
                          height: widget.errorImagesize?.height,
                          child: Image.asset(
                            'assets/images/others/noimage.png',
                            width: 50,
                            height: 50,
                          )),
                    ],
                  );
                }),
          );
  }
}

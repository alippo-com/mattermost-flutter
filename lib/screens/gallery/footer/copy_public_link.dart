// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/gallery.dart';
import 'package:mattermost_flutter/contexts/server.dart';
import 'package:mattermost_flutter/queries/remote/file.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';
import 'package:mattermost_flutter/components/toast.dart';
import 'package:mattermost_flutter/hooks/use_safe_area_insets.dart';

class CopyPublicLink extends HookWidget {
  final GalleryItemType item;
  final bool galleryView;
  final Function(GalleryAction) setAction;

  const CopyPublicLink({
    Key? key,
    required this.item,
    this.galleryView = true,
    required this.setAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insets = useSafeAreaInsets();
    final showToast = useState<bool?>(null);
    final error = useState<String>('');
    final mounted = useRef(true);

    useEffect(() {
      mounted.value = true;
      copyLink();

      return () {
        mounted.value = false;
      };
    }, []);

    useEffect(() {
      if (showToast.value == false) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted.value) {
            setAction(GalleryAction.none);
          }
        });
      }
    }, [showToast.value]);

    Future<void> copyLink() async {
      try {
        final publicLink = await fetchPublicLink(serverUrl, item.id);
        if (publicLink.containsKey('link')) {
          Clipboard.setData(ClipboardData(text: publicLink['link']));
        } else {
          error.value = 'Failed to copy link to clipboard';
        }
      } catch (e) {
        error.value = 'Failed to copy link to clipboard';
      } finally {
        showToast.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted.value) {
            showToast.value = false;
          }
        });
      }
    }

    final animatedStyle = useAnimation(
      duration: const Duration(milliseconds: 300),
      builder: (context, animationValue) {
        final marginBottom = galleryView ? GALLERY_FOOTER_HEIGHT + 8 : 0;
        return Positioned(
          bottom: insets.bottom + marginBottom,
          opacity: animationValue,
          child: Toast(
            style: error.value.isNotEmpty ? styles.error : styles.toast,
            message: error.value.isNotEmpty ? error.value : 'Link copied to clipboard',
            iconName: 'link-variant',
          ),
        );
      },
    );

    return animatedStyle;
  }
}

final styles = {
  'error': BoxDecoration(
    color: const Color(0xFFD24B4E),
  ),
  'toast': BoxDecoration(
    color: const Color(0xFF3DB887),
  ),
};

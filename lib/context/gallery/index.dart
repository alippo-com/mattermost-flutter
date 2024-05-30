// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';

class GalleryManagerItem {
  final int index;
  final ValueNotifier<dynamic> ref;

  GalleryManagerItem({required this.index, required this.ref});
}

class GalleryManagerItems {
  final Map<int, GalleryManagerItem> items = {};

  GalleryManagerItem? getItem(int index) => items[index];

  void addItem(int index, GalleryManagerItem item) {
    items[index] = item;
  }

  void clearItems() {
    items.clear();
  }
}

class GalleryInitProps {
  final Widget children;
  final String galleryIdentifier;

  GalleryInitProps({required this.children, required this.galleryIdentifier});
}

class Gallery {
  bool _init = false;
  Timer? timeout;

  final refsByIndexSV = ValueNotifier<GalleryManagerItems>(GalleryManagerItems());

  final sharedValues = GalleryManagerSharedValues(
    width: ValueNotifier(0),
    height: ValueNotifier(0),
    x: ValueNotifier(0),
    y: ValueNotifier(0),
    opacity: ValueNotifier(1),
    activeIndex: ValueNotifier(0),
    targetWidth: ValueNotifier(0),
    targetHeight: ValueNotifier(0),
  );

  final items = <int, GalleryManagerItem>{};

  bool get isInitialized => _init;

  GalleryManagerItem? resolveItem(int index) => items[index];

  void initialize() {
    _init = true;
  }

  void reset() {
    _init = false;
    items.clear();
    refsByIndexSV.value = GalleryManagerItems();
  }

  void resetSharedValues() {
    sharedValues.width.value = 0;
    sharedValues.height.value = 0;
    sharedValues.opacity.value = 1;
    sharedValues.activeIndex.value = -1;
    sharedValues.x.value = 0;
    sharedValues.y.value = 0;
  }

  void registerItem(int index, ValueNotifier<dynamic> ref) {
    if (items.containsKey(index)) return;

    addItem(index, ref);
  }

  void addItem(int index, ValueNotifier<dynamic> ref) {
    items[index] = GalleryManagerItem(index: index, ref: ref);

    timeout?.cancel();
    timeout = Timer(const Duration(milliseconds: 16), () {
      refsByIndexSV.value = GalleryManagerItems()..items.addAll(items);
      timeout = null;
    });
  }
}

class GalleryManager {
  final galleries = <String, Gallery>{};

  Gallery get(String identifier) {
    return galleries.putIfAbsent(identifier, () => Gallery());
  }

  bool remove(String identifier) {
    return galleries.remove(identifier) != null;
  }
}

final galleryManager = GalleryManager();

Gallery useGallery(String galleryIdentifier) {
  final gallery = galleryManager.get(galleryIdentifier);

  if (gallery == null) {
    throw Exception(
        'Cannot retrieve gallery manager from the context. Did you forget to wrap the app with GalleryProvider?');
  }

  return gallery;
}

class GalleryInit extends HookWidget {
  final Widget children;
  final String galleryIdentifier;

  GalleryInit({required this.children, required this.galleryIdentifier});

  @override
  Widget build(BuildContext context) {
    final gallery = useGallery(galleryIdentifier);

    useEffect(() {
      gallery.initialize();

      return () {
        gallery.reset();
      };
    }, []);

    useEffect(() {
      return () {
        galleryManager.remove(galleryIdentifier);
      };
    }, []);

    return children;
  }
}

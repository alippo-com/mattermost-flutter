import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class FileFilter extends StatefulWidget {
  final FileFilterType initialFilter;
  final void Function(FileFilterType) setFilter;
  final String title;

  FileFilter({
    required this.initialFilter,
    required this.setFilter,
    required this.title,
  });

  @override
  _FileFilterState createState() => _FileFilterState();
}

class _FileFilterState extends State<FileFilter> {
  late final ThemeData theme;
  late final bool isTablet;
  late final List<FilterItem> data;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    isTablet = useIsTablet();
    data = [
      FilterItem(
        id: t('screen.search.results.filter.all_file_types'),
        defaultMessage: 'All file types',
        filterType: FileFilterType.all,
      ),
      FilterItem(
        id: t('screen.search.results.filter.documents'),
        defaultMessage: 'Documents',
        filterType: FileFilterType.documents,
      ),
      FilterItem(
        id: t('screen.search.results.filter.spreadsheets'),
        defaultMessage: 'Spreadsheets',
        filterType: FileFilterType.spreadsheets,
      ),
      FilterItem(
        id: t('screen.search.results.filter.presentations'),
        defaultMessage: 'Presentations',
        filterType: FileFilterType.presentations,
      ),
      FilterItem(
        id: t('screen.search.results.filter.code'),
        defaultMessage: 'Code',
        filterType: FileFilterType.code,
      ),
      FilterItem(
        id: t('screen.search.results.filter.images'),
        defaultMessage: 'Images',
        filterType: FileFilterType.images,
      ),
      FilterItem(
        id: t('screen.search.results.filter.audio'),
        defaultMessage: 'Audio',
        filterType: FileFilterType.audio,
      ),
      FilterItem(
        id: t('screen.search.results.filter.videos'),
        defaultMessage: 'Videos',
        filterType: FileFilterType.videos,
      ),
    ];
  }

  void handleOnPress(FileFilterType fileType) {
    if (fileType != widget.initialFilter) {
      widget.setFilter(fileType);
    }
    dismissBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);

    return BottomSheetContent(
      showButton: false,
      showTitle: !isTablet,
      testID: 'search.filters',
      title: widget.title,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(color: changeOpacity(theme.colorScheme.onSurface, 0.08)),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return OptionItem(
            label: intl.formatMessage(item.id, defaultMessage: item.defaultMessage),
            type: 'select',
            action: () => handleOnPress(item.filterType),
            selected: widget.initialFilter == item.filterType,
          );
        },
      ),
    );
  }
}

class FilterItem {
  final String id;
  final String defaultMessage;
  final FileFilterType filterType;
  final bool separator;

  FilterItem({
    required this.id,
    required this.defaultMessage,
    required this.filterType,
    this.separator = false,
  });
}

enum FileFilterType {
  all,
  documents,
  spreadsheets,
  presentations,
  code,
  images,
  audio,
  videos,
}

ThemeData getStyleSheet(ThemeData theme) {
  return ThemeData(
    dividerColor: changeOpacity(theme.colorScheme.onSurface, 0.08),
  );
}

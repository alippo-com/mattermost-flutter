import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/files_search/no_results.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/files.dart';
import 'package:mattermost_flutter/utils/files.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/search.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/file_options/mobile_options.dart';
import 'package:mattermost_flutter/file_options/toasts.dart';
import 'package:mattermost_flutter/file_result.dart';
import 'package:mattermost_flutter/typings/database/models/servers/channel.dart';
import 'package:mattermost_flutter/typings/screens/gallery.dart';

ThemeData getStyles(ThemeData theme) {
    return ThemeData(
        textTheme: theme.textTheme.copyWith(
            headline6: theme.textTheme.headline6.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onSurface,
            ),
        ),
    );
}

class FileResults extends StatefulWidget {
    final bool canDownloadFiles;
    final List<ChannelModel> fileChannels;
    final List<FileInfo> fileInfos;
    final EdgeInsets paddingTop;
    final bool publicLinkEnabled;
    final String searchValue;
    final bool isChannelFiles;
    final bool isFilterEnabled;

    FileResults({
        required this.canDownloadFiles,
        required this.fileChannels,
        required this.fileInfos,
        required this.paddingTop,
        required this.publicLinkEnabled,
        required this.searchValue,
        this.isChannelFiles = false,
        this.isFilterEnabled = false,
    });

    @override
    _FileResultsState createState() => _FileResultsState();
}

class _FileResultsState extends State<FileResults> {
    late ThemeData theme;
    late ThemeData styles;
    late EdgeInsets insets;
    late bool isTablet;
    late List<FileInfo> orderedFileInfos;
    late List<GalleryItem> orderedGalleryItems;
    late Map<String, String> channelNames;
    late Map<String, int> fileInfosIndexes;
    late List<FileInfo> filesForGallery;
    GalleryAction action = GalleryAction.none;
    FileInfo? lastViewedFileInfo;

    @override
    void initState() {
        super.initState();
        theme = Theme.of(context);
        styles = getStyles(theme);
        insets = MediaQuery.of(context).viewPadding;
        isTablet = DeviceUtils.isTablet();
        filesForGallery = FileUtils.getFilesForGallery(widget.fileInfos, widget.publicLinkEnabled);
        channelNames = FileUtils.getChannelNamesWithID(widget.fileChannels);
        orderedFileInfos = FileUtils.getOrderedFileInfos(filesForGallery);
        fileInfosIndexes = FileUtils.getFileInfosIndexes(orderedFileInfos);
        orderedGalleryItems = FileUtils.getOrderedGalleryItems(orderedFileInfos);
    }

    void onPreviewPress(int idx) {
        GalleryUtils.openGalleryAtIndex('search-files-location', idx, orderedGalleryItems);
    }

    void onOptionsPress(FileInfo fileInfo) {
        setState(() {
            lastViewedFileInfo = fileInfo;
        });

        if (!isTablet) {
            FileOptions.showMobileOptionsBottomSheet(
                context: context,
                fileInfo: fileInfo,
                insets: insets,
                numOptions: FileUtils.getNumberFileMenuOptions(widget.canDownloadFiles, widget.publicLinkEnabled),
                setAction: (action) => setState(() => this.action = action),
                theme: theme,
            );
        }
    }

    Widget renderItem(BuildContext context, int index) {
        FileInfo item = orderedFileInfos[index];
        String? channelName;

        if (!widget.isChannelFiles && item.channel_id != null) {
            channelName = channelNames[item.channel_id!];
        }

        return FileResult(
            canDownloadFiles: widget.canDownloadFiles,
            channelName: channelName,
            fileInfo: item,
            index: fileInfosIndexes[item.id!] ?? 0,
            numOptions: FileUtils.getNumberFileMenuOptions(widget.canDownloadFiles, widget.publicLinkEnabled),
            onOptionsPress: onOptionsPress,
            onPress: onPreviewPress,
            publicLinkEnabled: widget.publicLinkEnabled,
            setAction: (action) => setState(() => this.action = action),
            updateFileForGallery: (idx, file) {
                setState(() {
                    orderedFileInfos[idx] = file;
                });
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                if (orderedFileInfos.isEmpty)
                    NoResultsWithTerm(
                        term: widget.searchValue,
                        type: TabTypes.FILES,
                    )
                else
                    Expanded(
                        child: ListView.separated(
                            padding: widget.paddingTop,
                            itemCount: orderedFileInfos.length,
                            itemBuilder: renderItem,
                            separatorBuilder: (context, index) => Divider(height: 10),
                        ),
                    ),
                Toasts(
                    action: action,
                    fileInfo: lastViewedFileInfo,
                    setAction: (action) => setState(() => this.action = action),
                ),
            ],
        );
    }
}

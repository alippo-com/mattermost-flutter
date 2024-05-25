
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/file_results.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'header.dart';

class ChannelFiles extends StatefulWidget {
  final ChannelModel channel;
  final AvailableScreens componentId;
  final bool canDownloadFiles;
  final bool publicLinkEnabled;

  ChannelFiles({
    required this.channel,
    required this.componentId,
    required this.canDownloadFiles,
    required this.publicLinkEnabled,
  });

  @override
  _ChannelFilesState createState() => _ChannelFilesState();
}

class _ChannelFilesState extends State<ChannelFiles> {
  late ThemeData theme;
  late String serverUrl;

  bool loading = true;
  String term = '';
  FileFilter filter = FileFilters.ALL;
  List<FileInfo> fileInfos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of<ThemeContext>(context).theme;
    serverUrl = Provider.of<ServerContext>(context).serverUrl;
    _handleSearch(term, filter);
  }

  Future<void> _handleSearch(String searchTerm, FileFilter filter) async {
    setState(() {
      loading = true;
    });

    final searchParams = getSearchParams(widget.channel.id, searchTerm, filter);
    final files = await searchFiles(serverUrl, widget.channel.teamId, searchParams);
    setState(() {
      fileInfos = files.isNotEmpty ? files : [];
      loading = false;
    });
  }

  void _handleFilterChange(FileFilter filterValue) {
    setState(() {
      loading = true;
      filter = filterValue;
    });
    _handleSearch(term, filterValue);
  }

  void _clearSearch() {
    setState(() {
      term = '';
    });
    _handleSearch('', filter);
  }

  void _onTextChange(String searchTerm) {
    setState(() {
      term = searchTerm;
      loading = true;
    });
    _handleSearch(searchTerm, filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Search(
                placeholder: 'Search',
                onChangeText: _onTextChange,
                onCancel: _clearSearch,
                value: term,
                keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
              ),
            ),
            Header(
              onFilterChanged: _handleFilterChange,
              selectedFilter: filter,
            ),
            Expanded(
              child: loading
                  ? Center(
                      child: Loading(color: theme.buttonBg),
                    )
                  : FileResults(
                      canDownloadFiles: widget.canDownloadFiles,
                      fileChannels: [widget.channel],
                      fileInfos: fileInfos,
                      publicLinkEnabled: widget.publicLinkEnabled,
                      searchValue: term,
                      isChannelFiles: true,
                      isFilterEnabled: filter != FileFilters.ALL,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

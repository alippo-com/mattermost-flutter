
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/components/server_user_list.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/view.dart' as ViewConstants;
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/helpers/api/general.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'channel_list_row.dart';
import 'custom_list.dart';
import 'option_list_row.dart';
import 'selected_options.dart';

const VALID_DATASOURCES = [
  ViewConstants.DATA_SOURCE_CHANNELS,
  ViewConstants.DATA_SOURCE_USERS,
  ViewConstants.DATA_SOURCE_DYNAMIC
];
const SUBMIT_BUTTON_ID = 'submit-integration-selector-multiselect';

class IntegrationSelector extends HookWidget {
  final String dataSource;
  final List<dynamic> data;
  final bool isMultiselect;
  final dynamic selected;
  final Function handleSelect;
  final String currentTeamId;
  final String currentUserId;
  final String componentId;
  final Future<List<DialogOption>> Function(String userInput)? getDynamicOptions;
  final List<PostActionOption>? options;

  IntegrationSelector({
    required this.dataSource,
    required this.data,
    this.isMultiselect = false,
    required this.selected,
    required this.handleSelect,
    required this.currentTeamId,
    required this.currentUserId,
    required this.componentId,
    this.getDynamicOptions,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final theme = useTheme();
    final searchTimeoutId = useRef<Timer?>(null);
    final style = getStyleSheet(theme);
    final intl = useIntl();

    final integrationData = useState<List<dynamic>>(data);
    final loading = useState<bool>(false);
    final term = useState<String>('');
    final searchResults = useState<List<dynamic>>([]);
    final multiselectSelected = useState<Map<String, dynamic>>({});
    final selectedIds = useState<Map<String, dynamic>>({});
    final customListData = useState<List<dynamic>>([]);
    final page = useRef<int>(-1);
    final next = useRef<bool>(VALID_DATASOURCES.contains(dataSource));

    void clearSearch() {
      term.value = '';
      searchResults.value = [];
    }

    Widget rightButton = useMemo(() {
      final base = buildNavigationButton(
        SUBMIT_BUTTON_ID,
        'integration_selector.multiselect.submit.button',
        null,
        intl.formatMessage(id: 'integration_selector.multiselect.submit', defaultMessage: 'Done'),
      );
      base.enabled = true;
      base.showAsAction = 'always';
      base.color = theme.sidebarHeaderTextColor;
      return base;
    }, [theme.sidebarHeaderTextColor, intl]);

    void handleSelectItem(dynamic item) {
      if (!isMultiselect) {
        handleSelect(item);
        close();
        return;
      }

      switch (dataSource) {
        case ViewConstants.DATA_SOURCE_CHANNELS:
          final itemKey = extractItemKey(dataSource, item);
          multiselectSelected.value = toggleFromMap(multiselectSelected.value, itemKey, item);
          break;
        default:
          final itemKey = extractItemKey(dataSource, item);
          multiselectSelected.value = toggleFromMap(multiselectSelected.value, itemKey, item);
      }
    }

    void handleRemoveOption(dynamic item) {
      final itemKey = extractItemKey(dataSource, item);

      if (dataSource == ViewConstants.DATA_SOURCE_USERS) {
        selectedIds.value.remove(itemKey);
      } else {
        multiselectSelected.value.remove(itemKey);
      }
    }

    Future<void> getChannels() async {
      if (next.current && !loading.value && term.value.isEmpty) {
        loading.value = true;
        page.current += 1;

        final channelData = await fetchChannels(serverUrl, currentTeamId, page.current);

        loading.value = false;

        if (channelData.isNotEmpty) {
          integrationData.value.addAll(channelData);
        } else {
          next.current = false;
        }
      }
    }

    Future<void> loadMore() async {
      if (dataSource == ViewConstants.DATA_SOURCE_CHANNELS) {
        await getChannels();
      }
    }

    Future<void> searchDynamicOptions(String searchTerm) async {
      if (options != null && options != integrationData.value && searchTerm.isEmpty) {
        integrationData.value = options!;
      }

      if (getDynamicOptions == null) {
        return;
      }

      final results = await getDynamicOptions!(searchTerm.toLowerCase());
      final searchData = results ?? [];

      if (searchTerm.isNotEmpty) {
        searchResults.value = searchData;
      } else {
        integrationData.value = searchData;
      }
    }

    void handleSelectProfile(UserProfile user) {
      if (!isMultiselect) {
        handleSelect(user);
        close();
      }

      selectedIds.value = handleIdSelection(dataSource, selectedIds.value, user);
    }

    void onHandleMultiselectSubmit() {
      if (dataSource == ViewConstants.DATA_SOURCE_USERS) {
        handleSelect(selectedIds.value.values.toList());
      } else {
        handleSelect(multiselectSelected.value.values.toList());
      }
      close();
    }

    void onSearch(String text) {
      if (text.isEmpty) {
        clearSearch();
        return;
      }

      term.value = text;

      searchTimeoutId.current?.cancel();

      searchTimeoutId.current = Timer(Duration(milliseconds: General.SEARCH_TIMEOUT_MILLISECONDS), () async {
        if (dataSource.isEmpty) {
          searchResults.value = filterSearchData('', integrationData.value, text);
          return;
        }

        loading.value = true;

        switch (dataSource) {
          case ViewConstants.DATA_SOURCE_CHANNELS:
            final isSearch = true;
            final receivedChannels = await searchChannels(serverUrl, text, currentTeamId, isSearch);

            if (receivedChannels.isNotEmpty) {
              searchResults.value = receivedChannels;
            }
            break;
          case ViewConstants.DATA_SOURCE_DYNAMIC:
            await searchDynamicOptions(text);
            break;
        }

        loading.value = false;
      });
    }

    useEffect(() {
      return () {
        searchTimeoutId.current?.cancel();
      };
    }, []);

    useEffect(() {
      if (dataSource == ViewConstants.DATA_SOURCE_CHANNELS) {
        getChannels();
      } else {
        searchDynamicOptions('');
      }
    }, []);

    useEffect(() {
      customListData.value = term.value.isNotEmpty ? searchResults.value : integrationData.value;

      if (dataSource == ViewConstants.DATA_SOURCE_DYNAMIC) {
        customListData.value = (integrationData.value as List<DialogOption>).where((option) => option.text.toLowerCase().contains(term.value)).toList();
      }
    }, [searchResults.value, integrationData.value]);

    useEffect(() {
      if (!isMultiselect) return;

      setButtons(componentId, {
        rightButtons: [rightButton],
      });
    }, [rightButton, componentId, isMultiselect]);

    useEffect(() {
      if (!isMultiselect) return;

      final multiselectItems = <String, dynamic>{};

      if (isMultiselect && selected is List && ![ViewConstants.DATA_SOURCE_USERS, ViewConstants.DATA_SOURCE_CHANNELS].contains(dataSource)) {
        for (final value in selected) {
          final option = options?.firstWhere((opt) => opt.value == value, orElse: () => null);
          if (option != null) {
            multiselectItems[value] = option;
          }
        }

        multiselectSelected.value = multiselectItems;
      }
    }, []);

    Widget renderLoading() {
      if (!loading.value) return Container();

      String text;
      switch (dataSource) {
        case ViewConstants.DATA_SOURCE_CHANNELS:
          text = t('mobile.integration_selector.loading_channels');
          break;
        default:
          text = t('mobile.integration_selector.loading_options');
          break;
      }

      return Center(
        child: Text(intl.formatMessage(id: text)),
      );
    }

    Widget renderNoResults() {
      if (loading.value || page.current == -1) return Container();

      return Center(
        child: Text(intl.formatMessage(id: 'mobile.custom_list.no_results')),
      );
    }

    Widget renderChannelItem(dynamic itemProps) {
      final itemSelected = multiselectSelected.value.containsKey(itemProps.item.id);
      return ChannelListRow(
        key: itemProps.id,
        channel: itemProps.item,
        theme: theme,
        selectable: isMultiselect,
        selected: itemSelected,
      );
    }

    Widget renderOptionItem(dynamic itemProps) {
      final itemSelected = multiselectSelected.value.containsKey(itemProps.item.value);
      return OptionListRow(
        key: itemProps.id,
        option: itemProps.item,
        theme: theme,
        selectable: isMultiselect,
        selected: itemSelected,
      );
    }

    Widget getRenderItem() {
      switch (dataSource) {
        case ViewConstants.DATA_SOURCE_CHANNELS:
          return renderChannelItem;
        default:
          return renderOptionItem;
      }
    }

    Widget renderSelectedOptions() {
      List<dynamic> selectedItems = multiselectSelected.value.values.toList();

      if (dataSource == ViewConstants.DATA_SOURCE_USERS) {
        selectedItems = selectedIds.value.values.toList();
      }

      if (selectedItems.isEmpty) return Container();

      return Column(
        children: [
          SelectedOptions(
            theme: theme,
            selectedOptions: selectedItems,
            dataSource: dataSource,
            onRemove: handleRemoveOption,
          ),
          Divider(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(intl.formatMessage(id: 'integration_selector.title')),
        actions: isMultiselect ? [IconButton(icon: Icon(Icons.check), onPressed: onHandleMultiselectSubmit)] : [],
      ),
      body: Column(
        children: [
          SearchBar(
            placeholder: intl.formatMessage(id: 'search_bar.search'),
            onChanged: onSearch,
            value: term.value,
          ),
          renderSelectedOptions(),
          Expanded(
            child: customListData.value.isNotEmpty
                ? ListView.builder(
                    itemCount: customListData.value.length,
                    itemBuilder: (context, index) {
                      final item = customListData.value[index];
                      return getRenderItem()(item);
                    },
                  )
                : renderNoResults(),
          ),
          if (loading.value) renderLoading(),
        ],
      ),
    );
  }
}

void close() {
  // Implement your close function here
}

String extractItemKey(String dataSource, dynamic item) {
  switch (dataSource) {
    case ViewConstants.DATA_SOURCE_USERS:
      return item.id;
    case ViewConstants.DATA_SOURCE_CHANNELS:
      return item.id;
    default:
      return item.value;
  }
}

Map<String, T> toggleFromMap<T>(Map<String, T> current, String key, T item) {
  final newMap = Map<String, T>.from(current);

  if (current.containsKey(key)) {
    newMap.remove(key);
  } else {
    newMap[key] = item;
  }

  return newMap;
}

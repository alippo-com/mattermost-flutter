// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_intl/intl.dart';
import 'package:mattermost/constants/general.dart';
import 'package:mattermost/constants/channel.dart';
import 'package:mattermost/context/theme.dart';
import 'package:mattermost/hooks/autocomplete.dart';
import 'package:mattermost/hooks/device.dart';
import 'package:mattermost/hooks/input.dart';
import 'package:mattermost/i18n.dart';
import 'package:mattermost/utils/theme.dart';
import 'package:mattermost/utils/typography.dart';
import 'package:mattermost/widgets/autocomplete.dart';
import 'package:mattermost/widgets/error_text.dart';
import 'package:mattermost/widgets/floating_text_input_label.dart';
import 'package:mattermost/widgets/formatted_text.dart';
import 'package:mattermost/widgets/loading.dart';
import 'package:mattermost/widgets/option_item.dart';
import 'package:mattermost/widgets/safe_area.dart';
import 'package:mattermost/widgets/keyboard_aware_scroll_view.dart';

const FIELD_MARGIN_BOTTOM = 24.0;
const MAKE_PRIVATE_MARGIN_BOTTOM = 32.0;
const BOTTOM_AUTOCOMPLETE_SEPARATION = 10.0;
const LIST_PADDING = 32.0;
const AUTOCOMPLETE_ADJUST = 5.0;

class ChannelInfoForm extends HookWidget {
  final String channelType;
  final String displayName;
  final Function(String) onDisplayNameChange;
  final bool editing;
  final dynamic error;
  final String header;
  final bool headerOnly;
  final Function(String) onHeaderChange;
  final Function(String) onTypeChange;
  final String purpose;
  final Function(String) onPurposeChange;
  final bool saving;
  final String type;

  ChannelInfoForm({
    Key key,
    this.channelType,
    @required this.displayName,
    @required this.onDisplayNameChange,
    @required this.editing,
    this.error,
    @required this.header,
    this.headerOnly,
    @required this.onHeaderChange,
    @required this.onTypeChange,
    @required this.purpose,
    @required this.onPurposeChange,
    @required this.saving,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final styles = useMemoized(() => getStyleSheet(theme), [theme]);

    final nameInput = useRef<TextFieldController>();
    final purposeInput = useRef<TextFieldController>();
    final headerInput = useRef<TextFieldController>();

    final scrollViewRef = useRef<KeyboardAwareScrollViewController>();

    final updateScrollTimeout = useRef<Timer>();

    final mainView = useRef<Container>();
    final wrapperHeight = useState(0.0);
    final keyboardOverlap = useKeyboardOverlap(mainView, wrapperHeight);

    final propagateValue = useInputPropagation();
    final shouldProcessEvent = useInputPropagation();

    final keyboardHeight = useKeyboardHeight();
    final keyboardVisible = useState(false);
    final scrollPosition = useState(0.0);

    final errorHeight = useState(0.0);
    final displayNameFieldHeight = useState(0.0);
    final makePrivateHeight = useState(0.0);
    final purposeFieldHeight = useState(0.0);
    final headerFieldHeight = useState(0.0);
    final headerPosition = useState(0.0);

    final optionalText = formatMessage(intl, id: t('channel_modal.optional'), defaultMessage: '(optional)');
    final labelDisplayName = formatMessage(intl, id: t('channel_modal.name'), defaultMessage: 'Name');
    final labelPurpose = formatMessage(intl, id: t('channel_modal.purpose'), defaultMessage: 'Purpose') + ' ' + optionalText;
    final labelHeader = formatMessage(intl, id: t('channel_modal.header'), defaultMessage: 'Header') + ' ' + optionalText;

    final placeholderDisplayName = formatMessage(intl, id: t('channel_modal.nameEx'), defaultMessage: 'Bugs, Marketing');
    final placeholderPurpose = formatMessage(intl, id: t('channel_modal.purposeEx'), defaultMessage: 'A channel to file bugs and improvements');
    final placeholderHeader = formatMessage(intl, id: t('channel_modal.headerEx'), defaultMessage: 'Use Markdown to format header text');

    final makePrivateLabel = formatMessage(intl, id: t('channel_modal.makePrivate.label'), defaultMessage: 'Make Private');
    final makePrivateDescription = formatMessage(intl, id: t('channel_modal.makePrivate.description'), defaultMessage: 'When a channel is set to private, only invited team members can access and participate in that channel.');

    final displayHeaderOnly = headerOnly || channelType == General.DM_CHANNEL || channelType == General.GM_CHANNEL;
    final showSelector = !displayHeaderOnly && !editing;

    final isPrivate = type == General.PRIVATE_CHANNEL;

    final handlePress = () {
      final chtype = isPrivate ? General.OPEN_CHANNEL : General.PRIVATE_CHANNEL;
      onTypeChange(chtype);
    };

    final blur = useCallback(() {
      nameInput.current?.blur();
      purposeInput.current?.blur();
      headerInput.current?.blur();
      scrollViewRef.current?.scrollToPosition(0, 0, true);
    }, []);

    final scrollHeaderToTop = useCallback(() {
      if (scrollViewRef?.current) {
        scrollViewRef.current?.scrollToPosition(0, headerPosition.value);
      }
    }, [headerPosition]);

    final onScroll = useCallback((e) {
      final pos = e.nativeEvent.contentOffset.y;
      if (updateScrollTimeout.current != null) {
        updateScrollTimeout.current.cancel();
      }
      updateScrollTimeout.current = Timer(Duration(milliseconds: 200), () {
        scrollPosition.value = pos;
        updateScrollTimeout.current = null;
      });
    }, []);

    useEffect(() {
      if (keyboardVisible.value && keyboardHeight.value == 0) {
        keyboardVisible.value = false;
      }
      if (!keyboardVisible.value && keyboardHeight.value != 0) {
        keyboardVisible.value = true;
      }
    }, [keyboardHeight]);

    final onHeaderAutocompleteChange = useCallback((value) {
      onHeaderChange(value);
      propagateValue(value);
    }, [onHeaderChange]);

    final onHeaderInputChange = useCallback((value) {
      if (!shouldProcessEvent(value)) {
        return;
      }
      onHeaderChange(value);
    }, [onHeaderChange]);

    final onLayoutError = useCallback((e) {
      errorHeight.value = e.layout.height;
    }, []);
    final onLayoutMakePrivate = useCallback((e) {
      makePrivateHeight.value = e.layout.height;
    }, []);
    final onLayoutDisplayName = useCallback((e) {
      displayNameFieldHeight.value = e.layout.height;
    }, []);
    final onLayoutPurpose = useCallback((e) {
      purposeFieldHeight.value = e.layout.height;
    }, []);
    final onLayoutHeader = useCallback((e) {
      headerFieldHeight.value = e.layout.height;
      headerPosition.value = e.layout.y;
    }, []);
    final onLayoutWrapper = useCallback((e) {
      wrapperHeight.value = e.layout.height;
    }, []);

    final otherElementsSize = LIST_PADDING + errorHeight.value +
        (showSelector ? makePrivateHeight.value + MAKE_PRIVATE_MARGIN_BOTTOM : 0) +
        (displayHeaderOnly ? 0 : purposeFieldHeight.value + FIELD_MARGIN_BOTTOM + displayNameFieldHeight.value + FIELD_MARGIN_BOTTOM);

    final workingSpace = wrapperHeight.value - keyboardOverlap;
    final spaceOnTop = otherElementsSize - scrollPosition.value - AUTOCOMPLETE_ADJUST;
    final spaceOnBottom = (workingSpace + scrollPosition.value) - (otherElementsSize + headerFieldHeight.value + BOTTOM_AUTOCOMPLETE_SEPARATION);

    final autocompletePosition = spaceOnBottom > spaceOnTop ?
    (otherElementsSize + headerFieldHeight.value) - scrollPosition.value :
    (workingSpace + scrollPosition.value + AUTOCOMPLETE_ADJUST + keyboardOverlap) - otherElementsSize;
    final autocompleteAvailableSpace = spaceOnBottom > spaceOnTop ? spaceOnBottom : spaceOnTop;
    final growDown = spaceOnBottom > spaceOnTop;

    final animatedAutocompletePosition = useAutocompleteDefaultAnimatedValues(autocompletePosition, autocompleteAvailableSpace);

    if (saving) {
      return Scaffold(
        body: Center(
          child: Loading(
            color: theme.centerChannelColor,
            size: 'large',
          ),
        ),
      );
    }

    Widget displayError;
    if (error != null) {
      displayError = SafeArea(
        child: Container(
          width: double.infinity,
          onLayout: onLayoutError,
          child: Center(
            child: ErrorText(
              error: error,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        onLayout: onLayoutWrapper,
        child: KeyboardAwareScrollView(
          ref: scrollViewRef,
          keyboardShouldPersistTaps: true,
          enableAutomaticScroll: !keyboardVisible.value,
          contentContainerStyle: styles.scrollView,
          onScroll: onScroll,
          child: GestureDetector(
            onTap: blur,
            child: Column(
              children: [
                if (displayError != null) displayError,
                if (showSelector)
                  OptionItem(
                    label: makePrivateLabel,
                    description: makePrivateDescription,
                    action: handlePress,
                    type: 'toggle',
                    selected: isPrivate,
                    icon: Icons.lock_outline,
                    containerStyle: styles.makePrivateContainer,
                    onLayout: onLayoutMakePrivate,
                  ),
                if (!displayHeaderOnly)
                  Column(
                    children: [
                      FloatingTextInput(
                        autoCorrect: false,
                        autoCapitalize: TextCapitalization.none,
                        blurOnSubmit: false,
                        disableFullscreenUI: true,
                        enablesReturnKeyAutomatically: true,
                        label: labelDisplayName,
                        placeholder: placeholderDisplayName,
                        onChanged: onDisplayNameChange,
                        maxLength: Channel.MAX_CHANNEL_NAME_LENGTH,
                        keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
                        returnKeyType: TextInputAction.next,
                        showErrorIcon: false,
                        spellCheck: false,
                        value: displayName,
                        ref: nameInput,
                        containerStyle: styles.fieldContainer,
                        theme: theme,
                        onLayout: onLayoutDisplayName,
                      ),
                      Container(
                        onLayout: onLayoutPurpose,
                        child: Column(
                          children: [
                            FloatingTextInput(
                              autoCorrect: false,
                              autoCapitalize: TextCapitalization.none,
                              blurOnSubmit: false,
                              disableFullscreenUI: true,
                              enablesReturnKeyAutomatically: true,
                              label: labelPurpose,
                              placeholder: placeholderPurpose,
                              onChanged: onPurposeChange,
                              keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
                              returnKeyType: TextInputAction.next,
                              showErrorIcon: false,
                              spellCheck: false,
                              value: purpose,
                              ref: purposeInput,
                              theme: theme,
                            ),
                            FormattedText(
                              style: styles.helpText,
                              id: 'channel_modal.descriptionHelp',
                              defaultMessage: 'Describe how this channel should be used.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Container(
                  onLayout: onLayoutHeader,
                  child: Column(
                    children: [
                      FloatingTextInput(
                        autoCorrect: false,
                        autoCapitalize: TextCapitalization.none,
                        blurOnSubmit: false,
                        disableFullscreenUI: true,
                        enablesReturnKeyAutomatically: true,
                        label: labelHeader,
                        placeholder: placeholderHeader,
                        onChanged: onHeaderInputChange,
                        multiline: true,
                        keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
                        returnKeyType: TextInputAction.next,
                        showErrorIcon: false,
                        spellCheck: false,
                        value: header,
                        ref: headerInput,
                        theme: theme,
                        onFocus: scrollHeaderToTop,
                      ),
                      FormattedText(
                        style: styles.helpText,
                        id: 'channel_modal.headerHelp',
                        defaultMessage: 'Specify text to appear in the channel header beside the channel name. For example, include frequently used links by typing link text [Link Title](http://example.com).',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

getStyleSheet(theme) {
  return {
    'container': {
      'flex': 1,
    },
    'scrollView': {
      'paddingVertical': LIST_PADDING,
      'paddingHorizontal': 20.0,
    },
    'errorContainer': {
      'width': '100%',
    },
    'errorWrapper': {
      'justifyContent': 'center',
      'alignItems': 'center',
    },
    'loading': {
      'flex': 1,
      'alignItems': 'center',
      'justifyContent': 'center',
    },
    'makePrivateContainer': {
      'marginBottom': MAKE_PRIVATE_MARGIN_BOTTOM,
    },
    'fieldContainer': {
      'marginBottom': FIELD_MARGIN_BOTTOM,
    },
    'helpText': {
      ...typography('Body', 75, 'Regular'),
      'color': changeOpacity(theme.centerChannelColor, 0.5),
      'marginTop': 8.0,
    },
  };
}

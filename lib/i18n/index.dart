// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants/deep_link.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/assets/i18n/en.dart';
import 'package:mattermost_flutter/assets/i18n/bg.dart';
import 'package:mattermost_flutter/assets/i18n/de.dart';
import 'package:mattermost_flutter/assets/i18n/en_AU.dart';
import 'package:mattermost_flutter/assets/i18n/es.dart';
import 'package:mattermost_flutter/assets/i18n/fa.dart';
import 'package:mattermost_flutter/assets/i18n/fr.dart';
import 'package:mattermost_flutter/assets/i18n/hu.dart';
import 'package:mattermost_flutter/assets/i18n/it.dart';
import 'package:mattermost_flutter/assets/i18n/ja.dart';
import 'package:mattermost_flutter/assets/i18n/ko.dart';
import 'package:mattermost_flutter/assets/i18n/nl.dart';
import 'package:mattermost_flutter/assets/i18n/pl.dart';
import 'package:mattermost_flutter/assets/i18n/pt_BR.dart';
import 'package:mattermost_flutter/assets/i18n/ro.dart';
import 'package:mattermost_flutter/assets/i18n/ru.dart';
import 'package:mattermost_flutter/assets/i18n/sv.dart';
import 'package:mattermost_flutter/assets/i18n/tr.dart';
import 'package:mattermost_flutter/assets/i18n/uk.dart';
import 'package:mattermost_flutter/assets/i18n/vi.dart';
import 'package:mattermost_flutter/assets/i18n/zh_CN.dart';
import 'package:mattermost_flutter/assets/i18n/zh_TW.dart';
import 'package:mattermost_flutter/utils/available_languages.dart';

const String primaryLocale = 'en';
String defaultLocale = getLocaleFromLanguage(Intl.getCurrentLocale());

Map<String, dynamic> loadTranslation([String? locale]) {
  try {
    Map<String, dynamic> translations;
    switch (locale) {
      case 'bg':
        translations = bg;
        break;
      case 'de':
        translations = de;
        break;
      case 'en-AU':
        translations = en_AU;
        break;
      case 'es':
        translations = es;
        break;
      case 'fa':
        translations = fa;
        break;
      case 'fr':
        translations = fr;
        break;
      case 'hu':
        translations = hu;
        break;
      case 'it':
        translations = it;
        break;
      case 'ja':
        translations = ja;
        break;
      case 'ko':
        translations = ko;
        break;
      case 'nl':
        translations = nl;
        break;
      case 'pl':
        translations = pl;
        break;
      case 'pt-BR':
        translations = pt_BR;
        break;
      case 'ro':
        translations = ro;
        break;
      case 'ru':
        translations = ru;
        break;
      case 'sv':
        translations = sv;
        break;
      case 'tr':
        translations = tr;
        break;
      case 'uk':
        translations = uk;
        break;
      case 'vi':
        translations = vi;
        break;
      case 'zh-CN':
        translations = zh_CN;
        break;
      case 'zh-TW':
        translations = zh_TW;
        break;
      default:
        translations = en;
        break;
    }

    return translations;
  } catch (e) {
    logError('NO Translation found', e);
    return en;
  }
}

String getLocaleFromLanguage(String lang) {
  var languageCode = lang.split('-')[0];
  var locale = availableLanguages[lang] ?? availableLanguages[languageCode] ?? primaryLocale;
  return locale;
}

void resetMomentLocale([String? locale]) {
  Intl.defaultLocale = locale?.split('-')[0] ?? defaultLocale.split('-')[0];
}

Map<String, dynamic> getTranslations(String lang) {
  var locale = getLocaleFromLanguage(lang);
  return loadTranslation(locale);
}

String getLocalizedMessage(String lang, String id, [String? defaultMessage]) {
  var locale = getLocaleFromLanguage(lang);
  var translations = getTranslations(locale);

  return translations[id] ?? defaultMessage ?? '';
}

String t(String v) {
  return v;
}

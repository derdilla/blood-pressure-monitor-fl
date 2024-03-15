import 'package:flutter/material.dart';

/// Selects the correct display name for a specific language code.
String getDisplayLanguage(Locale l) => switch(l.toLanguageTag()) {
  'en' => 'English',
  'en-US' => 'English (US)',
  'de' => 'Deutsch',
  'es' => 'Español',
  'fr' => 'Française',
  'it' => 'Italiano',
  'nb' => 'Norsk bokmål',
  'pt' => 'Português',
  'pt-BR' => 'Português (Brasil)',
  'ru' => 'Русский',
  'tr' => 'Türkçe',
  'sv' => 'Svenska',
  'zh' => '中文 (简体)',
  'zh-Hant' => '中文（繁體)',
  // Websites with names for expanding when new languages get added:
  // - https://chronoplexsoftware.com/localisation/help/languagecodes.htm
  // - https://localizely.com/locale-code/zh-Hans/
  //
  // Names should be modified so they start with an upper case letter.
  //
  (_) => (){
    debugPrint('Unlocalized language tag: $l');
    debugPrintStack();
    assert(false, 'Should only be called for localized strings and all '
        'localized strings are tested.');
    return l.languageCode;
  }()
};

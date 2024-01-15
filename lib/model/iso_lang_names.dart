import 'package:flutter/material.dart';

/// Selects the correct language name for a specific language code.
///
/// Does not account for dialects.
String? getDisplayLanguage(Locale l) => switch(l.toLanguageTag()) {
  'en' => 'English',
  'en-US' => 'English (US)',
  'de' => 'Deutsch',
  'fr' => 'française',
  'it' => 'Italiano',
  'nb' => 'Norsk bokmål',
  'pt' => 'Português',
  'pt-BR' => 'português (Brasil)',
  'ru' => 'русский',
  'tr' => 'Türkçe',
  'zh' => '中文 (简体)',
  'zh-Hant' => '中文（繁體)',
  (_) => (){
    assert(false, l.toString());
    return l.languageCode;
  }()
};

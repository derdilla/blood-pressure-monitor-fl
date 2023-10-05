/// This file hosts interfaces with attributes that different settings classes provide.


abstract class CustomFieldsSettings {
  bool get exportCustomFields;
  set exportCustomFields(bool value);
  List<String> get customFields;
  set customFields(List<String> value);
}
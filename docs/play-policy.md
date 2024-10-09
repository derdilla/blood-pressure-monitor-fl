# Google play policy

This document provides an overview of Information provided to google in the Google Play console

## Health apps declaration

All health related app features in the play console checklist:

- Activity and Fitness
- Diseases and conditions management
- Medical device apps
- Medication and pain management

Every x updates google play starts to randomly question the Health apps declaration. Here are explanations for declared categories and some explanations for (evidently) arguable non-declared categories to appeal (needs to stay bellow 1000 characters):
```yml
Reasoning behind declarations:
- Activity and Fitness: can track weight, pulse
- Diseases and conditions management: tracks Blood pressure value
- Medical device apps: Can connect to ble gatt compatible bluetooth blood pressure measurement devices
- Medication and pain management: optional medicine intake input

Reasoning non-declaration:
- Clinical decision support: only a diary, no recommendations
- Healthcare Services and Management: not associated with any particular health care provider
```

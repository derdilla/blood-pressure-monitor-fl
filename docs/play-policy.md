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

## Health connect rationale
The app stores measurements on device in the app. Users that want to automatically make this data available to other apps can do so by going to:

Settings > Health Connect

There they can:
1. Enable Health Connect
2. Sync historic data

### Blood pressure permissions
As the app name suggest blood pressure record management is a core feature of the app. The blood pressure permission is necessary in case users want to automatically make this data available to other apps.

They can do so by going to Settings > "Health Connect" and enabling it and then pressing Sync now in the "Blood pressure" section of that screen.

The read permission is required so that data saved by other apps can be displayed in the graph and list on the apps home screen. The data is also used to create the statistics at App Home > statistics icon. This is available after the sync described earlier.

The write permission is required to make taken measurements available to other apps. The app allows saving measurements manually (via App Home > Plus icon > SAVE) and when received through any compatible Bluetooth device. If "Automatically sync data" is enabled in the health connect settings, the app will now add these measurements to health connect.

### Weight permission
The user can enable an additional weight input by going to Settings > "Features" > "Activate weight related features".

The health connect weight permission is necessary in case users that want to automatically make this data available to other apps.

They can do so by going to Settings > "Health Connect" and enabling it and then pressing Sync now in the "Weight" section of that screen.

The read permission is needed so that weight entered by other apps can be displayed in the weight tab (scale icon) be on the home screen. Note that this tab is only available after enabling it via Settings > "Features" > "Activate weight related features".

The write permission is needed so that weight can be entered via the weight tab (scale icon) in the add measurement dialog (plus icon on home screen). Note that this tab is only available after enabling it via Settings > "Features" > "Activate weight related features".

### Historic data
The app needs access to historic data in order to display blood pressure trends on the graph at the home screen. To see this:

1. press the dropdown on the home screen that reads "7 days" by default and select "lifetime".
2. Then go to Settings > "Health Connect" and activate "Enable Health Connect"
3. When asked by Android, enable blood pressure read and write.
4. Go to Androids app permission settings. Under additional access enable "Access past data" if you haven't already.
5. Go back to the app
6. In the blood pressure section on the "Health Connect" screen press "Sync now"
7. Go to the apps home screen
8. The graph should now display historic data

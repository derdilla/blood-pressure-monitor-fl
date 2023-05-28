<div align="center">  
  <img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/79b8a2d38703a5ff6d491019ba51b0374c39963a/android/app/src/main/res/drawable/icon.png" width="20%" height="20%"></img>
</div>


<h1 align="center"> blood pressure monitor </h1>
<p align="center">
  <a href="[https://github.com/NobodyForNothing/blood-pressure-monitor-fl/actions/workflows/CI.yml">
    <img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/actions/workflows/CI.yml/badge.svg" alt="CI status" />
  </a>
  <a href"https://github.com/NobodyForNothing/blood-pressure-monitor-fl/releases/latest">
    <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/NobodyForNothing/blood-pressure-monitor-fl">
  </a>
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/NobodyForNothing/blood-pressure-monitor-fl">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/NobodyForNothing/blood-pressure-monitor-fl">
  <img alt="GitHub watchers" src="https://img.shields.io/github/watchers/NobodyForNothing/blood-pressure-monitor-fl">
</div>
<p align="center">
  A cross-platform app to save and analyze blood pressure values and allows easy data export
</p>

Track your blood pressure wherever you go. Offline, ad-free and open source.
This application allows you to easily store your records and export all your records to a CSV file. 

## Getting Started

### Android

#### Play Store
This app is available in the Google [Play Store](https://play.google.com/store/apps/details?id=com.derdilla.bloodPressureApp&hl=en-US&ah=OCOjPuu-d1n3CfovAYWnjcrk1d4). 

Please note that when switching from another installation source, you first need to uninstall the old app before you can get updates. **Making a manual backup is required to avoid data loss.**

#### GitHub
You can download and install the APK directly through the Releases page. Keep in mind that you have to regulary check for new versions manually.

#### Finding and Downloading the "Blood Pressure Monitor" App through Fdroid
Please note that the app is currently only available from the IzzyOnDroid repository due to the review phase of the main repository not being finished.
To find and download the "Blood Pressure Monitor" app from the IzzyOnDroid repository, follow these steps:

1. Download and install the [F-Droid app](https://f-droid.org/en/) App.
2. Once in F-Droid Go to the settings in right bottom drawer and  add the `https://apt.izzysoft.de/fdroid/repo` repository.
3. You can now search and install the "blood pressure monitor" App in F-Droid (You might need to add extra permissions)

### I-OS
While building an ios app would be no problem code wise, apple's restrictive behavior makes this more complicated (and expensive). So I wont take this step unless there is significant demand. 

### Linux
Download the bundle from the releases Page

### Windows and MacOS
Sorry, you need to compile from source. If there is enough demand I can add a windows build.

## Screenshots
<table style="width: 100%; border-collapse: collapse;">
  <tr>
    <td><img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/e685edb9a3835e8b8b5ca27862060715b02d5e8c/screenshots/example_home.png" height="100%" alt="Home"></img></td>
    <td><img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/e685edb9a3835e8b8b5ca27862060715b02d5e8c/screenshots/example_settings.png" height="100%" alt="Settings"></img></td>
    <td><img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/e685edb9a3835e8b8b5ca27862060715b02d5e8c/screenshots/example_stats.png" height="100%" alt="Statistics"></img></td>
    <td><img src="https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/e685edb9a3835e8b8b5ca27862060715b02d5e8c/screenshots/example_add.png" height="100%" alt="Add"></img></td>
  </tr>
</table>

## TODO:

- [X] add to f-droid (currently in extra repo)
- [X] add to play store (open test)
- [X] import from CSV
- [X] edit/delete entries in app
- [X] ensure that no data loss can occur during version changes


# Contributing

This repository has become quite large, so contributions are greatly appreciated and can come in many forms.

<div align="center">
<img src="https://tokei.rs/b1/github/NobodyForNothing/blood-pressure-monitor-fl?style=flat-square">
<img src="https://tokei.rs/b1/github/NobodyForNothing/blood-pressure-monitor-fl?category=code&style=flat-square">
<img src="https://tokei.rs/b1/github/NobodyForNothing/blood-pressure-monitor-fl?category=comments&style=flat-square">
</div>

*Please note that when contributing you agree that your work is under the same license as the project.*

## Opening bugs and proposing features

This is probably the simplest to do: Use the app and find out what's wrong and what can be improved. There is no such thing as a wrong issue. Just make sure there is no existing one about the exact same topic If you are unsure about something just create a new issue, the worst thing to happen is that it gets closed.

## Improving texts and translating
Another easy way to help is to go through the texts (this one or the ones in the app) and fix grammar/other mistakes or find better (more precise/friendly) ways to put things.
The easiest way to do this is [weblate](https://hosted.weblate.org/engage/blood-pressure-monitor-fl/).

[![Translation status](https://hosted.weblate.org/widgets/blood-pressure-monitor-fl/-/multi-auto.svg)](https://hosted.weblate.org/engage/blood-pressure-monitor-fl/)


## Coding
Since this is *FOSS*, you can compile the app yourself and adjust it for you own needs and give back those changes so everyone can profit.

We try to keep the code as documented, simple and maintainable as possible, so you won't need to learn the entire codebase. Additional information about data formats and code style suggestions can be found in the [docs](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/tree/main/docs) folder.

To build the app locally you have to:
1. [set up](https://docs.flutter.dev/get-started/install) flutter
2. `git clone https://github.com/NobodyForNothing/blood-pressure-monitor-fl.git`
3. run `dart run build_runner build` in the `health_data_store` directory

After this initial setup you can:
- Test the app: `flutter run --flavor github`
- Compile the app `flutter build apk --flavor github --release`

### Pull requests
If you can fix issues or implement features from the issues page feel free to make a PR on GitHub with your changes. While not a strict requirement, it is recommended to talk about it in an issue first.

### Platform-support
I'm looking for people who want to bring this app to many more users on IOS or desktop. If you can test there or can publish apps just email me or open an issue, so we can sort out the details! 

## Donations
If you have too much money, I would advise you to donate to either [F-Droid](https://f-droid.org/en/donate/), [Weblate](https://weblate.org/en/donate/), or some other service that has unavoidable maintenance costs.
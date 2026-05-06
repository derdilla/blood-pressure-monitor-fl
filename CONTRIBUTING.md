# Contributing

This repository has become quite large, so contributions are greatly appreciated and can come in many forms.

*Please note that when contributing you agree that your work is under the same license as the project.*

## Opening bugs and proposing features

This is probably the simplest to do: Use the app and find out what's wrong and what can be improved. There is no such thing as a wrong issue. Just make sure there is no existing one about the exact same topic. If you are unsure about something just create a new issue, the worst thing to happen is that it gets closed.

## Improving texts and translating

Another easy way to help is to go through the texts (this one, store listings or the ones in the app) and fix grammar, punctuation, or other mistakes.

The [weblate](https://hosted.weblate.org/engage/blood-pressure-monitor-fl/) contributions are currently broken. If you are interested in fixing them, please reach out. For now, you can just open a Pull Request files in `/app/lib/l10n` or submit them through some other channel like E-Mail.

## Coding

Since this is *FOSS*, you can compile the app yourself and adjust it for you own needs and give back those changes so everyone can profit.

We try to keep the code as documented, simple and maintainable as possible, so you won't need to learn the entire codebase. Additional information about data formats and code style suggestions can be found in the [docs](https://github.com/derdilla/blood-pressure-monitor-fl/tree/main/docs) folder.

To build the app locally you have to:
1. [set up](https://docs.flutter.dev/get-started/install) flutter
2. `git clone https://github.com/derdilla/blood-pressure-monitor-fl.git`
3. run `dart run build_runner build` in the `health_data_store` directory
4. run `dart run build_runner build` in the `app` directory

After this initial setup you can:
- Test the app: `flutter run --flavor github` to run the app locally or on devices attached via adb
- Compile the app `flutter build apk --flavor github`
  - For Android release builds (`--release`), you need to [configure a signing key](https://docs.flutter.dev/deployment/android#sign-the-app).

Once you change a file with the `@GenerateSettings` annotation, rebuild the settings:
`dart run build_runner build --build-filter="lib/model/storage/*.dart"`

### Pull requests

If you can fix issues or implement features from the issues page feel free to make a PR on GitHub with your changes. While not a strict requirement, it is recommended to talk about it in an issue first.

- If you have any questions on the codebase, just open a discussion
- For [all the right reasons](https://en.wikipedia.org/wiki/Large_language_model#Societal_concerns) we don't accept AI (LLM) generated contributions

### Platform-support

I'm looking for people who want to bring this app to many more users on IOS or desktop. If you can test there or can publish apps just email me or open an issue, so we can sort out the details! 

## Donations

If you sponsor [me](https://github.com/derdilla), I may be more motivated to work on this, seeing that people actually care enough to pay for it.

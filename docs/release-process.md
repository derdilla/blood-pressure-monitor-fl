*developer documentation - users can safely ignore this*

## App release checklist

- [ ] no remaining breaking issues
- [ ] Write changelog and wait ~1 week if possible
- [ ] add translation from [Weblate](https://hosted.weblate.org/projects/blood-pressure-monitor-fl/#repository)
- [ ] in case new languages got added, add them to `iso_lang_names.dart`
- [ ] Run tools/release_tool
- [ ] Manuall release testing: upgrading data and core features
- [ ] make Play release and create a GitHub release containing APK and debug symbols

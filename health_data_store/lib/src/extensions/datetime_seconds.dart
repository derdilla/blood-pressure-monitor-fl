/// Add the ability to interact with the original seconds based unix timestamp.
extension DateTimeS on DateTime {
  /// The number of seconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  /// Constructs a new DateTime instance with the given [secondsSinceEpoch].
  static DateTime fromSecondsSinceEpoch(int secondsSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
}

int timeToInt(DateTime dateTime) {
  return (dateTime.millisecondsSinceEpoch / (1000 * 60 * 60 * 24)).round();
}
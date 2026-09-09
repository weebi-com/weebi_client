/// Next free positive integer id given already used ids.
int nextPositiveId(Iterable<int> existingIds) {
  var maxId = 0;
  for (final id in existingIds) {
    if (id > maxId) maxId = id;
  }
  return maxId + 1;
}

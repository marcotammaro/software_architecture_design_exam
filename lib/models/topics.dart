enum Topics {
  football,
  cooking,
  sport,
  job,
  technology,
  cinema,
  art,
  medicine,
  beer,
  tv
}

extension TopicsHelper on Topics {
  int toInt() {
    return this.index;
  }

  static Topics fromInt(int index) {
    if (index == null) return null;
    return Topics.values[index];
  }
}

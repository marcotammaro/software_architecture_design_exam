class Notification {
  int key;
  String text;
  String from;
  DateTime datetime;
  String lobbyName;
  Notification({this.key, this.lobbyName, this.text, this.from, this.datetime});

  @override
  String toString() {
    // TODO: implement toString
    return "${this.key}, From: ${this.from}, In: ${this.lobbyName}, Text: ${this.text}, Schedule: ${this.datetime}";
  }
}

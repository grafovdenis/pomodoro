class Activity {
  String title;
  int duration;
  String startedAt;
  bool completed;

  Activity(String title, int duration, String startedAt, bool completed) {
    this.title = title;
    this.duration = duration;
    this.startedAt = startedAt;
    this.completed = completed;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'duration': duration,
        'startedAt': startedAt,
        'completed': completed
      };

  String toString() =>
      "{\"title\":\"$title\",\"duration\":$duration,\"startedAt\":\"$startedAt\",\"completed\":$completed}";
}

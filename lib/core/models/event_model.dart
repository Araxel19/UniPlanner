class Event {
  final int id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String? description;
  final int userId;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.userId,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      description: map['description'],
      userId: map['userId'],
    );
  }
}

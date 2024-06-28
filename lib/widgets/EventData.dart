class EventData {
  final String title;
  final String image;
  final String category;
  final String date;
  final String description;
  final String urlAddress;

  EventData({
    required this.title,
    required this.image,
    required this.category,
    required this.date,
    required this.description,
    required this.urlAddress,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
        title: json['title'],
        image: json['image'],
        category: json['category'],
        date: json['date'],
        description: json['description'],
        urlAddress: json['urlAddress']);
  }
}

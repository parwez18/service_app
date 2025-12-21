class ServiceItem {
  final String name;
  final String duration;
  final int price;

  ServiceItem({
    required this.name,
    required this.duration,
    required this.price,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      name: map['name'] ?? '',
      duration: map['duration'] ?? '',
      price: (map['price'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'duration': duration, 'price': price};
  }
}

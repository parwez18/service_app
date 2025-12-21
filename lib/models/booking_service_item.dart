class BookingServiceItem {
  final String name;
  final String duration;
  final int price;

  BookingServiceItem({
    required this.name,
    required this.duration,
    required this.price,
  });

  factory BookingServiceItem.fromMap(Map<String, dynamic> map) {
    return BookingServiceItem(
      name: map['name'],
      duration: map['duration'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'duration': duration, 'price': price};
  }
}

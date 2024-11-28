class OrderPlan {
  final int? id;
  final String date;
  final String foodItems;
  final double totalCost;

  OrderPlan({
    this.id,
    required this.date,
    required this.foodItems,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'food_items': foodItems,
      'total_cost': totalCost,
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'],
      date: map['date'],
      foodItems: map['food_items'],
      totalCost: map['total_cost'],
    );
  }
}

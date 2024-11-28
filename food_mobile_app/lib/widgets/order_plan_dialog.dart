import 'package:flutter/material.dart';
import '../models/order_plan.dart';

class OrderPlanDialog extends StatelessWidget {
  final OrderPlan orderPlan;

  const OrderPlanDialog({Key? key, required this.orderPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Order Plan for ${orderPlan.date}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items:\n${orderPlan.foodItems}'),
          const SizedBox(height: 16),
          Text('Total Cost: \$${orderPlan.totalCost.toStringAsFixed(2)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

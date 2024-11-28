import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import '../widgets/add_food_dialog.dart';
import '../widgets/update_food_dialog.dart';
import '../widgets/order_plan_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime selectedDate = DateTime.now();
  double targetCost = 0.0;
  List<FoodItem> foodItems = [];
  List<FoodItem> selectedItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await _dbHelper.getFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _showAddFoodDialog(BuildContext context) async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => const AddFoodDialog(),
    );

    if (result != null) {
      await _dbHelper.addFoodItem(result);
      _loadFoodItems();
    }
  }

  Future<void> _showUpdateFoodDialog(BuildContext context, FoodItem item) async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => UpdateFoodDialog(foodItem: item),
    );

    if (result != null) {
      await _dbHelper.updateFoodItem(result);
      _loadFoodItems();
    }
  }

  Future<void> _deleteFoodItem(int? id) async {
    if (id != null) {
      await _dbHelper.deleteFoodItem(id);
      _loadFoodItems();
    }
  }

  Future<void> _saveOrderPlan(BuildContext context) async {
    double totalCost = selectedItems.fold(0.0, (sum, item) => sum + item.cost);
    
    if (targetCost > 0 && totalCost > targetCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total cost exceeds target cost!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final orderPlan = OrderPlan(
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      foodItems: selectedItems.map((item) => '${item.name} (\$${item.cost})').join(', '),
      totalCost: totalCost,
    );

    await _dbHelper.saveOrderPlan(orderPlan);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan saved successfully!')),
    );
  }

  Future<void> _queryOrderPlan(BuildContext context) async {
    final orderPlan = await _dbHelper.getOrderPlanByDate(
      DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    if (orderPlan != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => OrderPlanDialog(orderPlan: orderPlan),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No order plan found for selected date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFoodDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Target Cost per Day',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            targetCost = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _queryOrderPlan(context),
                  child: const Text('Query Order Plan'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                final isSelected = selectedItems.contains(item);
                
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUpdateFoodDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFoodItem(item.id),
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedItems.add(item);
                            } else {
                              selectedItems.remove(item);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total Selected: \$${selectedItems.fold(0.0, (sum, item) => sum + item.cost).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: selectedItems.isEmpty ? null : () => _saveOrderPlan(context),
                  child: const Text('Save Order Plan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
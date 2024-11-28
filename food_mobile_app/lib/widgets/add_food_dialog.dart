import 'package:flutter/material.dart';
import '../models/food_item.dart';

class AddFoodDialog extends StatefulWidget {
  const AddFoodDialog({Key? key}) : super(key: key);

  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Food Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _costController,
            decoration: const InputDecoration(labelText: 'Cost'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _costController.text.isNotEmpty) {
              final foodItem = FoodItem(
                name: _nameController.text,
                cost: double.parse(_costController.text),
              );
              Navigator.pop(context, foodItem);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../models/food_item.dart';

class UpdateFoodDialog extends StatefulWidget {
  final FoodItem foodItem;

  const UpdateFoodDialog({Key? key, required this.foodItem}) : super(key: key);

  @override
  _UpdateFoodDialogState createState() => _UpdateFoodDialogState();
}

class _UpdateFoodDialogState extends State<UpdateFoodDialog> {
  late TextEditingController _nameController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem.name);
    _costController = TextEditingController(text: widget.foodItem.cost.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Food Item'),
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
              final updatedItem = FoodItem(
                id: widget.foodItem.id,
                name: _nameController.text,
                cost: double.parse(_costController.text),
              );
              Navigator.pop(context, updatedItem);
            }
          },
          child: const Text('Update'),
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

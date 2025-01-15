import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({Key? key}) : super(key: key);

  @override
  _AddTaskWidgetState createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _priority = 'Medium';
  DateTime _startDate = DateTime.now();
  List<bool> _selectedDays = List.filled(7, false);

  void _submitTask(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newTask = Task(
        name: _name,
        description: _description,
        completed: false,
        priority: _priority,
        startDate: _startDate,
        selectedDays: Task.daysToBinary(
          List.generate(7, (index) => index).where((i) => _selectedDays[i]).toList(),
        ),
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _selectedDays = List.filled(7, false);
        });
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Add Task'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Task Name'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Task name is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _name = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Description'),
                            onSaved: (value) {
                              _description = value ?? '';
                            },
                          ),
                          DropdownButtonFormField<String>(
                            value: _priority,
                            items: ['Low', 'Medium', 'High']
                                .map((priority) => DropdownMenuItem(
                                      value: priority,
                                      child: Text(priority),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                            decoration: const InputDecoration(labelText: 'Priority'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Start Date:'),
                              TextButton(
                                onPressed: () => _pickStartDate(context),
                                child: Text(
                                  '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 10,
                            children: List.generate(7, (index) {
                              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              return FilterChip(
                                label: Text(days[index]),
                                selected: _selectedDays[index],
                                onSelected: (isSelected) {
                                  setState(() {
                                    _selectedDays[index] = !_selectedDays[index];
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => _submitTask(context),
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

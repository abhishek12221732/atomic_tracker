import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _priority;
  late DateTime _startDate;
  late List<bool> _selectedDays;

  @override
  void initState() {
  super.initState();
  _name = widget.task.name;
  _description = widget.task.description;
  _priority = widget.task.priority;
  _startDate = widget.task.startDate;

  // Use binaryToBooleanList for correct initialization
  _selectedDays = Task.binaryToBooleanList(widget.task.selectedDays);
  print('Initialized selectedDays (boolean): $_selectedDays');
}

  void _updateTask(BuildContext context) {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    final updatedTask = widget.task.copyWith(
      name: _name,
      description: _description,
      priority: _priority,
      startDate: _startDate,
      selectedDays: Task.booleanListToBinary(_selectedDays),
    );
    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
    Navigator.of(context).pop();
  }
}


  void _deleteTask(BuildContext context) {
    if (widget.task.id != null) {
      Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.task.id!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name ?? 'Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTask(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Task name is required' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Low', 'Medium', 'High']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value!),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Date:'),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => _startDate = pickedDate);
                      }
                    },
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
                        _selectedDays[index] = isSelected;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateTask(context),
                child: const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

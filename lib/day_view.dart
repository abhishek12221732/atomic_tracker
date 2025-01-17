import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class DayView extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const DayView({required this.onDaySelected});

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final ScrollController _scrollController = ScrollController();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 182)); // 6 months back
  late DateTime _selectedDate;
  late double _itemWidth;

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalizeDate(DateTime.now()); // Normalize the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCurrentDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Normalize a date to remove time components
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _centerCurrentDate() {
    // Calculate the index of the current date
    final initialIndex = _selectedDate.difference(_startDate).inDays + 1;

    // Scroll to the position to center the current date
    final offset =
        (initialIndex * _itemWidth) - (MediaQuery.of(context).size.width / 2 - _itemWidth / 2);
    _scrollController.jumpTo(offset);

    // Invoke onDaySelected immediately to set the current date as selected
    widget.onDaySelected(_selectedDate);
  }

  void _onDayTap(int index) async{
    final tappedDate = _normalizeDate(_startDate.add(Duration(days: index)));
    await DatabaseHelper.instance.fillTaskCompletionTableForDate(tappedDate);
    setState(() {
      _selectedDate = tappedDate;
    });
    widget.onDaySelected(_selectedDate);

    // Smoothly center the tapped date
    final offset = (index * _itemWidth) - (MediaQuery.of(context).size.width / 2 - _itemWidth / 2);
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    _itemWidth = MediaQuery.of(context).size.width / 7; // Display 7 days at a time

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 365, // One year of dates
        itemBuilder: (context, index) {
          final date = _normalizeDate(_startDate.add(Duration(days: index)));
          final isSelected = date == _selectedDate; // Proper comparison using normalized dates

          return GestureDetector(
            onTap: () => _onDayTap(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: _itemWidth,
              margin: EdgeInsets.symmetric(vertical: isSelected ? 10 : 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date), // Day abbreviation
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date), // Day number
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

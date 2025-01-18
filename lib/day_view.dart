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

  // Normalize the current date
  _selectedDate = _normalizeDate(DateTime.now());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Calculate the index of today's date relative to the start date
    final initialIndex = DateTime.now().difference(_startDate).inDays;

    // Use _onDayTap to handle the initial selection and centering
    _onDayTap(initialIndex);
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

//   void _centerCurrentDate() {
//   // Calculate the index of the current date
//   final initialIndex = _selectedDate.difference(_startDate).inDays;

//   // Ensure the scroll position is within valid bounds
//   final double maxScrollExtent = 365 * _itemWidth; // Adjust for total item count
//   final double minScrollExtent = 0.0; // Ensure this is a double

//   // Calculate the target offset
//   double targetOffset =
//       (initialIndex * _itemWidth) - (MediaQuery.of(context).size.width / 2 - _itemWidth / 2);

//   // Clamp the offset to ensure it stays within bounds
//   targetOffset = targetOffset.clamp(minScrollExtent, maxScrollExtent);

//   // Jump to the calculated offset
//   _scrollController.jumpTo(targetOffset);

//   // Notify the selected date
//   widget.onDaySelected(_selectedDate);
// }



  void _onDayTap(int index) async {
  final tappedDate = _normalizeDate(_startDate.add(Duration(days: index)));
  await DatabaseHelper.instance.fillTaskCompletionTableForDate(tappedDate);
  setState(() {
    _selectedDate = tappedDate; // Update the selected date
  });
  widget.onDaySelected(_selectedDate); // Notify parent

  // Center the tapped date
  final offset = (index * _itemWidth) -
      (MediaQuery.of(context).size.width / 2 - _itemWidth / 2);

  _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
}


  @override
  Widget build(BuildContext context) {
   _itemWidth = MediaQuery.of(context).size.width > 0
    ? MediaQuery.of(context).size.width / 7
    : 50.0; // Fallback width

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

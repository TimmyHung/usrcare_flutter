import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CheckInPage extends StatefulWidget {
  final Set<String> checkinDates;

  const CheckInPage({super.key, required this.checkinDates});

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  late Set<String> _markedDates;

  @override
  void initState() {
    super.initState();
    _markedDates = widget.checkinDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 240),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/HomePage_Icons/sign.png", height: 50),
              const SizedBox(width: 10),
              const Text("簽簽樂")
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black38)
              ),
              child: TableCalendar(
                locale: "zh_TW",
                firstDay: DateTime.utc(2019, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                ),
                daysOfWeekHeight: 30,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                  ),
                  weekendStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                  ),
                  dowTextFormatter: (date, locale) {
                    return DateFormat.E(locale).format(date).substring(1); // 只顯示「日、一、二」等
                  },
                ),
                calendarStyle: CalendarStyle(
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  defaultTextStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                  selectedTextStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.white
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  outsideDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  outsideTextStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  cellMargin: const EdgeInsets.all(2.0),
                ),
                rowHeight: 52.0,
                selectedDayPredicate: (day) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(day);
                  return _markedDates.contains(formattedDate);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late Map<DateTime, List<Event>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Normalize dates in the events map
    _events = {
      DateTime(2025, 3, 7): [Event('Ramadan', Colors.green)],
      DateTime(2025, 3, 14): [Event('Holika Dahan', Colors.orange)],
      DateTime(2025, 3, 14): [Event('Holika', Colors.orange)],
      DateTime(2025, 3, 15): [Event('Zephyr', Colors.blue)],
      DateTime(2025, 3, 20): [Event('Holi', Colors.purple)],
      DateTime(2025, 3, 31): [Event('Eid al-Fitr', Colors.teal)],
    };
  }

  // Ensure the date is normalized before fetching events
  List<Event> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Calendar Widget
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 2.0),
                ),
              ],
            ),
            child: TableCalendar<Event>(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                // Customize event markers
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
                markersMaxCount: 2,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.black54),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.black54),
                titleTextStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              calendarBuilders: CalendarBuilders(
                // Display events as text on the calendar
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        events.first.title,
                        style: TextStyle(
                          fontSize: 10,
                          color: events.first.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),

          // Event List
          const SizedBox(height: 10), // Add some spacing
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 2.0),
                  )
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _getEventsForDay(_selectedDay).length,
                itemBuilder: (context, index) {
                  final event = _getEventsForDay(_selectedDay)[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: event.color,
                        radius: 8,
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Event Model
class Event {
  final String title;
  final Color color;

  Event(this.title, this.color);

  @override
  String toString() => title;
}

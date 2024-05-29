import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/todo_provider.dart';
//import 'package:todo/widgets/tasks.dart';
import 'package:table_calendar/table_calendar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: TodoProvider(),
      child: MaterialApp(
      title: 'Calendrier avec Événements',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Todo app'),
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController newTaskController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, List<Map<String, String>>> _events = {};
  Map<String, String> newEvent = {
  'name': '',
  'start': '',
  'end': '',
  'location': '',
  'description': ''
};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Calendrier avec Événements'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color.fromARGB(255, 177, 230, 255),
      body: Row(
        children: [
          // Column for the calendar
          Expanded(
            flex: 1,
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  calendarFormat: _calendarFormat,
                  
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return _events[day] ?? [];
                  },
                ),
              ],
            ),
          ),
          // Column for the button and events list
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                if (_selectedDay != null)
                  ElevatedButton(  
                    onPressed: () => _showAddEventDialog(_selectedDay!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[200],
                    ),
                    child: 
                      const Text('Ajouter un événement'),
                  ),
                const SizedBox(height: 8.0),
                _selectedDay != null && _events[_selectedDay] != null
                    ? Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _events[_selectedDay]!
                              .map((event) => GestureDetector(
                                    onTap: () => _showEventDetailsDialog(event, _selectedDay!),
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: 150,
                                        //color: Colors.pink[00],
                                        decoration: BoxDecoration(
                                          color: Colors.pink[100],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['name']!,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text('Heure: ${event['start']} - ${event['end']}'),
                                            Text('Lieu: ${event['location']}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(DateTime selectedDay, {Map<String, String>? event, int? index}) {
    TextEditingController nameController = TextEditingController(text: event?['name'] ?? '');
    TextEditingController startController = TextEditingController(text: event?['start'] ?? '');
    TextEditingController endController = TextEditingController(text: event?['end'] ?? '');
    TextEditingController locationController = TextEditingController(text: event?['location'] ?? '');
    TextEditingController descriptionController = TextEditingController(text: event?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        title: Text(event == null ? 'Ajouter un événement' : 'Modifier un événement'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                ),
              ),
              TextField(
                controller: startController,
                decoration: const InputDecoration(
                  labelText: 'Heure de début (HH:mm)',
                ),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    startController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: endController,
                decoration: const InputDecoration(
                  labelText: 'Heure de fin (HH:mm)',
                ),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    endController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  startController.text.isEmpty ||
                  endController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                return;
              }
              setState(() {
                newEvent = {
                  'name': nameController.text,
                  'start': startController.text,
                  'end': endController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                };
              });
              Navigator.pop(context);
              Provider.of<TodoProvider>(context, listen: false).addTodo(newEvent);
              newTaskController.clear();
            },
            child: Text(event == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showEventDetailsDialog(Map<String, String> event, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        title: Text(event['name']!),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Heure: ${event['start']} - ${event['end']}'),
            Text('Lieu: ${event['location']}'),
            Text('Description: ${event['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              int index = _events[selectedDay]!.indexOf(event);
              _showAddEventDialog(selectedDay, event: event, index: index);
            },
            child: const Text('Modifier'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _events[selectedDay]!.remove(event);
                if (_events[selectedDay]!.isEmpty) {
                  _events.remove(selectedDay);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
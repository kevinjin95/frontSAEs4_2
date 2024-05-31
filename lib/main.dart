import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/todo_provider.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        title: 'Calendrier avec Événements',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Todo app'),
      ),
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
  // final Map<DateTime, List<Map<String, String>>> _events = {};
  Map<String, String> newEvent = {
  'name': '',
  'start': '',
  'end': '',
  'location': '',
  'description': ''
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).getTodos2(_focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color.fromARGB(255, 177, 230, 255),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Column for the calendar
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: TableCalendar(
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
                            Provider.of<TodoProvider>(context, listen: false).getTodos2(selectedDay);
                            },
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: true,
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(5.0),
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ElevatedButton(
                          onPressed: () => _showAddEventDialog(_selectedDay!),
                            
                          child: const Text('Ajouter un évènement'),
                          
                        ),
                      ),
                    ],
                  ),
                ),
                // Column for the events
                Expanded(
                  flex: 1,
                  child: Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      var eventsForSelectedDay = todoProvider.items.where((item) {
                        return isSameDay(_selectedDay, _selectedDay);
                      }).toList();
                      return _selectedDay == null
                          ? Center(child: Text('Sélectionnez une date pour voir les événements'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Événements pour ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: eventsForSelectedDay.length,
                                    itemBuilder: (context, index) {
                                      var event = eventsForSelectedDay[index];
                                      return Card(
                                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          title: Text(event.eventName),
                                          subtitle: Text(
                                              '${event.eventStart} - ${event.eventEnd}\n${event.eventLocation}\n${event.eventDescription}'),
                                          trailing: Icon(Icons.event),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ),
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
}
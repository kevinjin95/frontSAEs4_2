import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/todo_provider.dart';
import 'package:todo/widgets/tasks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo/models/todo_item.dart'; // Modele des taches

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendrier avec Événements',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendrier avec Événements'),
      ),
      body: Row(
        children: [
          // Column for the calendar
          Expanded(
            flex: 2,
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
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          final eventList = events.cast<Map<String, String>>();
                          return Column(
                            children: eventList
                                .map((event) => Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        event['title']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }
                        return null;
                      },
                      selectedBuilder: (context, date, _) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                    child: Text('Ajouter un événement'),
                  ),
                const SizedBox(height: 8.0),
                _selectedDay != null && _events[_selectedDay] != null
                    ? Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _events[_selectedDay]!
                              .map((event) => GestureDetector(
                                    onTap: () => _showEventDetailsDialog(event, _selectedDay!),
                                    child: Card(
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        width: 150,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['title']!,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 4.0),
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
    TextEditingController _titleController = TextEditingController(text: event?['title'] ?? '');
    TextEditingController _startController = TextEditingController(text: event?['start'] ?? '');
    TextEditingController _endController = TextEditingController(text: event?['end'] ?? '');
    TextEditingController _locationController = TextEditingController(text: event?['location'] ?? '');
    TextEditingController _descriptionController = TextEditingController(text: event?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Ajouter un événement' : 'Modifier un événement'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                ),
              ),
              TextField(
                controller: _startController,
                decoration: InputDecoration(
                  labelText: 'Heure de début (HH:mm)',
                ),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _startController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: 'Heure de fin (HH:mm)',
                ),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _endController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lieu',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
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
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.isEmpty ||
                  _startController.text.isEmpty ||
                  _endController.text.isEmpty ||
                  _locationController.text.isEmpty ||
                  _descriptionController.text.isEmpty) {
                return;
              }

              setState(() {
                final newEvent = {
                  'title': _titleController.text,
                  'start': _startController.text,
                  'end': _endController.text,
                  'location': _locationController.text,
                  'description': _descriptionController.text,
                };

                if (event != null && index != null) {
                  // Modifier l'événement existant
                  _events[selectedDay]![index] = newEvent;
                } else {
                  // Ajouter un nouvel événement
                  if (_events[selectedDay] != null) {
                    _events[selectedDay]!.add(newEvent);
                  } else {
                    _events[selectedDay] = [newEvent];
                  }
                }
              });

              Navigator.pop(context);
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
        title: Text(event['title']!),
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
            child: Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              int index = _events[selectedDay]!.indexOf(event);
              _showAddEventDialog(selectedDay, event: event, index: index);
            },
            child: Text('Modifier'),
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
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//         value: TodoProvider(),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//       title: 'Calendrier avec Événements',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Todo app'),
//       )
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController newTaskController = TextEditingController();
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime? _selectedDay;
//   DateTime _focusedDay = DateTime.now();
//   final Map<DateTime, List<Map<String, String>>> _events = {};
//   Map<String, String> newEvent = {
//   'name': '',
//   'start': '',
//   'end': '',
//   'location': '',
//   'description': ''
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: const Text('Calendrier avec Événements'),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       backgroundColor: const Color.fromARGB(255, 177, 230, 255),
//       body: Row(
//         children: [
//           //Column for the calendar
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 TableCalendar(
//                   focusedDay: _focusedDay,
//                   firstDay: DateTime(2020),
//                   lastDay: DateTime(2030),
//                   calendarFormat: _calendarFormat,
                  
//                   selectedDayPredicate: (day) {
//                     return isSameDay(_selectedDay, day);
//                   },
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay;
//                     });
//                   },
//                   onFormatChanged: (format) {
//                     if (_calendarFormat != format) {
//                       setState(() {
//                         _calendarFormat = format;
//                       });
//                     }
//                   },
//                   onPageChanged: (focusedDay) {
//                     _focusedDay = focusedDay;
//                   },
//                   eventLoader: (day) {
//                     return _events[day] ?? [];
//                   },
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     onPressed: _selectedDay == null
//                       ? null
//                       : () {
//                           // Logique pour ajouter un événement
//                         },
//                       child: const Text('Ajouter un évènement'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
          
//           //Column for the button and events list
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 const SizedBox(height: 8.0),
//                 if (_selectedDay != null)
//                   ElevatedButton(  
//                     onPressed: () => _showAddEventDialog(_selectedDay!),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.yellow[200],
//                     ),
//                     child: 
//                       const Text('Ajouter un événement'),
//                   ),
//                 _selectedDay != null && _events[_selectedDay] != null
//                   ? Expanded(
//                     child: Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 8.0,
//                       runSpacing: 8.0,
//                       children: _events[_selectedDay]!
//                         .map((event) => GestureDetector(
//                             onTap: () => _showEventDetailsDialog(event, _selectedDay!),
//                             child: Card(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8.0),
//                                 width: 150,
//                                 color: Colors.pink[00],
//                                 decoration: BoxDecoration(
//                                   color: Colors.pink[100],
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       event['name']!,
//                                       style: const TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     const SizedBox(height: 4.0),
//                                     Text('Heure: ${event['start']} - ${event['end']}'),
//                                     Text('Lieu: ${event['location']}'),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                         )).toList(),
//                     ),
//                 ): Container(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     )
  
//   @override
//   void _showAddEventDialog(DateTime selectedDay, {Map<String, String>? event, int? index}) {
//     TextEditingController nameController = TextEditingController(text: event?['name'] ?? '');
//     TextEditingController startController = TextEditingController(text: event?['start'] ?? '');
//     TextEditingController endController = TextEditingController(text: event?['end'] ?? '');
//     TextEditingController locationController = TextEditingController(text: event?['location'] ?? '');
//     TextEditingController descriptionController = TextEditingController(text: event?['description'] ?? '');
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.green[100],
//         title: Text(event == null ? 'Ajouter un événement' : 'Modifier un événement'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Titre',
//                 ),
//               ),
//               TextField(
//                 controller: startController,
//                 decoration: const InputDecoration(
//                   labelText: 'Heure de début (HH:mm)',
//                 ),
//                 onTap: () async {
//                   TimeOfDay? time = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (time != null) {
//                     startController.text = time.format(context);
//                   }
//                 },
//               ),
//               TextField(
//                 controller: endController,
//                 decoration: const InputDecoration(
//                   labelText: 'Heure de fin (HH:mm)',
//                 ),
//                 onTap: () async {
//                   TimeOfDay? time = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (time != null) {
//                     endController.text = time.format(context);
//                   }
//                 },
//               ),
//               TextField(
//                 controller: locationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Lieu',
//                 ),
//               ),
//               TextField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Annuler'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (nameController.text.isEmpty ||
//                   startController.text.isEmpty ||
//                   endController.text.isEmpty ||
//                   locationController.text.isEmpty ||
//                   descriptionController.text.isEmpty) {
//                 return;
//               }
//               setState(() {
//                 newEvent = {
//                   'name': nameController.text,
//                   'start': startController.text,
//                   'end': endController.text,
//                   'location': locationController.text,
//                   'description': descriptionController.text,
//                 };
//               });
//               Navigator.pop(context);
//               Provider.of<TodoProvider>(context, listen: false).addTodo(newEvent);
//               newTaskController.clear();
//             },
//             child: Text(event == null ? 'Ajouter' : 'Modifier'),
//           ),
//         ],
//       ),
//     );
//   },
// }
//   void _showEventDetailsDialog(Map<String, String> event, DateTime selectedDay) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.green[100],
//         title: Text(event['name']!),
//         content: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Heure: ${event['start']} - ${event['end']}'),
//             Text('Lieu: ${event['location']}'),
//             Text('Description: ${event['description']}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Fermer'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               int index = _events[selectedDay]!.indexOf(event);
//               _showAddEventDialog(selectedDay, event: event, index: index);
//             },
//             child: const Text('Modifier'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _events[selectedDay]!.remove(event);
//                 if (_events[selectedDay]!.isEmpty) {
//                   _events.remove(selectedDay);
//                 }
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Supprimer'),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => TodoProvider(),
//       child: MaterialApp(
//         title: 'Calendrier avec Événements',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const MyHomePage(title: 'Todo app'),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime? _selectedDay;
//   DateTime _focusedDay = DateTime.now();
//   List<TodoItem> _items = [];
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<TodoProvider>(context, listen: false).getTodos2(_focusedDay);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text(widget.title),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       backgroundColor: const Color.fromARGB(255, 177, 230, 255),
//       body: Row(
//         children: [
//           // Column for the calendar
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 TableCalendar(
//                   focusedDay: _focusedDay,
//                   firstDay: DateTime(2020),
//                   lastDay: DateTime(2030),
//                   calendarFormat: _calendarFormat,
//                   selectedDayPredicate: (day) {
//                     return isSameDay(_selectedDay, day);
//                   },
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay;
//                     });
//                     Provider.of<TodoProvider>(context, listen: false).getTodos2(selectedDay);
//                   },
//                   calendarStyle: CalendarStyle(
//                     isTodayHighlighted: true,
//                     selectedDecoration: BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                     ),
//                     todayDecoration: BoxDecoration(
//                       color: Colors.orange,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 if (_selectedDay != null)
//                   ElevatedButton(  
//                     onPressed: () => _showAddEventDialog(_selectedDay!),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.yellow[200],
//                     ),
//                     child: 
//                       const Text('Ajouter un événement'),
//                 ),
//               ],
//             ),
//           ),
//           // Column for the events
//           Expanded(
//             flex: 1,
//             child: Consumer<TodoProvider>(
//               builder: (context, todoProvider, child) {
//                 var eventsForSelectedDay = todoProvider.items.where((item) {
//                   return isSameDay(_selectedDay, _selectedDay);
//                 }).toList();
//                 return _selectedDay == null
//                     ? Center(child: Text('Sélectionnez une date pour voir les événements'))
//                     : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
                            
//                             child: Text(
//                               'Événements pour ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: eventsForSelectedDay.length,
//                               itemBuilder: (context, index) {
//                                 var event = eventsForSelectedDay[index];
//                                 return Card(
//                                   margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                   child: ListTile(
//                                     title: Text(event.eventName),
//                                     subtitle: Text(
//                                         '${event.eventStart} - ${event.eventEnd}\n${event.eventLocation}\n${event.eventDescription}'),
//                                     trailing: Icon(Icons.event),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

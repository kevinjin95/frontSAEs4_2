import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/todo_item.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'In Time',
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(28, 107, 68, 1), // Votre couleur RGB
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              color: Colors.white, // Titre en blanc
              fontSize: 20.0, // Ajoutez cette ligne pour augmenter la taille du titre
            ),
          ),
        ),
        home: const MyHomePage(title: 'Planificateur'),
      ),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Contrôleur pour le champ de texte de la nouvelle tâche
  TextEditingController newTaskController = TextEditingController();

  // Format du calendrier
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  // Jour sélectionné dans le calendrier
  DateTime? _selectedDay;

  // Jour actuellement en focus dans le calendrier
  DateTime _focusedDay = DateTime.now();

  // Nouvel événement à ajouter
  Map<String, dynamic> newEvent = {
    'name': '',
    'start': '',
    'end': '',
    'location': '',
    'description': '',
    'year': 0,
    'month': 0,
    'day': 0,
  };

  // valeur de l'id à supprimer
  int id = 0; 

  List<TodoItem> eventsForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    // Après la construction du widget, on récupère les tâches pour le jour en focus
    Provider.of<TodoProvider>(context, listen: false).addListener(() {
      setState(() {
        eventsForSelectedDay = Provider.of<TodoProvider>(context, listen: false).items.where((item) {
          return isSameDay(_selectedDay, item.date);
        }).toList();
      }); 
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).getTodos(_focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[900],
      ),
      backgroundColor: const Color.fromARGB(235, 186, 231, 217),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Colonne pour le calendrier
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), // Voile transparent blanc cassé
                      borderRadius: BorderRadius.circular(10), // Bord arrondi pour un beau design UI
                      boxShadow: [ // Ombre pour un effet 3D
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          spreadRadius: -2,
                          blurRadius: 18,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(10.0), // Marge autour du conteneur
                    child: Column(
                      children: [
                        Expanded(
                          child: TableCalendar(
                            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                            focusedDay: _focusedDay,
                            firstDay: DateTime(2020),
                            lastDay: DateTime(2030),
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              // Vérifie si le jour est le même que le jour sélectionné
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              // Met à jour le jour sélectionné et le jour en focus
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              // Récupère les tâches pour le jour sélectionné
                              Provider.of<TodoProvider>(context, listen: false).getTodos(selectedDay);
                            },
                            calendarStyle: const CalendarStyle(
                              isTodayHighlighted: true,
                              selectedDecoration: BoxDecoration(
                                color: Color(0xFF66DDAA),
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 51, 105, 30),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            onPressed: () => _showAddEventDialog(_selectedDay!),
                            child: const Text('Ajouter un évènement'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Colonne pour les événements
                Expanded(
                  flex: 1,
                  child: Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      // Récupère les événements pour le jour sélectionné
                      if (kDebugMode) {
                        //print("pomme"); pour tester
                      }
                      return _selectedDay == null
                          ? const Center(child: Text('Sélectionnez une date pour voir les événements'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Événements pour ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: eventsForSelectedDay.length,
                                    itemBuilder: (context, index) {
                                      var event = eventsForSelectedDay[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          title: Text(event.eventName),
                                          subtitle: Text(
                                              '${event.eventStart} - ${event.eventEnd}\n${event.eventLocation}\n${event.eventDescription}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.assignment_add), //icône pour supprimer
                                                onPressed: () => _showEditEventDialog(_selectedDay!, event),
                                                  //todoProvider.deleteTodo(event.id);
                                                  // setState(() {
                                                  //   id = event.id;
                                                  //   }); //pour déclencher la reconstruction du widget on le fait en bas   
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete), //icône pour supprimer
                                                onPressed: () {
                                                  //pour déclencher la reconstruction du widget?
                                                  todoProvider.deleteTodo(event.id).then((value) { //on supprime en premier, then?
                                                  Provider.of<TodoProvider>(context, listen: false).getTodos(_selectedDay!).then((value) { //getTodos recupere les events à la date et donc il fait un -1 avec l'event choisi
                                                    setState(() { //permet de récupérer une liste à jour - l'event qu'on a supprimé 
                                                      eventsForSelectedDay = todoProvider.items.where((item) { //where c une boucle, for element(=item) in list
                                                        return isSameDay(_selectedDay, item.date);//retourner true ou false en faisant une comparaison _selectedDay et item.date, si c true litem est rentré dans eventforSelectedDay (comme un foreach) remonte d'une ligne et la ligne du dessus ajoute l'event en question
                                                      }).toList(); //transformer en liste 
                                                    });
                                                  },);

                                                  });
                                                },
                                              ),
                                            ],
                                          ),
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


  void _showAddEventDialog(DateTime selectedDay, {Map<String, String>? event}) {
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
                    // ignore: use_build_context_synchronously
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
                    // ignore: use_build_context_synchronously
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
                  'year': selectedDay.year,
                  'month': selectedDay.month,
                  'day': selectedDay.day,
                };
              });
              Provider.of<TodoProvider>(context, listen: false).addTodo(newEvent).then((value) { //package provider
                Navigator.pop(context);
                
              });
              Provider.of<TodoProvider>(context, listen: false).getTodos(selectedDay);
              newTaskController.clear();
            },
            child: Text(event == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(DateTime selectedDay, TodoItem event) { //permet de modifier l'event quand j'appuie sur l'icone (ouvre la boîte ), les parametres sont différents, autocomplete ce qu'il y a deja dans la BDD
    TextEditingController nameController = TextEditingController(text: event.eventName); 
    TextEditingController startController = TextEditingController(text: event.eventStart);
    TextEditingController endController = TextEditingController(text: event.eventEnd);
    TextEditingController locationController = TextEditingController(text: event.eventLocation);
    TextEditingController descriptionController = TextEditingController(text: event.eventDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        title: const Text('Modifier un événement'),
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
                    // ignore: use_build_context_synchronously
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
                    // ignore: use_build_context_synchronously
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
              setState(() { //le met à jour ici l'evènement modifier (rajouter des éclaircissements)
                newEvent = {
                  'name': nameController.text,
                  'start': startController.text,
                  'end': endController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                  'year': selectedDay.year,
                  'month': selectedDay.month,
                  'day': selectedDay.day,
                };
              });
              Provider.of<TodoProvider>(context, listen: false).editTodo(event.id, newEvent).then((value) { //edit appelle getTodo
              Provider.of<TodoProvider>(context, listen: false).getTodos(selectedDay);
                Navigator.pop(context); //navigator.pop fonction qui permet de revenir à l’écran précédent. 
                // Elle est utilisée avec Navigator.push(), qui ajoute un nouvel écran à la pile de navigation.
              });
              newTaskController.clear();
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}
class TodoItem{
  dynamic id;
  String eventName;
  String eventStart;
  String eventEnd;
  String eventLocation;
  String eventDescription;
  int eventYear;
  int eventMonth;
  int eventDay;
  bool isExecuted;
  DateTime date = DateTime.now();
  TodoItem({this.id, required this.eventName, 
                    required this.eventStart,
                    required this.eventEnd, 
                    required this.eventLocation, 
                    required this.eventDescription,
                    required this.eventYear, 
                    required this.eventMonth, 
                    required this.eventDay,
                    required this.isExecuted}) {
      date = DateTime(eventYear, eventMonth, eventDay);
    }
}
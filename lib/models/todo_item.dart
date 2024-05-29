class TodoItem{
  dynamic id;
  String eventName;
  String eventStart;
  String eventEnd;
  String eventLocation;
  String eventDescription;
  bool isExecuted;
  TodoItem({this.id, required this.eventName, 
                    required this.eventStart,
                    required this.eventEnd, 
                    required this.eventLocation, 
                    required this.eventDescription,
                    required this.isExecuted});
}
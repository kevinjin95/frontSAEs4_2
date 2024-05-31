import 'dart:ffi';

class TodoItem{
  dynamic id;
  String eventName;
  String eventStart;
  String eventEnd;
  String eventLocation;
  String eventDescription;
  Int eventYear;
  Int eventMonth;
  Int eventDay;
  bool isExecuted;
  TodoItem({this.id, required this.eventName, 
                    required this.eventStart,
                    required this.eventEnd, 
                    required this.eventLocation, 
                    required this.eventDescription,
                    required this.eventYear, 
                    required this.eventMonth, 
                    required this.eventDay,
                    required this.isExecuted});
}
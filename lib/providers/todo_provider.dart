import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // requetes HTTP

import 'package:todo/models/todo_item.dart'; // Modele des taches

class TodoProvider with ChangeNotifier{
  List<TodoItem> _items = [];
  final url = 'http://localhost:5000/event';

  List<TodoItem> get items {
    return [..._items];
  }

  Future<void> addTodo(Map<String, dynamic> event) async {
    Map<String, dynamic> request = {
      "eventName": event['name'] , 
      "eventStart": event['start'], 
      "eventEnd": event['end'], 
      "eventLocation": event['location'],
      "eventDescription": event['description'],
      "eventYear": event['year'],
      "eventMonth": event['month'],
      "eventDay": event['day'],
      "is_executed": false
    };
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(request));
    Map<String, dynamic> responsePayload = json.decode(response.body);
    final todo = TodoItem(
        id: responsePayload["id"],
        eventName: responsePayload["eventName"],
        eventStart: responsePayload["eventStart"],
        eventEnd: responsePayload["eventEnd"],
        eventLocation: responsePayload["eventLocation"],
        eventDescription: responsePayload["eventDescription"],
        eventYear: responsePayload["eventYear"],
        eventMonth: responsePayload["eventMonth"],
        eventDay: responsePayload["eventDay"],
        isExecuted: responsePayload["is_executed"]
    );
    _items.add(todo);
    notifyListeners();
  }

  Future<void> editTodo(int id, Map<String, dynamic> event) async {
    Map<String, dynamic> request = {
      "eventName": event['name'] , 
      "eventStart": event['start'], 
      "eventEnd": event['end'], 
      "eventLocation": event['location'],
      "eventDescription": event['description'],
      "eventYear": event['year'],
      "eventMonth": event['month'],
      "eventDay": event['day'],
      "is_executed": false
    };
    final headers = {'Content-Type': 'application/json'};
    final response = await http.patch(Uri.parse("$url/$id"), headers: headers, body: json.encode(request));
      
  }

 Future<void> getTodos(DateTime selectedDay) async {
    http.Response response;
    try {
      String formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
      
      String requestUrl = "$url?date=$formattedDate";
      
      response = await http.get(Uri.parse(requestUrl));
      List<dynamic> body = json.decode(response.body);
      
      _items = body.map((e) => TodoItem(
        id: e['id'],
        eventName: e['eventName'],
        eventStart: e['eventStart'],
        eventEnd: e['eventEnd'],
        eventLocation: e['eventLocation'],
        eventDescription: e['eventDescription'],
        eventYear: e['eventYear'],
        eventMonth: e['eventMonth'],
        eventDay: e['eventDay'],
        isExecuted: e['is_executed']
      )).toList();
      print(formattedDate);
      _items.forEach((element) {print("event num ${element.id} ${element.eventYear} ${element.eventMonth} ${element.eventDay}");});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow; // Renvoie l'erreur à l'appelant
    }
    notifyListeners();
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(Uri.parse('$url/$id'));
      if (kDebugMode) {
        print('Server response: ${response.body}');
      } // Ajoutez cette ligne

      if (response.statusCode == 200) {
        _items.removeWhere((item) => item.id == id);
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> executeTask(int todoId) async {
    try{
      final response = await http.patch(Uri.parse("$url/$todoId"));
      Map<String, dynamic> responsePayload = json.decode(response.body);
      for (var element in _items) {
        if(element.id == responsePayload["id"]){
            element.isExecuted = responsePayload["is_executed"];
        }
      } 
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
    notifyListeners();
  }

//fonction à garder !!!!!!!!!!!
//   Future<void> getTodos2(DateTime selectedDay) async {
//     http.Response response;
//     try {
//       // Convert the selected date to a string in the format 'yyyy-MM-dd'
//       String formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
      
//       // Append the date as a query parameter to the URL
//       String requestUrl = "$url?date=$formattedDate";
      
//       response = await http.get(Uri.parse(requestUrl));
//       List<dynamic> body = json.decode(response.body);
      
//       _items = body.map((e) => TodoItem(
//         id: e['id'],
//         eventName: e['eventName'],
//         eventStart: e['eventStart'],
//         eventEnd: e['eventEnd'],
//         eventLocation: e['eventLocation'],
//         eventDescription: e['eventDescription'],
//         isExecuted: e['is_executed']
//       )).toList();
//     } catch (e) {
//       print(e);
//     }
//     notifyListeners();
//   }
}

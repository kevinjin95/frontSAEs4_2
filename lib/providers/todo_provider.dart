import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // requetes HTTP

import 'package:todo/models/todo_item.dart'; // Modele des taches

class TodoProvider with ChangeNotifier{
  List<TodoItem> _items = [];
  final url = 'http://localhost:5000/event';

  List<TodoItem> get items {
    return [..._items];
  }

  Future<void> addTodo(Map<String, String> event) async {
    Map<String, dynamic> request = {
      "eventName": event['name'] , 
      "eventStart": event['start'], 
      "eventEnd": event['end'], 
      "eventLocation": event['location'],
      "eventDescription": event['description'],
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
        isExecuted: responsePayload["is_executed"]
    );
    _items.add(todo);
    notifyListeners();
  }

  Future<void> get getTodos async {
    http.Response response;
    try{
      response = await http.get(Uri.parse(url));
      List<dynamic> body = json.decode(response.body);
      _items = body.map((e) => TodoItem(
          id: e['id'],
          eventName: e['eventName'],
          eventStart: e['eventStart'],
          eventEnd: e['eventEnd'],
          eventLocation: e['eventLocation'],
          eventDescription: e['eventDescription'],
          isExecuted: e['is_executed']
      )
      ).toList();
    }catch(e){
      print(e);
    }
    notifyListeners();
  }

  Future<void> deleteTodo(int todoId) async {
    http.Response response;
    try{
      response = await http.delete(Uri.parse("$url/$todoId"));
      final body = json.decode(response.body);
      _items.removeWhere((element) => element.id == body["id"]);
      notifyListeners();
    }catch(e){
      print(e);
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
      print(e);
    }
    notifyListeners();
  }

  
  Future<void> getTodos2(DateTime selectedDay) async {
    http.Response response;
    try {
      // Convert the selected date to a string in the format 'yyyy-MM-dd'
      String formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
      
      // Append the date as a query parameter to the URL
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
        isExecuted: e['is_executed']
      )).toList();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}

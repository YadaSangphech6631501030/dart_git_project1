import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print("===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  final response = await http.post(
    Uri.parse('http://localhost:3000/login'),
    body: {'username': username, 'password': password},
  );

  final data = jsonDecode(response.body);

  if (data is List && data.isNotEmpty) {
    final userId = data[0]['userId'];
    await expenseMenu(username ?? 'User', userId);
  } else if (data is Map) {
    if (data.containsKey('userId')) {
      final userId = data['userId'];
      await expenseMenu(username ?? 'User', userId);
    } else if (data.containsKey('error')) {
      print("${data['error']}");
    } else {
      print("$data");
    }
  } else {
    print("$data");
  }
}



Future<void> expenseMenu(String username, int userId) async {
  while (true) {
    print("\n===== Expense Tracking =====");
    print("Welcome $username ");
    print("1. All expenses"); 
    print("2. Today's expenses"); 
    print("3. Search expense"); 
    print("4. Add new expense"); 
    print("5. Delete an expense"); 
    print("6. Exit");
    stdout.write("Choose ... ");
    String? choice = stdin.readLineSync()?.trim();

    if (choice == '1') {
      await showAllExpenses(userId);  
    } else if (choice == '2') {
      await showTodayExpenses(userId); 
    } else if (choice == '3') {
      await searchExpenses(userId);
    } else if (choice == '4') {
      await addExpenses();       
    } else if (choice == '5') {
      await deleteExpenses();
    } else if (choice == '6') {
      print("--- Bye ---");
      break;
    } else {
      print("Invalid option.");
    }
  }
}

Future<void> showAllExpenses(int userId) async {   
  print("----- All expenses -----");
  final url = Uri.parse('http://localhost:3000/expenses/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body) as List;
    if (result.isNotEmpty) {
      int total = 0;
      for (Map exp in result) {
        print('${exp['id']}. ${exp['item']} : ${exp['paid']} : ${exp["date"]}');
        total += exp['paid'] as int;
      }
      print("Total expenses = $total\$");
    } else {
      print("No expenses found.");
    }
  } else {
    print("Error: ${response.body}");
  }
}

Future<void> showTodayExpenses(int userId) async { 
  print("----- Today's expenses -----");
  final url = Uri.parse('http://localhost:3000/expenses/today/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body) as List;
    if (result.isNotEmpty) {
      int total = 0;
      for (Map exp in result) {
        print('${exp['id']}. ${exp['item']} : ${exp['paid']} : ${exp["date"]}');
        total += exp['paid'] as int;
      }
      print("Total expenses = $total\$");
    } else {
      print("No expenses found for today.");
    }
  } else {
    print("Error: ${response.body}");
  }
}


Future<void> searchExpenses(int userId) async {
  print("----- Search expenses -----");
  // Ask user for keyword/date
  stdout.write("Item to search: ");
  String? search = stdin.readLineSync()?.trim();

  if (search == null || search.isEmpty) {
    print("Please enter a search keyword.");
    return;
  }
  
  final uri = Uri.http('localhost:3000', '/expenses/$userId/search', {'keyword': search});
  try {
    final response = await http.get(uri);

    // Print search results
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as List;
      if (result.isNotEmpty) {
        for (Map exp in result) {
          print('${exp['id']}. ${exp['item']} : ${exp['paid']} : ${exp["date"]}');
        }
      } else {
        print("No item: '$search'");
      }
    } 
  } catch (e) {
    print("Unkonwn error");
  }
}

Future<void> addExpenses() async {
  print("===== Add new expenses =====");
  // Ask user to enter expense name and amount
  stdout.write("Item: ");
  String? item = stdin.readLineSync()?.trim();
  stdout.write("Paid: ");
  String? paidStr = stdin.readLineSync()?.trim();

  if (item == null || paidStr == null) {
    print("Invalid input");
    return;
  }
  // Call API (POST /expenses)
  final body = {"user_id": "1", "item": item, "paid": paidStr};
  final url = Uri.parse('http://localhost:3000/expenses');

  // Confirm if the expense was added successfully
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print("Inserted!");
  } else {
    print("Error: ${response.body}");
  }
}

Future<void> deleteExpenses() async {
  print("===== Delete expenses =====");
  // Ask user for expense ID
  stdout.write("Item id: ");
  String? id = stdin.readLineSync()?.trim();

  if (id == null || id.isEmpty) {
    print("Invalid input");
    return;
  }

  // Call API (DELETE /expenses/:id)
  final url = Uri.parse('http://localhost:3000/expenses/$id');
  final response = await http.delete(url);

  // Confirm if the expense was deleted successfully
  if (response.statusCode == 200) {
    print("Deleted!");
  } else {
    print("Error: ${response.body}");
  }
}

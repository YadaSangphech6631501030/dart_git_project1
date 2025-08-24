import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// login
void main() async {
  print("\n===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  //Incomplete input
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    await expenseMenu(username);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    print(response.body);
  } else {
    print("Unknown error");
  }
}

Future<void> expenseMenu(String username) async {
  while (true) {
    print("\n===== Expense Tracking =====");
    print("Welcome $username ");
    print("1. All expenses"); // dev 1
    print("2. Today's expenses"); // dev 1
    print("3. Search expense"); // dev 2
    print("4. Add new expense"); // dev 3
    print("5. Delete an expense"); // dev 3
    print("6. Exit");
    stdout.write("Choose ... ");
    String? choice = stdin.readLineSync()?.trim();

    if (choice == '1') {
      await showAllExpenses();
    } else if (choice == '2') {
      await showTodayExpenses();
    } else if (choice == '3') {
      await searchExpenses();
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

Future<void> showAllExpenses() async {
  print("----- All expenses -----");
  // Call API (GET /expenses)
  // Parse JSON response
  // Print all expenses
}

Future<void> showTodayExpenses() async {
  print("----- Today's expenses -----");
  // Call API (GET /expenses/today)
  // Filter expenses by today's date
  // Print today's expenses
}

Future<void> searchExpenses() async {
  print("----- Search expenses -----");
  // Ask user for keyword/date
  // Call API (GET /expenses/search?query=...)
  // Print search results
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

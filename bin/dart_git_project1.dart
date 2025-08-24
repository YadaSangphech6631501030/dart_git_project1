import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


int? userID;

void main() async {
  print("\n===== Login =====");
  stdout.write("Username: ");
  final username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  final password = stdin.readLineSync()?.trim();

  if (username == null || password == null || username.isEmpty || password.isEmpty) {
    print("Incomplete input");
    return;
  }

  final url = Uri.parse('http://localhost:3000/login');
  final res = await http.post(url, body: {"username": username, "password": password});

  if (res.statusCode == 200) {
    final data = json.decode(res.body);
    
    userID = (data['userId'] as num).toInt();
    await expenseMenu(username);
  } else {
    print(res.body);
  }
}

Future<void> expenseMenu(String username) async {
  while (true) {
    print("\n===== Expense Tracking =====");
    print("Welcome $username ");
    print("1. All expenses");         // dev 1
    print("2. Today's expenses");      // dev 1
    print("3. Search expense");        // dev 2
    print("4. Add new expense");       // dev 3
    print("5. Delete an expense");     // dev 3
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
  print("---------- All expenses ----------");
  num total = 0;
  final r = await http.get(Uri.parse('http://localhost:3000/expenses/$userID'));
  if (r.statusCode != 200) {
    print('Error ${r.statusCode}: ${r.body}');
    return;
  }
  final List list = json.decode(r.body);
  if (list.isEmpty) { print('No expenses.'); return; }

  for (final e in list) {
    final paid = (e['paid'] as num);
    final dateText = e['formatted_date'] ?? e['date'];
    print('${e['id']}. ${e['item']} : ${paid}฿ : $dateText');
    total += paid;
  }
  print('Total expenses = ${total}฿');
}

Future<void> showTodayExpenses() async {
  print("----- Today's expenses -----");
 final r = await http.get(Uri.parse('http://localhost:3000/expenses/today/$userID'));
  if (r.statusCode != 200) return print('Error ${r.statusCode}: ${r.body}');

  final list = json.decode(r.body) as List;
  if (list.isEmpty) return print('No expenses today.');

  num total = 0;
  for (final e in list) {
    print('${e['id']}. ${e['item']} : ${e['paid']}฿ : ${e['date']}');
    total += (e['paid'] as num);
  }
  print('Total expenses = ${total}฿');
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
  // Call API (POST /expenses)
  // Confirm if the expense was added successfully
}

Future<void> deleteExpenses() async {
  print("===== Delete expenses =====");
   // Ask user for expense ID
  // Call API (DELETE /expenses/:id)
  // Confirm if the expense was deleted successfully
}
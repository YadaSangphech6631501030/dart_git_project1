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

  final data = jsonDecode(response.body);
  final userId = data['userId'];

  if (response.statusCode == 200) {
    await expenseMenu(username,userId);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    print(response.body); 
  } else {
    print("Unknown error");
  }
}

Future<void> expenseMenu(String username, int userId) async {
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
  // Call API (POST /expenses)
  // Confirm if the expense was added successfully
}

Future<void> deleteExpenses() async {
  print("===== Delete expenses =====");
   // Ask user for expense ID
  // Call API (DELETE /expenses/:id)
  // Confirm if the expense was deleted successfully
}
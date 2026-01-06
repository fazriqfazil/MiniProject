import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';
import 'editbookingpage.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Control Panel", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage(role: 'User')),
                );
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: "Menus"),
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.list_alt), text: "All Bookings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminMenusTab(),
            AdminUsersTab(),
            AdminBookingsTab(),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: MANAGE MENUS ---
class AdminMenusTab extends StatefulWidget {
  const AdminMenusTab({super.key});

  @override
  State<AdminMenusTab> createState() => _AdminMenusTabState();
}

class _AdminMenusTabState extends State<AdminMenusTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getAllMenus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No menu packages found. Click + to add."));
          }

          final menus = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final item = menus[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    child: const Icon(Icons.restaurant, color: Colors.black),
                  ),
                  title: Text(item['title'] ?? "Unnamed", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Price: RM${item['basePrice']} | Pax: ${item['pax']}\n"
                          "Main: ${item['main']}\n"
                          "Sides: ${item['sides']}\n"
                          "Rating: ${item['rating']} ⭐",
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditMenuDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDeleteMenu(item['id'], item['title']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showAddMenuDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteMenu(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Menu?"),
        content: Text("Delete '$title' permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteMenu(id);
              if (!mounted) return;
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  void _showEditMenuDialog(BuildContext context, Map<String, dynamic> item) {
    final titleController = TextEditingController(text: item['title']);
    final priceController = TextEditingController(text: item['basePrice'].toString());
    final paxController = TextEditingController(text: item['pax'].toString());
    final mainController = TextEditingController(text: item['main']);
    final sidesController = TextEditingController(text: item['sides']);
    final dessertController = TextEditingController(text: item['dessert']);
    final drinkController = TextEditingController(text: item['drink']);
    final ratingController = TextEditingController(text: item['rating'].toString()); // FIXED HERE

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Menu Package"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(titleController, "Package Title", Icons.title),
              _buildField(priceController, "Price", Icons.attach_money, isNumber: true),
              _buildField(paxController, "Min Pax", Icons.group, isNumber: true),
              _buildField(mainController, "Main Course", Icons.restaurant),
              _buildField(sidesController, "Sides", Icons.set_meal),
              _buildField(dessertController, "Dessert", Icons.cake),
              _buildField(drinkController, "Drink", Icons.local_drink),
              _buildField(ratingController, "Rating (1-5)", Icons.star, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              await _dbHelper.updateMenu(item['id'], {
                'title': titleController.text,
                'basePrice': double.tryParse(priceController.text) ?? 0.0,
                'pax': int.tryParse(paxController.text) ?? 10,
                'main': mainController.text,
                'sides': sidesController.text,
                'dessert': dessertController.text,
                'drink': drinkController.text,
                'rating': int.tryParse(ratingController.text) ?? 5, // Parse back to Int
              });
              if (!mounted) return;
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final mainController = TextEditingController();
    final paxController = TextEditingController();
    final sidesController = TextEditingController();
    final dessertController = TextEditingController();
    final drinkController = TextEditingController();
    final ratingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Menu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(titleController, "Package Title", Icons.title),
              _buildField(priceController, "Price per Guest", Icons.attach_money, isNumber: true),
              _buildField(paxController, "Minimum Pax", Icons.group, isNumber: true),
              _buildField(mainController, "Main Course", Icons.restaurant),
              _buildField(sidesController, "Sides", Icons.set_meal),
              _buildField(dessertController, "Dessert", Icons.cake),
              _buildField(drinkController, "Drinks", Icons.local_drink),
              _buildField(ratingController, "Rating (1-5)", Icons.star, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _dbHelper.addMenuPackage({
                  'title': titleController.text,
                  'basePrice': double.tryParse(priceController.text) ?? 0.0,
                  'pax': int.tryParse(paxController.text) ?? 10,
                  'main': mainController.text,
                  'sides': sidesController.text,
                  'dessert': dessertController.text,
                  'drink': drinkController.text,
                  'rating': int.tryParse(ratingController.text) ?? 5, // Parse to Int
                });
                if (!mounted) return;
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

// --- TAB 2: MANAGE USERS ---
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});
  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Text(user['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user['email']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: () => _confirmDeleteUser(user['id'], user['name']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove User?"),
        content: Text("Are you sure you want to remove $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                await _dbHelper.deleteUser(id);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}


class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Function to refresh the UI
  void _refresh() {
    setState(() {});
  }

  // --- NEW: ACCEPT LOGIC ---
  void _acceptBooking(int id) async {
    // Make sure updateBookingStatus is defined in your DatabaseHelper
    await _dbHelper.updateBookingStatus(id, 'Accepted');
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking accepted!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Edit Logic
  Future<void> _editBooking(Map<String, dynamic> booking) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookingPage(booking: booking),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  // Delete/Cancel Logic
  void _confirmDeleteBooking(int id, String packageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Reservation?"),
        content: Text("Are you sure you want to cancel the booking for '$packageName'?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Booking"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () async {
              await _dbHelper.deleteBooking(id);
              if (!mounted) return;
              Navigator.pop(context);
              _refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reservation cancelled successfully")),
              );
            },
            child: const Text("Confirm Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getAdminAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text("No global bookings found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              // Check status from database
              bool isAccepted = b['status'] == 'Accepted';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isAccepted ? Colors.green : Colors.blueGrey,
                    child: Icon(isAccepted ? Icons.check : Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    b['packageName'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("${b['eventDate']} • ${b['eventTime']}"),
                  trailing: Text(
                    "RM ${b['totalPrice']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer ID: #${b['userId'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text("Number of Guests: ${b['numGuests']} Pax"),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // --- ACCEPT BUTTON ---
                              if (!isAccepted)
                                ElevatedButton.icon(
                                  onPressed: () => _acceptBooking(b['id']),
                                  icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                                  label: const Text("Accept"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text("Accepted ✅",
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),

                              const SizedBox(width: 8),

                              // EDIT BUTTON
                              OutlinedButton.icon(
                                onPressed: () => _editBooking(b),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                              ),
                              const SizedBox(width: 8),

                              // CANCEL BUTTON
                              OutlinedButton.icon(
                                onPressed: () => _confirmDeleteBooking(b['id'], b['packageName']),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text("Cancel"),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
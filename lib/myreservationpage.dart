import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'editbookingpage.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Function to refresh the list after deleting or updating
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reservations", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Ensure your database query pulls the 'status' column
        future: _dbHelper.getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reservations found."));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              // Define status logic
              bool isAccepted = booking['status'] == 'Accepted';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking['packageName'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        // --- STATUS INDICATOR CHIP ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAccepted ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAccepted ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Text(
                            isAccepted ? "Accepted" : "Pending",
                            style: TextStyle(
                              color: isAccepted ? Colors.green[700] : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Date: ${booking['eventDate']}\n"
                            "Time: ${booking['eventTime']}\n"
                            "Guests: ${booking['numGuests']} Pax\n"
                            "Total: RM${booking['totalPrice'].toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button - only show if NOT accepted
                        if (!isAccepted)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Edit Booking",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBookingPage(booking: booking),
                                ),
                              ).then((_) => _refresh());
                            },
                          ),
                        // Delete/Cancel button - always allow cancellation
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Cancel Booking",
                          onPressed: () => _showDeleteDialog(booking['id']),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this reservation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteBooking(id);
              if (!mounted) return;
              Navigator.pop(context);
              _refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Reservation Cancelled"),
                    backgroundColor: Colors.red
                ),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
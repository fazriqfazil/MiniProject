import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditBookingPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  const EditBookingPage({super.key, required this.booking});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  late int _numGuests;
  late double _basePrice;
  late int _minPax; // Dynamic minimum pax

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    // 1. Get current guest count
    _numGuests = widget.booking['numGuests'] ?? 1;


    _minPax = widget.booking['minPax'] ?? 20;

    // 3. Calculate base price (Total / Guests)
    _basePrice = (widget.booking['totalPrice'] ?? 0) / _numGuests;
  }

  // Real-time Re-pricing Logic
  double get _totalPrice => _numGuests * _basePrice;

  // This function handles the "Minus" button and shows your error
  void _decrementGuests() {
    if (_numGuests > _minPax) {
      setState(() {
        _numGuests--;
      });
    } else {
     //ERROR MESSAGE
      ScaffoldMessenger.of(context).clearSnackBars(); // Clears old messages first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ouhh this menu min pax is $_minPax!"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Reservation"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              widget.booking['packageName'] ?? "Package",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Minimum required: $_minPax pax", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            // Guest Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Guests:", style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decrementGuests, // Calls our function with the error
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: _numGuests <= _minPax ? Colors.grey : Colors.red,
                      ),
                    ),
                    Text("$_numGuests", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setState(() => _numGuests++),
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 40),

            Text(
              "Updated Total: RM ${_totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                onPressed: () async {
                  Map<String, dynamic> updatedData = {
                    'numGuests': _numGuests,
                    'totalPrice': _totalPrice,
                  };

                  await _dbHelper.updateBooking(widget.booking['id'], updatedData);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reservation Updated!")),
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
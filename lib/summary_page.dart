import 'package:flutter/material.dart';
import 'database_helper.dart';

class SummaryPage extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;


  const SummaryPage({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Summary"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Please confirm your details:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),


            _summaryRow("Package", bookingDetails['packageName']),
            _summaryRow("Date", bookingDetails['eventDate']),
            _summaryRow("Time", bookingDetails['eventTime']),
            _summaryRow("Guests", bookingDetails['numGuests'].toString()),

            const Divider(height: 40, thickness: 1),


            _summaryRow(
                "Final Amount",
                "RM${bookingDetails['totalPrice'].toStringAsFixed(2)}",
                isTotal: true
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () async {
                  try {

                    await DatabaseHelper().insertBooking(bookingDetails);

                    // Criteria 3: Success Notification
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking Confirmed Successfully!"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );


                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  } catch (e) {

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Error saving booking. Please try again."),
                            backgroundColor: Colors.red
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                    "Confirm Booking",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              "$label:",
              style: TextStyle(
                  fontSize: isTotal ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.black : Colors.grey[700]
              )
          ),
          Text(
              value,
              style: TextStyle(
                  fontSize: isTotal ? 20 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.green[700] : Colors.black
              )
          ),
        ],
      ),
    );
  }
}
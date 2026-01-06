import 'package:flutter/material.dart';
import 'summary_page.dart'; // We will create this next
class BookingPage extends StatefulWidget {
  final Map<String, dynamic> package;
  const BookingPage({super.key, required this.package});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  int _numGuests = 1;
  double _serviceCharge = 10.0; // Fixed customization/service charge

  // Criteria 2: Calculation (basePrice * numguest) + service customization
  double get _totalPrice => (widget.package['basePrice'] * _numGuests) + _serviceCharge;

  @override
  void initState() {
    super.initState();
    // Set initial guests to the package minimum pax
    _numGuests = widget.package['pax'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking: ${widget.package['title']}"),
        backgroundColor: Colors.black, // Makes the bar background black
        foregroundColor: Colors.white, // Makes the text and back arrow white
        elevation: 0,                  // Optional: removes the shadow for a flat, modern look
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Event Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Event Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Event Date', prefixIcon: Icon(Icons.calendar_today_outlined)),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                validator: (value) => value!.isEmpty ? 'Select a date' : null,
              ),
              const SizedBox(height: 15),

              // Event Time
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Event Time', prefixIcon: Icon(Icons.access_time)),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeController.text = pickedTime.format(context);
                    });
                  }
                },
                validator: (value) => value!.isEmpty ? 'Select a time' : null,
              ),
              const SizedBox(height: 25),

              // Number of Guests
              TextFormField(
                initialValue: _numGuests.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Number of Guests",
                  hintText: "Min: ${widget.package['pax']}",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.people),
                ),
                onChanged: (value) {
                  int? val = int.tryParse(value);
                  if (val != null && val >= widget.package['pax']) {
                    setState(() {
                      _numGuests = val;
                    });
                  }
                },
                validator: (value) {
                  int? val = int.tryParse(value!);
                  if (val == null || val < widget.package['pax']) {
                    return "Minimum guests for this package is ${widget.package['pax']}";
                  }
                  return null;
                },
              ),

              const Divider(height: 40),


              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _priceRow("Base Price (${widget.package['basePrice']} x $_numGuests)",
                        (widget.package['basePrice'] * _numGuests)),
                    _priceRow("Service Customization", _serviceCharge),
                    const Divider(),
                    _priceRow("TOTAL PRICE", _totalPrice, isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryPage(
                            bookingDetails: {
                              'packageName': widget.package['title'],
                              'eventDate': _dateController.text,
                              'eventTime': _timeController.text,
                              'numGuests': _numGuests,
                              'totalPrice': _totalPrice,
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Continue to Summary", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, double price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("RM${price.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}
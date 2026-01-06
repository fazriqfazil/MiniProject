import 'package:flutter/material.dart';
import 'database_helper.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation logic for the "Get Started" button pulse
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Catering Packages",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _dbHelper.getAllMenus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("No packages available yet.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              final menus = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 140),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final item = menus[index];
                  return ProfessionalMenuCard(item: item);
                },
              );
            },
          ),


          _buildFloatingFooter(context),
        ],
      ),
    );
  }

  Widget _buildFloatingFooter(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5)
            )
          ],
        ),
        child: Row(
          children: [
            // --- ASSET IMAGE ---
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/image/thumbsup.gif', // Ensure this exists in your assets folder
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.fastfood, color: Colors.orange, size: 40),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Ready to order?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Login to start booking",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),


            ScaleTransition(
              scale: _scaleAnimation,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 5,
                ),
                child: Row(
                  children: const [
                    Text("Get Started",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalMenuCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const ProfessionalMenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(height: 6, color: Colors.black), // Minimalist top accent
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item['title'] ?? 'Menu Package',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildPaxBadge(item['pax'] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRating(item['rating'] ?? 5),
                  const Divider(height: 30),
                  _detailRow(Icons.restaurant, "Main", item['main']),
                  _detailRow(Icons.set_meal, "Sides", item['sides']),
                  _detailRow(Icons.icecream, "Dessert", item['dessert']),
                  _detailRow(Icons.local_drink, "Drink", item['drink']),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("RM ${item['basePrice']}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                      const Text(" / guest", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaxBadge(dynamic pax) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text("Min $pax Pax", style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRating(int rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.amber, size: 16,
      )),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value ?? "Not specified", style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }
}
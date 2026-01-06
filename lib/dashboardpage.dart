import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'main.dart';
import 'myreservationpage.dart';
import 'database_helper.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  const DashboardPage({super.key, required this.userName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      // "back layer" image effect
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                title: Text(
                  'Hi, ${widget.userName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/image/restaurant.jpg',
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _dbHelper.getAllMenus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No packages found."));
            }

            final menus = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final package = menus[index];
                return _buildPackageCard(package);
              },
            );
          },
        ),
      ),
    );
  }

  // UI for Menu Cards
  Widget _buildPackageCard(Map<String, dynamic> package) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package['title'] ?? 'Unnamed Package',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 5),
            _buildStars(package['rating'] ?? 5),
            const Divider(height: 25),
            _menuItem(Icons.restaurant, "Main", package['main'] ?? 'N/A'),
            _menuItem(Icons.cake, "Sides", package['sides'] ?? 'N/A'),
            _menuItem(Icons.icecream_outlined, "Dessert", package['dessert'] ?? 'N/A'),
            _menuItem(Icons.local_drink, "Drink", package['drink'] ?? 'N/A'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Min Pax: ${package['pax'] ?? 0} | RM${package['basePrice']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BookingPage(package: package)));
                  },
                  child: const Text("Select Package",
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(
          5,
              (i) => Icon(Icons.star,
              color: i < rating ? Colors.orange : Colors.grey, size: 20)),
    );
  }

  // --- SIDEBAR WITH ACCEPTED COUNT BADGE ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_circle, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text("Welcome, ${widget.userName}",
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          _drawerSectionTitle("MY ACTIVITY"),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),

          // FUTURE BUILDER FOR ACTIVE RESERVATIONS COUNT
          FutureBuilder<int>(
            future: _dbHelper.getAcceptedBookingCount(),
            builder: (context, snapshot) {
              int acceptedCount = snapshot.data ?? 0;

              return ListTile(
                leading: const Icon(Icons.event_available, color: Colors.green),
                title: const Text("Active Reservations"),
                // Only show badge if count > 0
                trailing: acceptedCount > 0
                    ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$acceptedCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyReservationsPage()));
                },
              );
            },
          ),

          const Divider(),
          _drawerSectionTitle("ACCOUNT"),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(role: 'User')));
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 15, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1.1),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const _ParentHomePage(),
      );
  }
}

class _ParentHomePage extends StatelessWidget {
  const _ParentHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Promotional Banner
              _buildPromotionalBanner(),
              const SizedBox(height: 20),

              // Featured Caregivers
              _buildFeaturedCaregivers(),
              const SizedBox(height: 20),

              // Quick Booking Options
              _buildQuickBooking(),
              const SizedBox(height: 20),

              // Categories
              _buildCategories(),
              const SizedBox(height: 20),

              // Upcoming Bookings
              _buildUpcomingBookings(),
              const SizedBox(height: 20),

              // Testimonials
              _buildTestimonials(),
              const SizedBox(height: 20),

              // Call-to-Action Buttons
              _buildCallToActionButtons(),
              const SizedBox(height: 20),

              // Footer Links
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for caregivers...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Promotional Banner
  Widget _buildPromotionalBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/promo_banner.jpg'), // Add your image asset
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Text(
          'Support B40 Caregivers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Featured Caregivers
  Widget _buildFeaturedCaregivers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Caregivers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Example: 5 featured caregivers
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/caregiver.jpg'), // Add caregiver image
                    ),
                    const SizedBox(height: 10),
                    const Text('Jane Doe'),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('4.8'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Quick Booking Options
  Widget _buildQuickBooking() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to quick booking screen
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Book Now'),
    );
  }

  // Categories
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: const [
            _CategoryItem(icon: Icons.school, label: 'Tutoring'),
            _CategoryItem(icon: Icons.nightlight, label: 'Overnight'),
            _CategoryItem(icon: Icons.accessible, label: 'Special Needs'),
          ],
        ),
      ],
    );
  }

  // Upcoming Bookings
  Widget _buildUpcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Bookings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/caregiver.jpg'), // Add caregiver image
            ),
            title: Text('Jane Doe'),
            subtitle: Text('Tomorrow, 10:00 AM'),
            trailing: Icon(Icons.arrow_forward),
          ),
        ),
      ],
    );
  }

  // Testimonials
  Widget _buildTestimonials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Testimonials',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Example: 3 testimonials
            itemBuilder: (context, index) {
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“Great experience with Jane!”',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 5),
                    Text('- Sarah M.'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Call-to-Action Buttons
  Widget _buildCallToActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to become a caregiver screen
            },
            child: const Text('Become a Caregiver'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to donation screen
            },
            child: const Text('Donate'),
          ),
        ),
      ],
    );
  }

  // Footer Links
  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {
            // Navigate to how it works screen
          },
          child: const Text('How It Works'),
        ),
        TextButton(
          onPressed: () {
            // Navigate to FAQs screen
          },
          child: const Text('FAQs'),
        ),
        TextButton(
          onPressed: () {
            // Navigate to contact us screen
          },
          child: const Text('Contact Us'),
        ),
      ],
    );
  }
}

// Category Item Widget
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
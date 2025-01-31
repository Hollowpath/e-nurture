import 'package:flutter/material.dart';

class ParentCard extends StatelessWidget {
  final String name;
  final int age;
  final double rating;
  final int hourlyRate;
  final List<String> certifications;
  final String experience;
  final String availability;
  final String distance;
  final String image;

  const ParentCard({
    super.key,
    required this.name,
    required this.age,
    required this.rating,
    required this.hourlyRate,
    required this.certifications,
    required this.experience,
    required this.availability,
    required this.distance,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caregiver Information
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(image), // Caregiver profile picture
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name, $age',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('$rating'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Hourly Rate
            Text('\$$hourlyRate/hour'),
            // Certifications
            Text('Certifications: ${certifications.join(', ')}'),
            // Experience
            Text('Experience: $experience'),
            // Availability
            Text('Availability: $availability'),
            // Distance
            Text('Distance: $distance'),
            const SizedBox(height: 10),
            // Quick Actions
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to booking screen
                  },
                  child: const Text('Book Now'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to caregiver profile
                  },
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
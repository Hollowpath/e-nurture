import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverCard extends StatelessWidget {
  final String bookingId;
  final String date;
  final String time;
  final String parentName;
  final int children;
  final String location;
  final String status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMessageParent;

  const CaregiverCard({
    super.key,
    required this.bookingId,
    required this.date,
    required this.time,
    required this.parentName,
    required this.children,
    required this.location,
    required this.status,
    this.onAccept,
    this.onReject,
    this.onViewDetails,
    this.onMessageParent,
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
            Text(
              '$date, $time',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Parent: $parentName'),
            Text('Children: $children'),
            Text('Location: $location'),
            Text(
              'Status: $status',
              style: TextStyle(
                color: status == 'Pending'
                    ? Colors.orange
                    : status == 'Accepted'
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (status == 'Pending')
                  ElevatedButton(
                    onPressed: onAccept, // Use callback function
                    child: const Text('Accept'),
                  ),
                if (status == 'Pending') const SizedBox(width: 10),
                if (status == 'Pending')
                  ElevatedButton(
                    onPressed: onReject, // Use callback function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onMessageParent,
                  child: const Text('Message Parent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

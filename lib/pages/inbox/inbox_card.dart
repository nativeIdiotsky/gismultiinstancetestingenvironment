import 'package:flutter/material.dart';
import 'inbox_model.dart';
import 'inbox_show_message.dart'; // Import the new details page

class InboxCard extends StatelessWidget {
  final NotifyBroadcast notification;

  const InboxCard({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetailsPage(context, notification),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _getBorderColor(notification.warning_gauge_lvl)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              decoration: BoxDecoration(
                color: _getBorderColor(notification.warning_gauge_lvl),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to the details page
  void _navigateToDetailsPage(
      BuildContext context, NotifyBroadcast notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboxDetailsPage(notification: notification),
      ),
    );
  }

  // Method to determine border color based on status code
  Color _getBorderColor(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

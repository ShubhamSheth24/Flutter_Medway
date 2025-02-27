import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQs"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ExpansionTile(
              title: Text("How do I update my payment method?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "You can update your payment method by navigating to the Payment Method page and entering your new card details."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("How do I reset my password?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "To reset your password, go to the login page and click on the 'Forgot Password' link. Follow the instructions sent to your email."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("How do I schedule an appointment?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "You can schedule an appointment by navigating to the Appointment page and selecting your preferred date and time."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("What payment methods are accepted?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "We accept all major credit and debit cards, including Visa, MasterCard, and American Express."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("How do I cancel an appointment?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "You can cancel an appointment by going to the Appointment page, selecting the appointment, and clicking the 'Cancel' button."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Is my personal information secure?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "Yes, we use advanced encryption and security measures to protect your personal information."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("How do I contact customer support?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "You can contact customer support by emailing support@example.com or calling +1-123-456-7890."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Can I change my email address?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "Yes, you can change your email address by going to the Profile page and updating your email in the settings."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("What should I do if I forget my username?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "If you forget your username, you can recover it by clicking on the 'Forgot Username' link on the login page and following the instructions."),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("How do I update my health stats?"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "You can update your health stats by navigating to the Profile page and editing the relevant fields."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

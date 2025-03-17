import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50, // Reduced from 56
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20, // Reduced from 22
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18, // Reduced from 20
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10), // Reduced from 12
          children: [
            const Padding(
              padding:
                  EdgeInsets.only(top: 10, bottom: 16), // Reduced from 12, 20
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 22, // Reduced from 24
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildFAQTile(
              'How do I update my payment method?',
              'You can update your payment method by navigating to the Payment Method page and entering your new card details.',
            ),
            _buildFAQTile(
              'How do I reset my password?',
              'To reset your password, go to the login page and click on the "Forgot Password" link. Follow the instructions sent to your email.',
            ),
            _buildFAQTile(
              'How do I schedule an appointment?',
              'You can schedule an appointment by navigating to the Appointment page and selecting your preferred date and time.',
            ),
            _buildFAQTile(
              'What payment methods are accepted?',
              'We accept all major credit and debit cards, including Visa, MasterCard, and American Express.',
            ),
            _buildFAQTile(
              'How do I cancel an appointment?',
              'You can cancel an appointment by going to the Appointment page, selecting the appointment, and clicking the "Cancel" button.',
            ),
            _buildFAQTile(
              'Is my personal information secure?',
              'Yes, we use advanced encryption and security measures to protect your personal information.',
            ),
            _buildFAQTile(
              'How do I contact customer support?',
              'You can contact customer support by emailing support@example.com or calling +1-123-456-7890.',
            ),
            _buildFAQTile(
              'Can I change my email address?',
              'Yes, you can change your email address by going to the Profile page and updating your email in the settings.',
            ),
            _buildFAQTile(
              'What should I do if I forget my username?',
              'If you forget your username, you can recover it by clicking on the "Forgot Username" link on the login page and following the instructions.',
            ),
            _buildFAQTile(
              'How do I update my health stats?',
              'You can update your health stats by navigating to the Profile page and editing the relevant fields.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6), // Reduced from 8
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Reduced from 10
        ),
        color: Colors.grey.shade50,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6), // Reduced from 16, 8
          childrenPadding:
              const EdgeInsets.fromLTRB(12, 0, 12, 12), // Reduced from 16
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16, // Reduced from 18
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          iconColor: Colors.blueAccent,
          collapsedIconColor: Colors.grey,
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 12, // Reduced from 14
                color: Color.fromRGBO(97, 97, 97, 1),
                height: 1.3, // Slightly tightened from 1.4
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FAQItem(
              question: 'How do I place an order?',
              answer:
                  'Browse products, add items to cart, proceed to checkout, and select your payment method.',
            ),
            FAQItem(
              question: 'What payment methods do you accept?',
              answer: 'We accept M-Pesa, Credit/Debit Cards, and other payment gateways.',
            ),
            FAQItem(
              question: 'How long does delivery take?',
              answer:
                  'Standard delivery takes 2-5 business days depending on your location.',
            ),
            FAQItem(
              question: 'Can I cancel my order?',
              answer:
                  'Orders can be cancelled within 1 hour of placement. Contact our support team for assistance.',
            ),
            FAQItem(
              question: 'What is your return policy?',
              answer:
                  'Items can be returned within 30 days of delivery in original condition for a full refund.',
            ),
            FAQItem(
              question: 'How do I track my order?',
              answer:
                  'You can track your order status in the Orders section of your profile.',
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

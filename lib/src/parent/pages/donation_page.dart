import 'package:flutter/material.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impactful Banner
            _buildImpactfulBanner(),
            const SizedBox(height: 20),

            // Donation Purpose
            _buildDonationPurpose(),
            const SizedBox(height: 20),

            // Donation Options
            _buildDonationOptions(),
            const SizedBox(height: 20),

            // Payment Methods
            _buildPaymentMethods(),
            const SizedBox(height: 20),

            // Impact Breakdown
            _buildImpactBreakdown(),
            const SizedBox(height: 20),

            // Donor Recognition
            _buildDonorRecognition(),
            const SizedBox(height: 20),

            // Tax Deduction Information
            _buildTaxDeductionInfo(),
            const SizedBox(height: 20),

            // Call-to-Action Button
            _buildDonateNowButton(),
            const SizedBox(height: 20),

            // Trust and Security
            _buildTrustAndSecurity(),
            const SizedBox(height: 20),

            // Testimonials
            _buildTestimonials(),
            const SizedBox(height: 20),

            // Contact Information
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  // Impactful Banner
  Widget _buildImpactfulBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/donation_banner.jpg'), // Add your image asset
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

  // Donation Purpose
  Widget _buildDonationPurpose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Your Donation Makes a Difference',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Your donation funds training and certification for low-income caregivers, helping them provide better care for children in need.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Donation Options
  Widget _buildDonationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donation Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDonationButton('\$10'),
            _buildDonationButton('\$25'),
            _buildDonationButton('\$50'),
            _buildDonationButton('\$100'),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter custom amount',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Checkbox(value: false, onChanged: null),
            Text('Make this a monthly donation'),
          ],
        ),
      ],
    );
  }

  // Donation Button Widget
  Widget _buildDonationButton(String amount) {
    return ElevatedButton(
      onPressed: () {
        // Handle donation amount selection
      },
      child: Text(amount),
    );
  }

  // Payment Methods
  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Payment Methods',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Credit/Debit Card'),
        Text('PayPal'),
        Text('Google Pay'),
      ],
    );
  }

  // Impact Breakdown
  Widget _buildImpactBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Impact',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('\$50 funds CPR certification for one caregiver.'),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: 0.5, // Example: 50% progress
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 10),
        const Text('Raised: \$5,000 of \$10,000 goal'),
      ],
    );
  }

  // Donor Recognition
  Widget _buildDonorRecognition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donor Recognition',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Checkbox(value: false, onChanged: null),
            Text('Donate anonymously'),
          ],
        ),
        Row(
          children: const [
            Checkbox(value: false, onChanged: null),
            Text('Display my name on the donor wall'),
          ],
        ),
      ],
    );
  }

  // Tax Deduction Information
  Widget _buildTaxDeductionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Tax Deduction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Your donation is tax-deductible. A receipt will be emailed to you.'),
      ],
    );
  }

  // Donate Now Button
  Widget _buildDonateNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle donation submission
        },
        child: const Text('Donate Now'),
      ),
    );
  }

  // Trust and Security
  Widget _buildTrustAndSecurity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Trust & Security',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Your information is secure and will not be shared.'),
        SizedBox(height: 10),
        Text('Secured by SSL Encryption'),
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
        const Text(
          '"Thanks to donors, I became a certified caregiver and can now provide better care for children in my community." - Sarah',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Image.asset('assets/testimonial.jpg'), // Add testimonial image
      ],
    );
  }

  // Contact Information
  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Contact Us',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Email: support@enurture.com'),
        Text('Phone: +1 (123) 456-7890'),
      ],
    );
  }
}
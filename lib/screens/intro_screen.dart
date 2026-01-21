import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Higher Returns,\nNo Hidden Charges',
      'description':
          'Experience transparent banking with competitive interest rates and zero hidden fees.',
      'image': 'lib/images/intro_1.png', // Placeholder
      'icon': 'trending_up'
    },
    {
      'title': 'Anytime\nWithdrawal',
      'description':
          'Your money is always yours. Withdraw instantly whenever you need it, 24/7.',
      'image': 'lib/images/intro_2.png', // Placeholder
      'icon': 'timelapse'
    },
    {
      'title': 'No Loss\nPolicy',
      'description':
          'Your capital is secure with us. We prioritize the safety of your funds above all else.',
      'image': 'lib/images/intro_3.png', // Placeholder
      'icon': 'shield'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    context,
                    _pages[index],
                    colorScheme,
                  );
                },
              ),
            ),
            _buildBottomControls(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, Map<String, String> data, ColorScheme colorScheme) {
    IconData icon;
    if (data['icon'] == 'trending_up')
      icon = Icons.trending_up;
    else if (data['icon'] == 'timelapse')
      icon = Icons.timelapse;
    else
      icon = Icons.shield;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['description']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pushNamed(context, '/mobile_otp');
                }
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Already have an account? Login',
                style: GoogleFonts.poppins(color: colorScheme.primary)),
          )
        ],
      ),
    );
  }
}

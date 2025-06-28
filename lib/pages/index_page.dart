import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_text.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Header
                  const SizedBox(height: 32),
                  _buildHeader(),
                  
                  // Hero Section
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeroSection(),
                  ),
                  
                  // Stats
                  const SizedBox(height: 32),
                  _buildStats(),
                  
                  // Features
                  const SizedBox(height: 48),
                  _buildFeatures(),
                  
                  // Main Action Button
                  const SizedBox(height: 48),
                  _buildMainActionButton(),
                  
                  // Build Your Knight Coach Button
                  const SizedBox(height: 24),
                  _buildCoachBuilderButton(),
                  
                  // Motivation Section
                  const SizedBox(height: 48),
                  _buildMotivationSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.directions_run,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Stride',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Column(
          children: [
            const GradientText(
              'Run Smarter',
              colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const GradientText(
              'Not Harder',
              colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'AI-powered form analysis for safer, more efficient running',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('∞', 'Analyses'),
        _buildStatCard('AI', 'Powered'),
        _buildStatCard('15s', 'Analysis'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.upload_file,
        'title': 'Upload Video',
        'description': 'Record 10 seconds of your running form',
        'step': '1',
      },
      {
        'icon': Icons.flash_on,
        'title': 'AI Analysis',
        'description': 'Advanced ML analyzes your biomechanics',
        'step': '2',
      },
      {
        'icon': Icons.track_changes,
        'title': 'Get Feedback',
        'description': 'Personalized coaching for improvement from Gemini AI',
        'step': '3',
      },
    ];

    return Column(
      children: [
        const Text(
          'How it works',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ...features
            .asMap()
            .entries
            .map((entry) => _buildFeatureCard(entry.value, entry.key))
            .toList(),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                feature['icon'],
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature['step'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Start Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Upload your running video to get started',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachBuilderButton() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: ElevatedButton(
            onPressed: () => context.go('/coach-builder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, color: Color(0xFF8B5CF6)),
                SizedBox(width: 12),
                Text(
                  'Build Your Knight Coach',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create your personalized running coach',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.directions_run,
              color: Color(0xFF8B5CF6),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to improve?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join thousands of runners optimizing their form with AI feedback',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 
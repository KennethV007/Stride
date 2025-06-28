import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_text.dart';

class _GeminiGradientCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepGradient = SweepGradient(
      colors: const [
        Color(0xFF4F8CFF),
        Color(0xFF7F5FFF),
        Color(0xFFFF5CA8),
        Color(0xFF4F8CFF), // loop for smoothness
      ],
      startAngle: 0.0,
      endAngle: 6.28319, // 2*pi
    );
    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 2, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    
    // Pulse animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1333),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gemini gradient background
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181A20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF181A20),
                  const Color(0xFF4F8CFF).withValues(alpha: 0.25),
                  const Color(0xFF7F5FFF).withValues(alpha: 0.25),
                  const Color(0xFFFF5CA8).withValues(alpha: 0.18),
                  const Color(0xFF181A20),
                ],
                stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
              ),
            ),
          ),
          // Dark overlay for extra tint
          Container(
            color: Colors.black.withValues(alpha: 0.18), // slightly darker tint
          ),
          // Main content
          SafeArea(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(Color(0xFF4F8CFF), Color(0xFF7F5FFF), _pulseAnimation.value)!,
                        Color.lerp(Color(0xFF7F5FFF), Color(0xFFFF5CA8), _pulseAnimation.value)!,
                        Color.lerp(Color(0xFFFF5CA8), Color(0xFF4F8CFF), _pulseAnimation.value)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return GradientText(
                  'Stride',
                  colors: [
                    Color.lerp(Color(0xFF4F8CFF), Color(0xFF7F5FFF), _pulseAnimation.value)!,
                    Color.lerp(Color(0xFF7F5FFF), Color(0xFFFF5CA8), _pulseAnimation.value)!,
                    Color.lerp(Color(0xFFFF5CA8), Color(0xFF4F8CFF), _pulseAnimation.value)!,
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        // Keep user menu/login widgets from teammates
        IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(
            Icons.account_circle_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
          tooltip: 'Account',
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return GradientText(
              'Run Smarter',
              colors: [
                Color.lerp(Color(0xFF4F8CFF), Color(0xFF7F5FFF), _pulseAnimation.value)!,
                Color.lerp(Color(0xFF7F5FFF), Color(0xFFFF5CA8), _pulseAnimation.value)!,
                Color.lerp(Color(0xFFFF5CA8), Color(0xFF4F8CFF), _pulseAnimation.value)!,
              ],
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return GradientText(
              'Not Harder',
              colors: [
                Color.lerp(Color(0xFFFF5CA8), Color(0xFF7F5FFF), _pulseAnimation.value)!,
                Color.lerp(Color(0xFF7F5FFF), Color(0xFF4F8CFF), _pulseAnimation.value)!,
                Color.lerp(Color(0xFF4F8CFF), Color(0xFFFF5CA8), _pulseAnimation.value)!,
              ],
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'AI-powered form analysis for safer, more efficient running',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          GradientText(
            value,
            colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.person_add,
        'title': 'Generate Coach',
        'description': 'Create your personalized AI running coach',
        'step': '1',
      },
      {
        'icon': Icons.upload_file,
        'title': 'Upload Video',
        'description': 'Record 10 seconds of your running form',
        'step': '2',
      },
      {
        'icon': Icons.flash_on,
        'title': 'AI Analysis',
        'description': 'Advanced ML analyzes your biomechanics',
        'step': '3',
      },
      {
        'icon': Icons.track_changes,
        'title': 'Get Feedback',
        'description': 'Personalized coaching for improvement from Gemini AI',
        'step': '4',
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF7F5FFF).withValues(alpha: 0.18),
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                feature['icon'],
                color: Colors.white, // icon itself is white
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature['step'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientText(
                      feature['title'],
                      colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
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
                  colors: [
                    Color(0xFF4F8CFF),
                    Color(0xFF7F5FFF),
                    Color(0xFFFF5CA8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
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
            color: Colors.white.withValues(alpha: 0.6),
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
              width: 1.5,
              color: const Color(0xFF7F5FFF), // Gemini purple
            ),
          ),
          child: ElevatedButton(
            onPressed: () => context.go('/coach-builder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF7F5FFF), // Gemini purple
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, color: Color(0xFF7F5FFF)), // Gemini purple
                SizedBox(width: 12),
                Text(
                  'Build Your AI Coach',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F5FFF), // Gemini purple
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: Color(0xFF7F5FFF)), // Gemini purple
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create your personalized running coach',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _GeminiGradientCirclePainter(),
                ),
              ),
              const Icon(
                Icons.auto_graph,
                color: Colors.white,
                size: 32,
              ),
            ],
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
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
} 
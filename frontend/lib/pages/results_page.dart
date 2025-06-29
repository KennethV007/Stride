import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_text.dart';
import 'package:video_player/video_player.dart';







class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  VideoPlayerController? _controller;
  String? _videoUrl;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isInitialized = false;
  String? _videoError;
  List<String> _tips = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['processed_video_url'] != null) {
      _videoUrl = extra['processed_video_url'];
      if (extra['analysis'] is Map && extra['analysis']['tips'] is List) {
        _tips = List<String>.from(extra['analysis']['tips']);
      }
      _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!))
        ..initialize().then((_) {
          setState(() {});
          _controller!.setVolume(0.0);
          _controller!.play();
        });
      _controller!.setLooping(true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181A20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF181A20),
                  const Color(0xFF4F8CFF).withOpacity(0.25),
                  const Color(0xFF7F5FFF).withOpacity(0.25),
                  const Color(0xFFFF5CA8).withOpacity(0.18),
                  const Color(0xFF181A20),
                ],
                stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.18),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          _buildVideoSection(),
                          const SizedBox(height: 24),
                          _buildAIFeedbackSection(),
                          const SizedBox(height: 32),
                          _buildActionButtons(context),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 2,
                  style: BorderStyle.solid,
                  color: Colors.transparent,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GradientText(
              'Your Form Analysis',
              colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analyzed Video',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Video Player
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
<<<<<<< HEAD
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF06B6D4).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    
                    // Play button
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    
                    // Pose tracking indicator
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pose Tracking: Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
=======
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(),
>>>>>>> 2d14dde8878430ab47627e4d21c9445228732826
              ),
              const SizedBox(height: 16),
              // Video controls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Your Form'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Optimal Form'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Coach Feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coach Avatar
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Center(
                        child: Text(
                          'CS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coach Stride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'AI Form Analyst',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
<<<<<<< HEAD
              
              // Primary Feedback
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F5FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    style: BorderStyle.solid,
                    color: Colors.transparent,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Feedback:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F5FFF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You\'re overstriding slightly.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Detailed Feedback
              Text(
                'Your foot is landing too far in front of your center of gravity, which can lead to braking forces and increased injury risk. Try to focus on landing with your foot closer to directly under your hips.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Your cadence appears to be around 165 steps per minute. Consider increasing to 170-180 for optimal efficiency.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Overall, your upper body posture looks great! Keep that slight forward lean and relaxed shoulders.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
=======
              // Dynamic Feedback Tips
              if (_tips.isNotEmpty)
                ..._tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 16)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              if (_tips.isEmpty)
                const Text(
                  'No feedback available.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
>>>>>>> 2d14dde8878430ab47627e4d21c9445228732826
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Upload Another Run',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7F5FFF)),
              foregroundColor: const Color(0xFF7F5FFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Icon(Icons.trending_up, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'View Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F5FFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 
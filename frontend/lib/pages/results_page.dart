import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_text.dart';
import 'package:video_player/video_player.dart';
import '../services/gemini_service.dart';
import '../services/coach_storage_service.dart';
import 'dart:typed_data';







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
  List<String> _geminiFeedback = [];
  Map<String, dynamic>? _analysisData;
  bool _isGeneratingFeedback = false;
  CoachData? _savedCoach;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['processed_video_url'] != null) {
      _videoUrl = extra['processed_video_url'];
      _analysisData = extra['analysis'] as Map<String, dynamic>?;
      
      // Get basic tips from analysis
      if (_analysisData != null && _analysisData!['tips'] is List) {
        _tips = List<String>.from(_analysisData!['tips']);
      }
      
      // Initialize video controller
      _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!))
        ..initialize().then((_) {
          setState(() {});
          _controller!.setVolume(0.0);
          _controller!.play();
        });
      _controller!.setLooping(true);
      
      // Load saved coach data and generate Gemini feedback
      _loadSavedCoach();
      _generateGeminiFeedback();
    }
  }

  Future<void> _loadSavedCoach() async {
    final coach = await CoachStorageService.loadCoach();
    if (mounted) {
      setState(() {
        _savedCoach = coach;
      });
    }
  }

  Future<void> _generateGeminiFeedback() async {
    if (_analysisData == null) return;
    
    setState(() {
      _isGeneratingFeedback = true;
    });
    
    try {
      final feedback = await GeminiService.generateRunningFormFeedback(
        analysisData: _analysisData!,
      );
      
      if (feedback != null && mounted) {
        setState(() {
          _geminiFeedback = feedback;
          _isGeneratingFeedback = false;
        });
      }
    } catch (e) {
      print('Error generating Gemini feedback: $e');
      if (mounted) {
        setState(() {
          _isGeneratingFeedback = false;
        });
      }
    }
  }

  String _getCoachName() {
    if (_savedCoach == null) return 'Coach Stride';
    
    final type = _savedCoach!.type;
    final attributes = _savedCoach!.attributes;
    
    switch (type) {
      case 'Knight':
        final personality = attributes['personality'] ?? 'Noble';
        final region = attributes['region'] ?? 'Realm';
        return 'Sir $personality of $region';
      case 'Ninja':
        final element = attributes['element'] ?? 'Shadow';
        final village = attributes['village'] ?? 'Village';
        return '$element ${village.split(' ').first} Ninja';
      case 'Robot':
        final function = attributes['function'] ?? 'Assistant';
        final lab = attributes['lab'] ?? 'Tech';
        return '${lab.split(' ').first}-${function.split(' ').first}';
      case 'Mandalorian':
        final region = attributes['region'] ?? 'Sector';
        final warriorType = attributes['warrior_type'] ?? 'Hunter';
        return '$region $warriorType';
      default:
        return 'Coach Stride';
    }
  }

  String _getCoachSubtitle() {
    if (_savedCoach == null) return 'AI Form Analyst';
    
    final type = _savedCoach!.type;
    
    switch (type) {
      case 'Knight':
        return 'Running Form Knight';
      case 'Ninja':
        return 'Speed & Form Ninja';
      case 'Robot':
        return 'Biomechanics Analyst';
      case 'Mandalorian':
        return 'Form Discipline Master';
      default:
        return 'AI Form Analyst';
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
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
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
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(),
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
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _savedCoach?.imageAsBytes != null
                            ? Image.memory(
                                _savedCoach!.imageAsBytes!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFF1E293B),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCoachName(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getCoachSubtitle(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // AI-Generated Feedback (Gemini)
              if (_isGeneratingFeedback)
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Generating personalized feedback...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              
              // Show Gemini feedback if available
              if (_geminiFeedback.isNotEmpty && !_isGeneratingFeedback)
                ..._geminiFeedback.map((feedback) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 16)),
                      Expanded(
                        child: Text(
                          feedback,
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
                
              // Show basic tips if no Gemini feedback yet
              if (_geminiFeedback.isEmpty && !_isGeneratingFeedback && _tips.isNotEmpty)
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
                
              // Show fallback message if no feedback available
              if (_geminiFeedback.isEmpty && _tips.isEmpty && !_isGeneratingFeedback)
                const Text(
                  'No feedback available.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
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
      ],
    );
  }
} 
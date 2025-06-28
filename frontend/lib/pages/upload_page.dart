import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_text.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _includeGpsStats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildTitle(),
                        const SizedBox(height: 32),
                        _buildUploadZone(),
                        const SizedBox(height: 32),
                        _buildMotivationalCopy(),
                        const SizedBox(height: 24),
                        _buildGpsToggle(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'Submit Your Run for Analysis',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Upload your running video and let our AI analyze your form',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: _handleFileUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            // Video Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(39),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Color(0xFF06B6D4),
                  size: 32,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upload Text
            const Text(
              'Upload or Record Your Video Here',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'MP4 / MOV / Max 15 seconds',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Choose File Button
            ElevatedButton(
              onPressed: _handleFileUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Choose File',
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
            
            const SizedBox(height: 20),
            
            // Divider
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withOpacity(0.2),
            ),
            
            const SizedBox(height: 20),
            
            // Record Video Button
            ElevatedButton(
              onPressed: _handleVideoRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_camera_front, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Record a Video',
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
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalCopy() {
    return const GradientText(
      'Stride smarter, not harder.',
      colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGpsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Include recent GPS stats',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _includeGpsStats = !_includeGpsStats;
              });
            },
            child: Container(
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                color: _includeGpsStats
                    ? const Color(0xFF06B6D4)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _includeGpsStats
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFileUpload() {
    // Simulate file upload process
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Upload Video',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Video upload functionality would be implemented here. For now, proceeding to results.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/results');
              },
              child: const Text(
                'Continue to Results',
                style: TextStyle(color: Color(0xFF06B6D4)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleVideoRecording() {
    context.go('/camera');
  }
} 
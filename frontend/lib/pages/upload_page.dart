import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/gradient_text.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentStep = '';
  String? _processedVideoUrl;
  Map<String, dynamic>? _analysisData;

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
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
      onTap: _isUploading ? null : _handleFileUpload,
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
                child: _isUploading 
                  ? const CircularProgressIndicator(
                      color: Color(0xFF06B6D4),
                      strokeWidth: 3,
                    )
                  : const Icon(
                      Icons.videocam,
                      color: Color(0xFF06B6D4),
                      size: 32,
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upload Text
            Text(
              _isUploading ? 'Processing Your Video...' : 'Upload or Record Your Video Here',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            if (_isUploading && _currentStep.isNotEmpty) ...[
              Text(
                _currentStep,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
              ),
            ] else ...[
              Text(
                'MP4 / MOV / Max 15 seconds',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Choose File Button
            if (!_isUploading) ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalCopy() {
    return GradientText(
      'Stride smarter, not harder.',
      colors: [Color(0xFF4F8CFF), Color(0xFF7F5FFF), Color(0xFFFF5CA8)],
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }



  void _handleFileUpload() async {
    if (_isUploading) return;
    
    final ImagePicker picker = ImagePicker();
    try {
      // Pick video from gallery
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15), // Limit to 15 seconds
      );

      if (video != null) {
        await _processVideo(video);
      }
    } catch (e) {
      _showErrorDialog('Failed to select video: $e');
    }
  }

  Future<void> _processVideo(XFile video) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentStep = 'Preparing video for upload...';
    });

    try {
      // Step 1: Upload video to backend
      setState(() {
        _currentStep = 'Uploading video to server...';
        _uploadProgress = 0.2;
      });

      final uploadResponse = await _uploadVideoToBackend(video);
      
      setState(() {
        _currentStep = 'Analyzing video with AI...';
        _uploadProgress = 0.5;
      });

      // Step 2: Run analysis (this happens on the backend)
      setState(() {
        _currentStep = 'Processing MediaPipe landmarks...';
        _uploadProgress = 0.7;
      });

      // Step 3: Show results
      setState(() {
        _currentStep = 'Analysis complete!';
        _uploadProgress = 1.0;
        _processedVideoUrl = uploadResponse['processed_video_url'];
        _analysisData = uploadResponse['analysis'];
      });

      // Show the processed video in a dialog
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showProcessedVideoDialog(uploadResponse);
      }

    } catch (e) {
      _showErrorDialog('Processing failed: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _currentStep = '';
      });
    }
  }

  Future<Map<String, dynamic>> _uploadVideoToBackend(XFile video) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/video/upload'),
      );
      
      // Add the file with explicit content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await video.readAsBytes(),
          filename: video.name,
          contentType: MediaType('video', 'mp4'), // Explicit content type
        ),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Server error: ${streamedResponse.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  void _showProcessedVideoDialog(Map<String, dynamic> uploadResponse) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF06B6D4),
                    size: 30,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Analysis Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF06B6D4)),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Color(0xFF06B6D4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/results', extra: uploadResponse);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Results',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF06B6D4)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleVideoRecording() {
    if (!_isUploading) {
      context.go('/camera');
    }
  }
} 
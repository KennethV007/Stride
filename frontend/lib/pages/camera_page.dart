import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isRecording = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  int _recordingDuration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview (Mock)
            _buildCameraPreview(),
            
            // Top Controls
            _buildTopControls(),
            
            // Bottom Controls
            _buildBottomControls(),
            
            // Recording Timer
            if (_isRecording) _buildRecordingTimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F172A).withOpacity(0.8),
            const Color(0xFF1E293B).withOpacity(0.6),
            const Color(0xFF0F172A).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam,
              size: 80,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera Preview',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Camera functionality would be implemented here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.2),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.go('/upload'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          // Flash Toggle
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Recording Duration Indicator
          if (_isRecording)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'REC ${_formatDuration(_recordingDuration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          
          // Control Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera Flip Button
              GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              // Record Button
              GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isRecording
                      ? const Icon(
                          Icons.stop,
                          color: Colors.white,
                          size: 40,
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                ),
              ),
              
              // Empty space to maintain center alignment
              const SizedBox(width: 60),
            ],
          ),
          
          // Instructions
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Record 10-15 seconds of your running form\nTap the red button to start/stop recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingTimer() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingDuration = 0;
        _startRecordingTimer();
      } else {
        _stopRecordingAndProcess();
      }
    });
  }

  void _startRecordingTimer() {
    // Simulate recording timer
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration++;
        });
        _startRecordingTimer();
      }
    });
  }

  void _stopRecordingAndProcess() {
    // Simulate video processing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Video Recorded',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Video recorded successfully (${_formatDuration(_recordingDuration)})!\nProcessing and proceeding to results.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/results');
              },
              child: const Text(
                'Continue to Results',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Record Again',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 
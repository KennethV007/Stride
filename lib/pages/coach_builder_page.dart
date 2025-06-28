import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/gemini_service.dart';
import 'dart:typed_data';

class CoachBuilderPage extends StatefulWidget {
  const CoachBuilderPage({super.key});

  @override
  State<CoachBuilderPage> createState() => _CoachBuilderPageState();
}

class _CoachBuilderPageState extends State<CoachBuilderPage> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  int _totalSlides = 7; // Updated to include coach type selection slide + ninja personality slide
  bool _isGeneratingCoach = false;
  Uint8List? _generatedKnightImage;

  // Coach type selection
  String? _selectedCoachType;
  
  // User selections for Knight
  String? _selectedRegion;
  String? _selectedPersonality;
  String? _selectedWeapon;
  String? _selectedArmor;

  // User selections for other coach types (placeholder for now)
  Map<String, String?> _ninjaSelections = {
    'village': null,
    'weapon': null,
    'skill': null,
    'element': null,
    'personality': null,
  };
  Map<String, String?> _robotSelections = {};
  Map<String, String?> _mandalorianSelections = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < _totalSlides - 1) {
      // Check if current slide has a selection before proceeding
      if (_canProceedFromCurrentSlide()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showSelectionRequiredDialog();
      }
    } else {
      // On final slide, check if all selections are made
      if (_allSelectionsComplete()) {
        _finishCoachCreation();
      } else {
        _showIncompleteSelectionsDialog();
      }
    }
  }

  void _previousSlide() {
    if (_currentSlide > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedFromCurrentSlide() {
    switch (_currentSlide + 1) {
      case 1:
        return _selectedCoachType != null;
      case 2:
        if (_selectedCoachType == 'Knight') {
          return _selectedRegion != null;
        } else if (_selectedCoachType == 'Ninja') {
          return _ninjaSelections['village'] != null;
        }
        return true; // For other coach types, allow proceeding for now
      case 3:
        if (_selectedCoachType == 'Knight') {
          return _selectedPersonality != null;
        } else if (_selectedCoachType == 'Ninja') {
          return _ninjaSelections['weapon'] != null;
        }
        return true;
      case 4:
        if (_selectedCoachType == 'Knight') {
          return _selectedWeapon != null;
        } else if (_selectedCoachType == 'Ninja') {
          return _ninjaSelections['skill'] != null;
        }
        return true;
      case 5:
        if (_selectedCoachType == 'Knight') {
          return _selectedArmor != null;
        } else if (_selectedCoachType == 'Ninja') {
          return _ninjaSelections['element'] != null;
        }
        return true;
      case 6:
        if (_selectedCoachType == 'Ninja') {
          return _ninjaSelections['personality'] != null;
        }
        return _allSelectionsComplete();
      case 7:
        return _allSelectionsComplete();
      default:
        return true;
    }
  }

  bool _allSelectionsComplete() {
    if (_selectedCoachType == 'Knight') {
      return _selectedRegion != null &&
             _selectedPersonality != null &&
             _selectedWeapon != null &&
             _selectedArmor != null;
    } else if (_selectedCoachType == 'Ninja') {
      return _ninjaSelections['village'] != null &&
             _ninjaSelections['weapon'] != null &&
             _ninjaSelections['skill'] != null &&
             _ninjaSelections['element'] != null &&
             _ninjaSelections['personality'] != null;
    }
    // For other coach types, return true for now (placeholder)
    return true;
  }

  void _showSelectionRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Selection Required',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please make a selection before proceeding to the next slide.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIncompleteSelectionsDialog() {
    List<String> missing = [];
    if (_selectedRegion == null) missing.add('Origin');
    if (_selectedPersonality == null) missing.add('Personality');
    if (_selectedWeapon == null) missing.add('Weapon');
    if (_selectedArmor == null) missing.add('Armor');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Incomplete Selections',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Please complete the following selections: ${missing.join(', ')}',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishCoachCreation() async {
    // For non-Knight and non-Ninja coaches, show a coming soon dialog
    if (_selectedCoachType != 'Knight' && _selectedCoachType != 'Ninja') {
      _showComingSoonDialog();
      return;
    }

    setState(() {
      _isGeneratingCoach = true;
      _generatedKnightImage = null;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'Generating Your ${_selectedCoachType} Coach...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCoachType == 'Knight'
                  ? 'Creating a ${_selectedPersonality} knight from ${_selectedRegion}...'
                  : 'Creating a ${_ninjaSelections['personality']} ninja from ${_ninjaSelections['village']}...',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      Uint8List? imageBytes;
      
      if (_selectedCoachType == 'Knight') {
        // Generate the knight coach image
        imageBytes = await GeminiService.generateKnightCoachImage(
          region: _selectedRegion!,
          personality: _selectedPersonality!,
          weapon: _selectedWeapon!,
          armor: _selectedArmor!,
        );
      } else if (_selectedCoachType == 'Ninja') {
        // Generate the ninja coach image
        imageBytes = await GeminiService.generateNinjaCoachImage(
          village: _ninjaSelections['village']!,
          weapon: _ninjaSelections['weapon']!,
          skill: _ninjaSelections['skill']!,
          element: _ninjaSelections['element']!,
          personality: _ninjaSelections['personality']!,
        );
      }

      setState(() {
        _generatedKnightImage = imageBytes;
        _isGeneratingCoach = false;
      });

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show results
      if (_selectedCoachType == 'Knight') {
        _showKnightCoachResults();
      } else if (_selectedCoachType == 'Ninja') {
        _showNinjaCoachResults();
      }
    } catch (e) {
      setState(() {
        _isGeneratingCoach = false;
      });

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error dialog
      _showErrorDialog();
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCoachTypeIcon(_selectedCoachType!),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '$_selectedCoachType Coach Coming Soon!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re working hard to bring you $_selectedCoachType coaches with unique customization options and AI-powered generation.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedCoachType = null;
                      _selectedRegion = null;
                      _selectedPersonality = null;
                      _selectedWeapon = null;
                      _selectedArmor = null;
                      _ninjaSelections = {
                        'village': null,
                        'weapon': null,
                        'skill': null,
                        'element': null,
                        'personality': null,
                      };
                      _currentSlide = 0;
                      _generatedKnightImage = null;
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Try Knight Coach',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Return Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showKnightCoachResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏆 Your Knight Coach is Ready!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Display the generated image or a placeholder
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: _generatedKnightImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _generatedKnightImage!,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.purple.withOpacity(0.3), Colors.cyan.withOpacity(0.3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Image generation in progress...',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Show selections summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Knight\'s Attributes:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeRow('Origin', _selectedRegion!, _getRegionIcon(_selectedRegion!)),
                    _buildAttributeRow('Personality', _selectedPersonality!, _getPersonalityIcon(_selectedPersonality!)),
                    _buildAttributeRow('Weapon', _selectedWeapon!, _getWeaponIcon(_selectedWeapon!)),
                    _buildAttributeRow('Armor', _selectedArmor!, _getArmorIcon(_selectedArmor!)),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedCoachType = null;
                        _selectedRegion = null;
                        _selectedPersonality = null;
                        _selectedWeapon = null;
                        _selectedArmor = null;
                        _ninjaSelections = {
                          'village': null,
                          'weapon': null,
                          'skill': null,
                          'element': null,
                          'personality': null,
                        };
                        _currentSlide = 0;
                        _generatedKnightImage = null;
                      });
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Create Another',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Return Home',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNinjaCoachResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.75,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🥷 Your Ninja Coach is Ready!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Display the generated image or a placeholder
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: _generatedKnightImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _generatedKnightImage!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Colors.purple.withOpacity(0.3), Colors.cyan.withOpacity(0.3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  'Image generation in progress...',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(height: 12),
                
                // Show selections summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Ninja\'s Attributes:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildAttributeRow('Village', _ninjaSelections['village']!, _getNinjaVillageIcon(_ninjaSelections['village']!)),
                      _buildAttributeRow('Weapon', _ninjaSelections['weapon']!, _getNinjaWeaponIcon(_ninjaSelections['weapon']!)),
                      _buildAttributeRow('Skill', _ninjaSelections['skill']!, _getNinjaSkillIcon(_ninjaSelections['skill']!)),
                      _buildAttributeRow('Element', _ninjaSelections['element']!, _getNinjaElementIcon(_ninjaSelections['element']!)),
                      _buildAttributeRow('Personality', _ninjaSelections['personality']!, _getNinjaPersonalityIcon(_ninjaSelections['personality']!)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedCoachType = null;
                          _selectedRegion = null;
                          _selectedPersonality = null;
                          _selectedWeapon = null;
                          _selectedArmor = null;
                          _ninjaSelections = {
                            'village': null,
                            'weapon': null,
                            'skill': null,
                            'element': null,
                            'personality': null,
                          };
                          _currentSlide = 0;
                          _generatedKnightImage = null;
                        });
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Create Another',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Return Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text(
          'Generation Failed',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'We couldn\'t generate your knight coach image at this time. Please try again later.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  void _goToSlide(int index) {
    setState(() {
      _currentSlide = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          child: Column(
            children: [
              // Header with back button and title
              _buildHeader(),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              // Slideshow
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                  itemCount: _totalSlides,
                  itemBuilder: (context, index) {
                    return _buildSlide(index + 1);
                  },
                ),
              ),
              
              // Navigation controls
              _buildNavigationControls(),
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
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Build Your Knight Coach',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(_totalSlides, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _totalSlides - 1 ? 8.0 : 0.0,
              ),
              child: GestureDetector(
                onTap: () => _goToSlide(index),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index <= _currentSlide
                        ? const Color(0xFF8B5CF6)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlide(int slideNumber) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _getSlideContent(slideNumber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSlideContent(int slideNumber) {
    switch (slideNumber) {
      case 1:
        return _buildCoachTypeSlide();
      case 2:
        return _buildRegionSlide();
      case 3:
        return _buildPersonalitySlide();
      case 4:
        return _buildWeaponSlide();
      case 5:
        return _buildArmorSlide();
      case 6:
        return _buildFinalCustomizationSlide();
      case 7:
        return _buildSummarySlide();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCoachTypeSlide() {
    final coachTypes = [
      {'name': 'Knight', 'description': 'Medieval warrior with honor and strength', 'icon': '⚔️'},
      {'name': 'Ninja', 'description': 'Stealthy assassin with speed and precision', 'icon': '🥷'},
      {'name': 'Robot', 'description': 'Futuristic android with logic and efficiency', 'icon': '🤖'},
      {'name': 'Mandalorian', 'description': 'Bounty hunter with discipline and skill', 'icon': '🚀'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.person,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'Select Your Coach Type',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the type of coach that best fits your training style',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...coachTypes.map((type) => _buildChoiceButton(
          type['name']!,
          type['description']!,
          type['icon']!,
          _selectedCoachType == type['name'],
          () => setState(() => _selectedCoachType = type['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildRegionSlide() {
    // Only show this slide if Knight is selected
    if (_selectedCoachType == 'Ninja') {
      return _buildNinjaVillageSlide();
    } else if (_selectedCoachType != 'Knight') {
      return _buildPlaceholderSlide('Region Selection', 'This will be customized for $_selectedCoachType coaches');
    }
    
    final regions = [
      {'name': 'Drakethorne', 'description': 'volcanic warrior kingdom', 'icon': '🌋'},
      {'name': 'Sylvasteel', 'description': 'forest guardians of light', 'icon': '🌲'},
      {'name': 'Elaria', 'description': 'floating sky city of scholars', 'icon': '☁️'},
      {'name': 'Umbranox', 'description': 'shadows of the forgotten realm', 'icon': '🌑'},
      {'name': 'Cryomir', 'description': 'glacier battlegrounds of ice', 'icon': '❄️'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.public,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'Where is your knight from?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose a mystical realm that shapes your knight\'s origin',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...regions.map((region) => _buildChoiceButton(
          region['name']!,
          region['description']!,
          region['icon']!,
          _selectedRegion == region['name'],
          () => setState(() => _selectedRegion = region['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildPersonalitySlide() {
    // Only show this slide if Knight is selected
    if (_selectedCoachType == 'Ninja') {
      return _buildNinjaWeaponSlide();
    } else if (_selectedCoachType != 'Knight') {
      return _buildPlaceholderSlide('Personality Selection', 'This will be customized for $_selectedCoachType coaches');
    }
    
    final personalities = [
      {'name': 'Wise', 'description': 'offers patient, thoughtful advice', 'icon': '🧙‍♂️'},
      {'name': 'Fearless', 'description': 'motivates with intensity and boldness', 'icon': '⚔️'},
      {'name': 'Playful', 'description': 'light-hearted and humorous', 'icon': '😄'},
      {'name': 'Mysterious', 'description': 'cryptic and poetic', 'icon': '🔮'},
      {'name': 'Noble', 'description': 'honorable and inspiring', 'icon': '👑'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.psychology,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What is your knight\'s personality?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'This will shape how your coach communicates with you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...personalities.map((personality) => _buildChoiceButton(
          personality['name']!,
          personality['description']!,
          personality['icon']!,
          _selectedPersonality == personality['name'],
          () => setState(() => _selectedPersonality = personality['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildWeaponSlide() {
    // Only show this slide if Knight is selected
    if (_selectedCoachType == 'Ninja') {
      return _buildNinjaSkillSlide();
    } else if (_selectedCoachType != 'Knight') {
      return _buildPlaceholderSlide('Weapon Selection', 'This will be customized for $_selectedCoachType coaches');
    }
    
    final weapons = [
      {'name': 'Sword', 'description': 'classic and balanced', 'icon': '🗡️'},
      {'name': 'Spear', 'description': 'strategic and agile', 'icon': '🪙'},
      {'name': 'Warhammer', 'description': 'powerful and brutal', 'icon': '🔨'},
      {'name': 'Bow & Arrows', 'description': 'precise and swift', 'icon': '🏹'},
      {'name': 'Arcane Staff', 'description': 'mystical and wise', 'icon': '🪄'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.sports_martial_arts,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What weapon does your knight wield?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the weapon that represents your training style',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...weapons.map((weapon) => _buildChoiceButton(
          weapon['name']!,
          weapon['description']!,
          weapon['icon']!,
          _selectedWeapon == weapon['name'],
          () => setState(() => _selectedWeapon = weapon['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildArmorSlide() {
    // Only show this slide if Knight is selected
    if (_selectedCoachType == 'Ninja') {
      return _buildNinjaElementSlide();
    } else if (_selectedCoachType != 'Knight') {
      return _buildPlaceholderSlide('Armor Selection', 'This will be customized for $_selectedCoachType coaches');
    }
    
    final armors = [
      {'name': 'Goldenplate', 'description': 'regal, shining, commanding', 'icon': '✨'},
      {'name': 'Crystalline', 'description': 'sparkling, magical, elegant', 'icon': '💠'},
      {'name': 'Shadowsteel', 'description': 'stealthy, edgy, intimidating', 'icon': '🌑'},
      {'name': 'Naturehide', 'description': 'organic, grounded, mythical', 'icon': '🍃'},
      {'name': 'Emberforged', 'description': 'molten, rough, battle-worn', 'icon': '🔥'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.shield,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What is your knight\'s armor theme?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select the armor style that matches your aesthetic',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...armors.map((armor) => _buildChoiceButton(
          armor['name']!,
          armor['description']!,
          armor['icon']!,
          _selectedArmor == armor['name'],
          () => setState(() => _selectedArmor = armor['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildPlaceholderSlide(String title, String description) {
    return Column(
      children: [
        const Icon(
          Icons.construction,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Text(
            'Coming Soon!\n\nThis coach type will have its own unique customization options.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalCustomizationSlide() {
    if (_selectedCoachType == 'Ninja') {
      return _buildNinjaPersonalitySlide();
    } else if (_selectedCoachType == 'Knight') {
      // For knights, this slide is not needed, so show a transition message
      return Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF8B5CF6),
            size: 48,
          ),
          const SizedBox(height: 24),
          const Text(
            'Knight Customization Complete!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your knight is ready to be generated',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
            ),
            child: const Text(
              '⚔️ Your knight coach is ready!\n\nProceed to the next slide to review your selections and generate your personalized knight.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const Icon(
            Icons.construction,
            color: Color(0xFF8B5CF6),
            size: 48,
          ),
          const SizedBox(height: 24),
          Text(
            'Final $_selectedCoachType Customization',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This will be customized for $_selectedCoachType coaches',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Text(
              'Coming Soon!\n\nThis coach type will have its own unique final customization step.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNinjaPersonalitySlide() {
    final personalities = [
      {'name': 'Calm and calculated', 'description': 'strategic and thoughtful approach', 'icon': '🧘'},
      {'name': 'Mischievous and sly', 'description': 'playful with cunning tactics', 'icon': '😏'},
      {'name': 'Honorable and disciplined', 'description': 'follows the ancient code', 'icon': '🙏'},
      {'name': 'Cold and ruthless', 'description': 'efficiency above all else', 'icon': '🥶'},
      {'name': 'Loyal and protective', 'description': 'devoted to those they serve', 'icon': '🛡️'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.psychology,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What kind of personality does your ninja have?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'This will shape how your ninja coach communicates and motivates you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...personalities.map((personality) => _buildChoiceButton(
          personality['name']!,
          personality['description']!,
          personality['icon']!,
          _ninjaSelections['personality'] == personality['name'],
          () => setState(() => _ninjaSelections['personality'] = personality['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildSummarySlide() {
    return Column(
      children: [
        const Icon(
          Icons.auto_awesome,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        Text(
          'Your ${_selectedCoachType ?? 'Coach'}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _selectedCoachType == 'Knight' 
              ? 'Ready to generate your personalized knight coach!'
              : _selectedCoachType == 'Ninja'
                  ? 'Ready to generate your personalized ninja coach!'
                  : 'Ready to generate your personalized $_selectedCoachType coach!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        _buildSummaryCard('Coach Type', _selectedCoachType ?? 'Not selected', _getCoachTypeIcon(_selectedCoachType ?? '')),
        if (_selectedCoachType == 'Knight') ...[
          _buildSummaryCard('Origin', _selectedRegion ?? 'Not selected', '🏰'),
          _buildSummaryCard('Personality', _selectedPersonality ?? 'Not selected', '💭'),
          _buildSummaryCard('Weapon', _selectedWeapon ?? 'Not selected', '⚔️'),
          _buildSummaryCard('Armor', _selectedArmor ?? 'Not selected', '🛡️'),
        ] else if (_selectedCoachType == 'Ninja') ...[
          _buildSummaryCard('Village', _ninjaSelections['village'] ?? 'Not selected', '🏘️'),
          _buildSummaryCard('Weapon', _ninjaSelections['weapon'] ?? 'Not selected', '🗡️'),
          _buildSummaryCard('Skill', _ninjaSelections['skill'] ?? 'Not selected', '🥷'),
          _buildSummaryCard('Element', _ninjaSelections['element'] ?? 'Not selected', '⚡'),
          _buildSummaryCard('Personality', _ninjaSelections['personality'] ?? 'Not selected', '😊'),
        ] else ...[
          _buildSummaryCard('Customization 1', 'Coming Soon', '🔧'),
          _buildSummaryCard('Customization 2', 'Coming Soon', '🔧'),
          _buildSummaryCard('Customization 3', 'Coming Soon', '🔧'),
          _buildSummaryCard('Customization 4', 'Coming Soon', '🔧'),
        ],
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
            ),
          ),
          child: Text(
            _selectedCoachType == 'Knight'
                ? 'Gemini AI will generate your unique knight coach image based on your selections!'
                : _selectedCoachType == 'Ninja'
                    ? 'Your ninja coach will be available soon with AI-powered generation!'
                    : 'Your $_selectedCoachType coach will be available soon with AI-powered generation!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String title, String description, String icon, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF8B5CF6)
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          SizedBox(
            width: 100,
            child: _currentSlide > 0
                ? ElevatedButton(
                    onPressed: _previousSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Previous'),
                  )
                : const SizedBox(),
          ),
          
          // Slide indicator
          Text(
            '${_currentSlide + 1} of $_totalSlides',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          // Next button
          SizedBox(
            width: 100,
            child: _currentSlide < _totalSlides - 1
                ? ElevatedButton(
                    onPressed: _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next'),
                  )
                : ElevatedButton(
                    onPressed: _isGeneratingCoach ? null : _finishCoachCreation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isGeneratingCoach 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Generate'),
                  ),
          ),
        ],
      ),
    );
  }

  String _getRegionIcon(String region) {
    switch (region) {
      case 'Drakethorne':
        return '🌋';
      case 'Sylvasteel':
        return '🌲';
      case 'Elaria':
        return '☁️';
      case 'Umbranox':
        return '🌑';
      case 'Cryomir':
        return '❄️';
      default:
        return '🏰';
    }
  }

  String _getPersonalityIcon(String personality) {
    switch (personality) {
      case 'Wise':
        return '🧙‍♂️';
      case 'Fearless':
        return '⚔️';
      case 'Playful':
        return '😄';
      case 'Mysterious':
        return '🔮';
      case 'Noble':
        return '👑';
      default:
        return '💭';
    }
  }

  String _getWeaponIcon(String weapon) {
    switch (weapon) {
      case 'Sword':
        return '🗡️';
      case 'Spear':
        return '🪙';
      case 'Warhammer':
        return '🔨';
      case 'Bow & Arrows':
        return '🏹';
      case 'Arcane Staff':
        return '🪄';
      default:
        return '⚔️';
    }
  }

  String _getArmorIcon(String armor) {
    switch (armor) {
      case 'Goldenplate':
        return '✨';
      case 'Crystalline':
        return '💠';
      case 'Shadowsteel':
        return '🌑';
      case 'Naturehide':
        return '🍃';
      case 'Emberforged':
        return '🔥';
      default:
        return '🛡️';
    }
  }

  Widget _buildAttributeRow(String label, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getCoachTypeIcon(String coachType) {
    switch (coachType) {
      case 'Knight':
        return '⚔️';
      case 'Ninja':
        return '🥷';
      case 'Robot':
        return '🤖';
      case 'Mandalorian':
        return '🚀';
      default:
        return '🏰';
    }
  }

  // Ninja slideshow methods
  Widget _buildNinjaVillageSlide() {
    final villages = [
      {'name': 'Shadowleaf', 'description': 'stealth and darkness', 'icon': '🌿'},
      {'name': 'Emberclan', 'description': 'fiery assassins', 'icon': '🔥'},
      {'name': 'Mistveil', 'description': 'illusion masters', 'icon': '🌫️'},
      {'name': 'Stormspire', 'description': 'speed and thunder', 'icon': '⛈️'},
      {'name': 'Bloomfang', 'description': 'nature-blending spies', 'icon': '🌸'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.location_city,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What is your ninja\'s origin village?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the hidden village that trained your ninja',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...villages.map((village) => _buildChoiceButton(
          village['name']!,
          village['description']!,
          village['icon']!,
          _ninjaSelections['village'] == village['name'],
          () => setState(() => _ninjaSelections['village'] = village['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildNinjaWeaponSlide() {
    final weapons = [
      {'name': 'Twin daggers', 'description': 'dual-wielding precision', 'icon': '🗡️'},
      {'name': 'Throwing stars (shuriken)', 'description': 'ranged accuracy', 'icon': '⭐'},
      {'name': 'Smoke bombs & traps', 'description': 'tactical deception', 'icon': '💣'},
      {'name': 'Katana', 'description': 'traditional honor blade', 'icon': '⚔️'},
      {'name': 'Poison-tipped darts', 'description': 'silent elimination', 'icon': '🎯'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.sports_martial_arts,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What is your ninja\'s preferred weapon?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select the weapon that defines your combat style',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...weapons.map((weapon) => _buildChoiceButton(
          weapon['name']!,
          weapon['description']!,
          weapon['icon']!,
          _ninjaSelections['weapon'] == weapon['name'],
          () => setState(() => _ninjaSelections['weapon'] = weapon['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildNinjaSkillSlide() {
    final skills = [
      {'name': 'Invisibility', 'description': 'vanish from sight completely', 'icon': '👻'},
      {'name': 'Speed and agility', 'description': 'lightning-fast movement', 'icon': '💨'},
      {'name': 'Mind control', 'description': 'influence thoughts and actions', 'icon': '🧠'},
      {'name': 'Disguise and mimicry', 'description': 'become anyone, anywhere', 'icon': '🎭'},
      {'name': 'Silent takedowns', 'description': 'eliminate without a sound', 'icon': '🤫'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.psychology,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What is your ninja\'s skill specialty?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose your ninja\'s unique mastery',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...skills.map((skill) => _buildChoiceButton(
          skill['name']!,
          skill['description']!,
          skill['icon']!,
          _ninjaSelections['skill'] == skill['name'],
          () => setState(() => _ninjaSelections['skill'] = skill['name']),
        )).toList(),
      ],
    );
  }

  Widget _buildNinjaElementSlide() {
    final elements = [
      {'name': 'Fire', 'description': 'bold & destructive', 'icon': '🔥'},
      {'name': 'Water', 'description': 'fluid & evasive', 'icon': '💧'},
      {'name': 'Wind', 'description': 'swift & precise', 'icon': '🌪️'},
      {'name': 'Shadow', 'description': 'deceptive & silent', 'icon': '🌑'},
      {'name': 'Lightning', 'description': 'fast & aggressive', 'icon': '⚡'},
    ];

    return Column(
      children: [
        const Icon(
          Icons.auto_awesome,
          color: Color(0xFF8B5CF6),
          size: 48,
        ),
        const SizedBox(height: 24),
        const Text(
          'What element guides your ninja\'s path?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select the elemental force that empowers your ninja',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        ...elements.map((element) => _buildChoiceButton(
          element['name']!,
          element['description']!,
          element['icon']!,
          _ninjaSelections['element'] == element['name'],
          () => setState(() => _ninjaSelections['element'] = element['name']),
        )).toList(),
      ],
    );
  }

  String _getNinjaVillageIcon(String village) {
    switch (village) {
      case 'Shadowleaf':
        return '🌿';
      case 'Emberclan':
        return '🔥';
      case 'Mistveil':
        return '🌫️';
      case 'Stormspire':
        return '⛈️';
      case 'Bloomfang':
        return '🌸';
      default:
        return '🏘️';
    }
  }

  String _getNinjaWeaponIcon(String weapon) {
    switch (weapon) {
      case 'Twin daggers':
        return '🗡️';
      case 'Throwing stars (shuriken)':
        return '⭐';
      case 'Smoke bombs & traps':
        return '💣';
      case 'Katana':
        return '⚔️';
      case 'Poison-tipped darts':
        return '🎯';
      default:
        return '🗡️';
    }
  }

  String _getNinjaSkillIcon(String skill) {
    switch (skill) {
      case 'Invisibility':
        return '👻';
      case 'Speed and agility':
        return '💨';
      case 'Mind control':
        return '🧠';
      case 'Disguise and mimicry':
        return '🎭';
      case 'Silent takedowns':
        return '🤫';
      default:
        return '🥷';
    }
  }

  String _getNinjaElementIcon(String element) {
    switch (element) {
      case 'Fire':
        return '🔥';
      case 'Water':
        return '💧';
      case 'Wind':
        return '🌪️';
      case 'Shadow':
        return '🌑';
      case 'Lightning':
        return '⚡';
      default:
        return '⚡';
    }
  }

  String _getNinjaPersonalityIcon(String personality) {
    switch (personality) {
      case 'Calm and calculated':
        return '🧘';
      case 'Mischievous and sly':
        return '😏';
      case 'Honorable and disciplined':
        return '🙏';
      case 'Cold and ruthless':
        return '🥶';
      case 'Loyal and protective':
        return '🛡️';
      default:
        return '😊';
    }
  }
} 
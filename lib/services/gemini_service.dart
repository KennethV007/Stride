import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyDGHhVbNfjMc12koidU_t-XBFM5i5mXtUU';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent';

  static Future<Uint8List?> generateKnightCoachImage({
    required String region,
    required String personality,
    required String weapon,
    required String armor,
  }) async {
    try {
      // Create a detailed prompt for the knight coach image
      final prompt = _buildKnightPrompt(region, personality, weapon, armor);
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['TEXT', 'IMAGE'],
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Look for image data in the response parts
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null) {
            for (final part in parts) {
              if (part['inlineData'] != null) {
                final imageData = part['inlineData']['data'] as String;
                return base64Decode(imageData);
              }
            }
          }
        }
        
        print('No image data found in response');
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating knight coach image: $e');
      return null;
    }
  }

  static String _buildKnightPrompt(String region, String personality, String weapon, String armor) {
    // Map regions to visual descriptions
    final regionDescriptions = {
      'Drakethorne': 'volcanic landscape with molten lava flows, dark rocky terrain, and fiery red skies',
      'Sylvasteel': 'mystical forest with ancient trees, glowing light filtering through leaves, and ethereal green atmosphere',
      'Elaria': 'floating sky city with clouds, celestial architecture, and bright azure blue skies',
      'Umbranox': 'shadowy realm with dark mists, mysterious silhouettes, and purple-black atmosphere',
      'Cryomir': 'frozen tundra with ice crystals, snow-covered mountains, and cold blue-white lighting',
    };

    // Map personalities to visual traits
    final personalityTraits = {
      'Wise': 'calm, serene expression with ancient wisdom in their eyes, peaceful stance',
      'Fearless': 'bold, confident posture with fierce determination, ready for battle stance',
      'Playful': 'friendly, approachable demeanor with a slight smile, relaxed posture',
      'Mysterious': 'enigmatic presence with partially shadowed face, intriguing aura',
      'Noble': 'regal bearing with proud stance, honorable and inspiring presence',
    };

    // Map weapons to descriptions
    final weaponDescriptions = {
      'Sword': 'gleaming sword with intricate hilt design',
      'Spear': 'elegant spear with ornate blade and detailed shaft',
      'Warhammer': 'massive warhammer with runic engravings',
      'Bow & Arrows': 'masterfully crafted bow with a quiver of arrows',
      'Arcane Staff': 'mystical staff glowing with magical energy',
    };

    // Map armor to descriptions
    final armorDescriptions = {
      'Goldenplate': 'shining golden plate armor with royal engravings',
      'Crystalline': 'armor made of sparkling crystals that reflect light beautifully',
      'Shadowsteel': 'dark, sleek armor with sharp edges and intimidating design',
      'Naturehide': 'organic armor made from natural materials with earthy textures',
      'Emberforged': 'battle-worn armor with glowing ember-like accents',
    };

    return '''
Create a detailed fantasy knight coach character portrait with these specific attributes:

ORIGIN: From $region - ${regionDescriptions[region]}
PERSONALITY: $personality - ${personalityTraits[personality]}
WEAPON: Wielding a ${weaponDescriptions[weapon]}
ARMOR: Wearing ${armorDescriptions[armor]}

The knight should be:
- A heroic, inspiring figure that would motivate runners and athletes
- Always wearing a helmet that matches their armor style and origin
- Shown as a portrait from the chest/shoulders up (head and upper torso only)
- Standing in a confident, coaching pose with upper body visible
- Set against a background that reflects their $region origin
- Detailed fantasy art style with vibrant colors
- Professional and motivational appearance suitable for a fitness coach
- The overall composition should feel empowering and encouraging
- Portrait orientation focusing on the helmeted face and upper armor details

Style: High-quality fantasy portrait art, detailed character design, inspiring and motivational atmosphere, chest-up composition, knight must be wearing a helmet.
''';
  }

  // Legacy method for text descriptions (keeping for backward compatibility)
  static Future<String?> generateKnightCoachDescription({
    required String region,
    required String personality,
    required String weapon,
    required String armor,
  }) async {
    try {
      // For text descriptions, use the standard model
      final textPrompt = _buildKnightPrompt(region, personality, weapon, armor);
      
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': textPrompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating knight coach description: $e');
      return null;
    }
  }

  static Future<Uint8List?> generateNinjaCoachImage({
    required String village,
    required String weapon,
    required String skill,
    required String element,
    required String personality,
  }) async {
    try {
      // Create a detailed prompt for the ninja coach image
      final prompt = _buildNinjaPrompt(village, weapon, skill, element, personality);
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['TEXT', 'IMAGE'],
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Look for image data in the response parts
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null) {
            for (final part in parts) {
              if (part['inlineData'] != null) {
                final imageData = part['inlineData']['data'] as String;
                return base64Decode(imageData);
              }
            }
          }
        }
        
        print('No image data found in response');
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating ninja coach image: $e');
      return null;
    }
  }

  static String _buildNinjaPrompt(String village, String weapon, String skill, String element, String personality) {
    // Map villages to visual descriptions
    final villageDescriptions = {
      'Shadowleaf': 'hidden village in dark forest with shadowy trees, mysterious fog, and subtle moonlight filtering through leaves',
      'Emberclan': 'village built around volcanic terrain with glowing embers, warm orange lighting, and fire-themed architecture',
      'Mistveil': 'ethereal village shrouded in mystical mist with floating elements and dreamlike atmosphere',
      'Stormspire': 'mountain village with lightning storms, dramatic clouds, and electric blue energy in the air',
      'Bloomfang': 'nature-integrated village with blooming flowers, vines, and organic structures blending with the environment',
    };

    // Map personalities to visual traits
    final personalityTraits = {
      'Calm and calculated': 'serene, focused expression with strategic eyes, composed and thoughtful posture',
      'Mischievous and sly': 'cunning smile with clever eyes, playful yet dangerous demeanor',
      'Honorable and disciplined': 'noble bearing with respectful stance, traditional and dignified presence',
      'Cold and ruthless': 'intense, piercing gaze with emotionless expression, intimidating aura',
      'Loyal and protective': 'determined, caring expression with protective stance, trustworthy presence',
    };

    // Map weapons to descriptions
    final weaponDescriptions = {
      'Twin daggers': 'dual curved daggers with intricate handles, crossed or ready for dual-wielding',
      'Throwing stars (shuriken)': 'collection of gleaming shuriken with sharp edges and perfect balance',
      'Smoke bombs & traps': 'tactical gear with smoke bombs and various ninja tools',
      'Katana': 'traditional katana with ornate tsuba and perfectly balanced blade',
      'Poison-tipped darts': 'blowgun with specialized darts, precise and deadly',
    };

    // Map skills to visual effects
    final skillEffects = {
      'Invisibility': 'subtle transparency effect with fading edges, partially visible silhouette',
      'Speed and agility': 'motion blur effects with dynamic pose suggesting swift movement',
      'Mind control': 'mystical energy around the head with hypnotic patterns in the eyes',
      'Disguise and mimicry': 'subtle face-changing effects with multiple identity hints',
      'Silent takedowns': 'stealthy pose with shadow effects and complete silence aura',
    };

    // Map elements to visual effects
    final elementalEffects = {
      'Fire': 'flames dancing around the ninja with warm red-orange energy',
      'Water': 'flowing water effects with blue-cyan energy and fluid movements',
      'Wind': 'swirling air currents with green-white energy and leaves in motion',
      'Shadow': 'dark energy with purple-black shadows extending from the ninja',
      'Lightning': 'electric bolts with bright yellow-blue energy crackling around them',
    };

    return '''
Create a detailed ninja coach character portrait with these specific attributes:

ORIGIN VILLAGE: From $village - ${villageDescriptions[village]}
PERSONALITY: $personality - ${personalityTraits[personality]}
PREFERRED WEAPON: ${weaponDescriptions[weapon]}
SKILL SPECIALTY: $skill - ${skillEffects[skill]}
ELEMENTAL PATH: $element - ${elementalEffects[element]}

The ninja should be:
- A skilled, inspiring figure that would motivate runners and athletes
- Always wearing a traditional ninja mask/hood that covers most of the face, showing only the eyes
- Shown as a portrait from the chest/shoulders up (head and upper torso only)
- Standing in a confident, coaching pose with upper body visible
- Set against a background that reflects their $village origin
- Detailed anime/manga art style with vibrant colors and elemental effects
- Professional and motivational appearance suitable for a fitness coach
- The overall composition should feel empowering and stealthy
- Portrait orientation focusing on the masked face and upper ninja outfit details
- Incorporate $element elemental effects subtly around the ninja
- Show hints of their $weapon weapon
- Display their $skill specialty through visual effects

Style: High-quality anime/manga ninja portrait art, detailed character design, inspiring and mysterious atmosphere, chest-up composition, ninja must be wearing a traditional mask covering most of the face with only eyes visible.
''';
  }
} 
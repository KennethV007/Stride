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

  static Future<Uint8List?> generateRobotCoachImage({
    required String lab,
    required String function,
    required String emotions,
    required String power,
    required String personality,
  }) async {
    try {
      // Create a detailed prompt for the robot coach image
      final prompt = _buildRobotPrompt(lab, function, emotions, power, personality);
      
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
      print('Error generating robot coach image: $e');
      return null;
    }
  }

  static String _buildRobotPrompt(String lab, String function, String emotions, String power, String personality) {
    // Map labs to visual descriptions
    final labDescriptions = {
      'CoreSys AI Labs': 'high-tech military facility with steel and gunmetal gray design, tactical interfaces, and combat-ready aesthetics',
      'NovaTek Robotics': 'sleek civilian laboratory with white and blue colors, friendly interfaces, and approachable design',
      'IonForge': 'experimental research facility with glowing energy cores, plasma effects, and cutting-edge technology',
      'SkyMind': 'neural cybernetics lab with brain-like patterns, neural networks, and consciousness-focused design',
      'Scrapborn': 'makeshift workshop with recycled parts, mismatched components, and creative engineering solutions',
    };

    // Map functions to visual traits
    final functionTraits = {
      'Battle command unit': 'military-grade armor with tactical displays, command interfaces, and strategic positioning systems',
      'Personal AI assistant': 'sleek, approachable design with helpful interface screens and friendly body language',
      'Stealth reconnaissance': 'streamlined, dark chassis with sensor arrays, camouflage capabilities, and surveillance equipment',
      'Data analytics and hacking': 'multiple holographic displays, data streams, and advanced computational interfaces',
      'Heavy-duty defense droid': 'robust, armored construction with defensive systems and protective stance',
    };

    // Map emotions to visual effects
    final emotionEffects = {
      'Fully logical — no emotions': 'cold, calculating LED eyes with analytical displays and purely functional expression',
      'Mimics human empathy': 'warm, expressive LED eyes with subtle emotional indicators and caring facial features',
      'Glitches with random emotions': 'flickering displays with unstable emotional expressions and chaotic visual effects',
      'Programmed compassion': 'gentle, caring LED eyes with soft blue lighting and nurturing design elements',
      'Malfunctions under stress': 'warning indicators and error messages with stressed visual effects and system alerts',
    };

    // Map power sources to visual effects
    final powerEffects = {
      'Nuclear core': 'glowing atomic symbol with radioactive energy effects and nuclear power indicators',
      'Solar array': 'solar panel arrays with bright yellow energy collection and sustainable power displays',
      'Fusion battery': 'compact energy cells with blue-white fusion reactions and high-tech power systems',
      'Unknown energy source': 'mysterious glowing core with unknown energy patterns and enigmatic power displays',
      'Magic-tech hybrid': 'mystical energy combined with technology, arcane symbols mixed with circuits',
    };

    // Map personalities to behavioral traits
    final personalityTraits = {
      'Sarcastic': 'witty expression with slightly tilted head, eye-roll indicators, and clever interface displays',
      'Supportive': 'encouraging posture with motivational displays, positive energy, and helpful gestures',
      'Ruthless': 'intimidating stance with cold efficiency displays, no-nonsense expression, and aggressive positioning',
      'Nerdy/curious': 'inquisitive head tilt with data analysis displays, curious LED patterns, and research interfaces',
      'Heroic and loyal': 'noble bearing with protective stance, honor displays, and steadfast positioning',
    };

    return '''
Create a detailed robot coach character portrait with these specific attributes:

ORIGIN LAB: Created by $lab - ${labDescriptions[lab]}
MAIN FUNCTION: $function - ${functionTraits[function]}
EMOTION PROCESSING: $emotions - ${emotionEffects[emotions]}
POWER SOURCE: $power - ${powerEffects[power]}
PERSONALITY MODULE: $personality - ${personalityTraits[personality]}

The robot should be:
- A futuristic, inspiring AI coach that would motivate runners and athletes
- Shown as a portrait from the chest/shoulders up (head and upper torso only)
- Standing in a confident, coaching pose with upper body visible
- Set against a high-tech background that reflects their $lab origin
- Detailed sci-fi art style with vibrant technological colors and effects
- Professional and motivational appearance suitable for a fitness coach
- The overall composition should feel empowering and technologically advanced
- Portrait orientation focusing on the robotic face and upper chassis details
- Display their $power power source through visual energy effects
- Show their $emotions emotional processing through facial displays
- Incorporate design elements that reflect their $function primary function
- Express their $personality personality through posture and interface displays
- Include holographic or LED displays showing motivational fitness data
- Modern, sleek robotic design with advanced AI coaching capabilities

Style: High-quality sci-fi robot portrait art, detailed character design, inspiring and futuristic atmosphere, chest-up composition, advanced AI coach with technological interfaces and motivational presence.
''';
  }

  static Future<Uint8List?> generateMandalorianCoachImage({
    required String region,
    required String weapon,
    required String armor,
    required String motivation,
    required String warriorType,
  }) async {
    try {
      // Create a detailed prompt for the Mandalorian coach image
      final prompt = _buildMandalorianPrompt(region, weapon, armor, motivation, warriorType);
      
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
      print('Error generating Mandalorian coach image: $e');
      return null;
    }
  }

  static String _buildMandalorianPrompt(String region, String weapon, String armor, String motivation, String warriorType) {
    // Map regions to visual descriptions
    final regionDescriptions = {
      'Desert Wastes': 'harsh desert landscape with sand dunes, rocky outcrops, and scorching sun effects',
      'Sky Bastion': 'floating aerial fortress with clouds, wind currents, and high-altitude atmosphere',
      'Outer Rim': 'remote space frontier with distant stars, asteroid fields, and frontier outpost aesthetics',
      'Iron Hills': 'militaristic mountain fortress with metallic structures, defensive positions, and industrial elements',
      'Frozen Canyons': 'ice-covered canyon terrain with glacial formations, frost effects, and cold blue lighting',
    };

    // Map weapons to visual descriptions
    final weaponDescriptions = {
      'Blaster rifle': 'advanced energy rifle with tactical scope and precision targeting systems',
      'Wrist rockets': 'wrist-mounted rocket launchers with explosive projectile systems',
      'Vibroblade': 'high-frequency vibrating sword with energy-enhanced cutting edge',
      'Grapple wire': 'retractable grappling hook system with tactical deployment gear',
      'Jetpack flamethrower': 'jetpack-integrated flamethrower with aerial combat capabilities',
    };

    // Map armor materials to visual effects
    final armorEffects = {
      'Beskar steel': 'legendary silver-gray Mandalorian metal with distinctive shine and battle-tested durability',
      'Phantom alloy': 'semi-transparent lightweight material with stealth-like shimmer effects',
      'Scarhide plating': 'battle-scarred armor with visible damage marks and weathered durability',
      'Plasma-infused glass': 'translucent armor with glowing plasma energy coursing through transparent sections',
      'Reclaimed scrap metal': 'makeshift armor assembled from various salvaged metal pieces with creative engineering',
    };

    // Map motivations to behavioral traits
    final motivationTraits = {
      'Honor and legacy': 'noble bearing with ancestral pride, honorable stance, and traditional Mandalorian symbols',
      'Revenge': 'intense, focused expression with determined posture and vengeful energy',
      'Glory and fame': 'confident, heroic stance with legendary presence and achievement displays',
      'Protecting the innocent': 'protective posture with caring determination and guardian-like presence',
      'Collecting the bounty': 'calculating hunter expression with tactical awareness and professional demeanor',
    };

    // Map warrior types to visual characteristics
    final warriorTypeTraits = {
      'Lone wolf sniper': 'solitary stance with precision rifle and focused, patient expression',
      'Tactician and squad leader': 'commanding presence with tactical displays and leadership posture',
      'Relentless tracker': 'alert, hunting stance with tracking equipment and determined pursuit energy',
      'Gadget-based saboteur': 'tech-savvy appearance with various gadgets and infiltration equipment',
      'Noble defender of the creed': 'traditional Mandalorian stance with ceremonial elements and honor symbols',
    };

    return '''
Create a detailed Mandalorian coach character portrait with these specific attributes:

ORIGIN REGION: From $region - ${regionDescriptions[region]}
PRIMARY WEAPON: Wielding ${weaponDescriptions[weapon]}
ARMOR MATERIAL: Made of $armor - ${armorEffects[armor]}
WARRIOR MOTIVATION: $motivation - ${motivationTraits[motivation]}
WARRIOR TYPE: $warriorType - ${warriorTypeTraits[warriorType]}

The Mandalorian should be:
- A skilled, inspiring warrior coach that would motivate runners and athletes
- Always wearing the iconic Mandalorian helmet with T-shaped visor
- Shown as a portrait from the chest/shoulders up (head and upper torso only)
- Standing in a confident, coaching pose with upper body visible
- Set against a background that reflects their $region origin
- Detailed Star Wars-style art with authentic Mandalorian aesthetics
- Professional and motivational appearance suitable for a fitness coach
- The overall composition should feel empowering and disciplined
- Portrait orientation focusing on the helmeted face and upper armor details
- Display their $armor armor material through realistic textures and effects
- Show their $weapon weapon prominently in the composition
- Express their $motivation motivation through posture and stance
- Incorporate visual elements that reflect their $warriorType fighting style
- Include subtle Mandalorian cultural symbols and clan markings
- Authentic Mandalorian armor design with weathering and battle history

Style: High-quality Star Wars Mandalorian portrait art, detailed character design, inspiring and disciplined atmosphere, chest-up composition, authentic Mandalorian warrior with traditional helmet and armor.
''';
  }
} 
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class CoachData {
  final String type;
  final Map<String, String> attributes;
  final List<int>? imageBytes;
  final DateTime createdAt;

  CoachData({
    required this.type,
    required this.attributes,
    this.imageBytes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'attributes': attributes,
      'imageBytes': imageBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CoachData fromJson(Map<String, dynamic> json) {
    return CoachData(
      type: json['type'],
      attributes: Map<String, String>.from(json['attributes']),
      imageBytes: json['imageBytes'] != null ? List<int>.from(json['imageBytes']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Uint8List? get imageAsBytes {
    return imageBytes != null ? Uint8List.fromList(imageBytes!) : null;
  }
}

class CoachStorageService {
  static const String _coachKey = 'saved_coach';

  static Future<void> saveCoach(CoachData coach) async {
    final prefs = await SharedPreferences.getInstance();
    final coachJson = json.encode(coach.toJson());
    await prefs.setString(_coachKey, coachJson);
  }

  static Future<CoachData?> loadCoach() async {
    final prefs = await SharedPreferences.getInstance();
    final coachJson = prefs.getString(_coachKey);
    
    if (coachJson == null) return null;
    
    try {
      final coachMap = json.decode(coachJson);
      return CoachData.fromJson(coachMap);
    } catch (e) {
      // If there's an error parsing, clear the stored data
      await clearCoach();
      return null;
    }
  }

  static Future<void> clearCoach() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coachKey);
  }

  static Future<bool> hasCoach() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_coachKey);
  }
} 
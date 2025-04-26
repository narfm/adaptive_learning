import 'package:flutter/material.dart';

/// Model class for storing user profile information based on age/grade selection
class UserProfile {
  final int? age;
  final String? grade;
  final String uiLevel;
  final String difficultyProfile;
  final bool isParentTeacherMode;

  UserProfile({
    this.age,
    this.grade,
    required this.uiLevel,
    required this.difficultyProfile,
    this.isParentTeacherMode = false,
  });

  /// Factory method to determine UI level and difficulty based on age
  factory UserProfile.fromAge(int age) {
    String uiLevel;
    String difficultyProfile;
    
    if (age >= 5 && age <= 7) {
      uiLevel = 'young';
      difficultyProfile = 'early-elementary';
    } else if (age >= 8 && age <= 10) {
      uiLevel = 'middle';
      difficultyProfile = 'elementary';
    } else {
      uiLevel = 'older';
      difficultyProfile = 'middle-school';
    }
    
    return UserProfile(
      age: age,
      uiLevel: uiLevel,
      difficultyProfile: difficultyProfile,
    );
  }

  /// Factory method to determine UI level and difficulty based on grade
  factory UserProfile.fromGrade(String grade) {
    String uiLevel;
    String difficultyProfile;
    int gradeNum = int.parse(grade.replaceAll(RegExp(r'[^\d]'), ''));
    
    if (gradeNum >= 1 && gradeNum <= 2) {
      uiLevel = 'young';
      difficultyProfile = 'early-elementary';
    } else if (gradeNum >= 3 && gradeNum <= 5) {
      uiLevel = 'middle';
      difficultyProfile = 'elementary';
    } else {
      uiLevel = 'older';
      difficultyProfile = 'middle-school';
    }
    
    return UserProfile(
      grade: grade,
      uiLevel: uiLevel,
      difficultyProfile: difficultyProfile,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userAge': age,
      'userGrade': grade,
      'uiLevel': uiLevel,
      'difficultyProfile': difficultyProfile,
      'isParentTeacherMode': isParentTeacherMode,
    };
  }

  /// Create from JSON (for loading saved profile)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['userAge'],
      grade: json['userGrade'],
      uiLevel: json['uiLevel'],
      difficultyProfile: json['difficultyProfile'],
      isParentTeacherMode: json['isParentTeacherMode'] ?? false,
    );
  }
}

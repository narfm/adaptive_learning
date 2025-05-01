import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A service class to manage audio playback for the app
class AudioService {
  // Singleton instance
  static final AudioService _instance = AudioService._internal();
  
  // Factory constructor to return the singleton instance
  factory AudioService() => _instance;
  
  // Private constructor
  AudioService._internal();
  
  // Audio players for different sound types
  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  
  // Sound effect paths
  final Map<String, String> _soundEffects = {
    'count': 'count.mp3',
    'correct': 'correct.mp3',
    'incorrect': 'incorrect.mp3',
    'pop': 'pop.mp3',
    'slide': 'slide.mp3',
    'combine': 'combine.mp3',
    'subtract': 'subtract.mp3',
    'multiply': 'multiply.mp3',
    'divide': 'divide.mp3',
    'success': 'success.mp3',
    'click': 'click.mp3',
  };
  
  // Flag to track if audio is enabled
  bool _isAudioEnabled = true;
  
  /// Get the current audio enabled state
  bool get isAudioEnabled => _isAudioEnabled;
  
  /// Set the audio enabled state
  set isAudioEnabled(bool value) {
    _isAudioEnabled = value;
    if (!_isAudioEnabled) {
      _effectsPlayer.stop();
      _backgroundPlayer.stop();
    }
    
    // Update volume based on enabled state
    _updateVolume();
  }
  
  /// Update volume based on enabled state
  Future<void> _updateVolume() async {
    try {
      if (_isAudioEnabled) {
        await _effectsPlayer.setVolume(1.0);
        await _backgroundPlayer.setVolume(0.3);
      } else {
        await _effectsPlayer.setVolume(0.0);
        await _backgroundPlayer.setVolume(0.0);
      }
    } catch (e) {
      debugPrint('Error updating audio volume: $e');
    }
  }
  
  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      await _effectsPlayer.setReleaseMode(ReleaseMode.stop);
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Set volume levels
      await _effectsPlayer.setVolume(1.0);
      await _backgroundPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }
  
  /// Play a sound effect
  Future<void> playSound(String soundName) async {
    if (!_isAudioEnabled) return;
    
    try {
      final soundPath = _soundEffects[soundName];
      if (soundPath != null) {
        await _effectsPlayer.stop();
        await _effectsPlayer.play(AssetSource('sounds/$soundPath'));
      } else {
        debugPrint('Sound effect not found: $soundName');
      }
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }
  
  /// Play background music
  Future<void> playBackgroundMusic(String musicName) async {
    if (!_isAudioEnabled) return;
    
    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.play(AssetSource('sounds/$musicName'));
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }
  
  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }
  
  /// Dispose the audio players
  Future<void> dispose() async {
    try {
      await _effectsPlayer.dispose();
      await _backgroundPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio players: $e');
    }
  }
}

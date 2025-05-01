# Technical Context: BrightMind Adaptive Learning App

## Technology Stack

### Core Framework
- **Flutter**: Cross-platform UI toolkit for building natively compiled applications
- **Dart**: Programming language used with Flutter

### Key Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| **lottie** | ^3.0.0 | JSON-based animation rendering for complex animations |
| **animated_text_kit** | ^4.2.2 | Text animations for engaging UI elements |
| **shared_preferences** | ^2.2.2 | Local storage for user preferences and profile data |
| **audioplayers** | ^5.2.1 | Audio playback for sound effects and voice guidance |
| **flutter_lints** | ^5.0.0 | Static analysis for code quality |

### Development Environment
- **Flutter SDK**: ^3.7.2
- **Dart SDK**: ^3.7.2
- **IDE Support**: VS Code, Android Studio
- **Platforms**: Android, iOS, Web, macOS, Linux, Windows

## Project Structure

```
flutter_application_1/
├── android/                 # Android platform-specific code
├── ios/                     # iOS platform-specific code
├── web/                     # Web platform-specific code
├── macos/                   # macOS platform-specific code
├── linux/                   # Linux platform-specific code
├── windows/                 # Windows platform-specific code
├── lib/                     # Dart source code
│   ├── main.dart            # Application entry point
│   ├── models/              # Data models
│   ├── screens/             # Full-page UI components
│   ├── widgets/             # Reusable UI components
│   └── utils/               # Helper functions and services
├── assets/                  # External resources
│   ├── animations/          # Lottie animation files
│   ├── images/              # Image assets
│   └── sounds/              # Audio files
├── test/                    # Test files
├── pubspec.yaml             # Project configuration and dependencies
└── analysis_options.yaml    # Linter configuration
```

## Asset Organization

### Animations
- Located in `assets/animations/`
- Format: Lottie JSON files (`.json`)
- Used for: Character animations, UI transitions, visual feedback
- Key files:
  - `mascot.json`: AI teacher character animation

### Images
- Located in `assets/images/`
- Formats: PNG, JPG
- Used for: UI elements, character images, object visualizations
- Key files:
  - `alex.jpg`: Teacher character image
  - `logo_placeholder.txt`: Placeholder for app logo

### Sounds
- Located in `assets/sounds/`
- Format: MP3
- Used for: Sound effects, voice guidance, feedback
- Required sounds:
  - `count.mp3`: Counting sound
  - `correct.mp3`: Correct answer sound
  - `incorrect.mp3`: Incorrect answer sound
  - `pop.mp3`: Object appearance sound
  - `slide.mp3`: Transition sound
  - `combine.mp3`: Addition operation sound
  - `subtract.mp3`: Subtraction operation sound
  - `multiply.mp3`: Multiplication operation sound
  - `divide.mp3`: Division operation sound
  - `success.mp3`: Problem completion sound
  - `click.mp3`: Button click sound

## Code Organization

### Models
- `UserProfile`: Stores user information (age, grade, preferences)
  - Factory methods for creation from different sources
  - JSON serialization/deserialization

### Screens
- `SplashScreen`: App entry point with branding and animations
- `AgeGradeSelectionScreen`: User profile creation interface
- `TeacherIntroductionScreen`: Character-led topic introduction
- `HomeScreen`: Main navigation hub
- `BasicMathLessonScreen`: Interactive math lesson with examples and problems

### Widgets
- `AnimatedMascot`: Character guide with different states and animations
- `AgeButton`: Specialized button for age selection
- `GradeButton`: Specialized button for grade selection
- `ExampleAnimationDisplay`: Visualizes math operations step-by-step
- `MathProblemDisplay`: Shows math problems with visual representations
- `InteractiveCountingArea`: Interactive area for object manipulation
- `AnswerOptionButton`: Multiple choice answer selection button

### Utils
- `constants.dart`: App-wide constants for styling and configuration
- `AudioService`: Service for managing sound playback

## Technical Constraints

### Performance Considerations
- **Animation Performance**: Complex animations must be optimized for lower-end devices
- **Memory Management**: Asset preloading balanced with memory usage
- **Audio Latency**: Sound effects need minimal delay for proper feedback

### Platform Compatibility
- **Screen Sizes**: UI must adapt to various device sizes (phones, tablets)
- **Platform Differences**: Handle platform-specific behaviors (permissions, navigation)
- **Accessibility**: Support platform accessibility features

### Development Constraints
- **Asset Size Management**: Balance quality with download size
- **Code Reusability**: Maximize component reuse across different lesson types
- **Testing Complexity**: UI testing for interactive elements

## Development Workflow

### Build Process
- Development builds via `flutter run`
- Release builds via `flutter build <platform>`
- Asset bundling handled by Flutter's asset system

### Testing Strategy
- Widget tests for UI components
- Unit tests for business logic
- Integration tests for user flows

### Deployment Targets
- Primary: Android and iOS
- Secondary: Web
- Future consideration: Desktop platforms

## Technical Debt & Considerations

### Current Technical Debt
- Default app name (`flutter_application_1`) needs updating
- Some placeholder assets need replacement
- Limited test coverage

### Future Technical Needs
- Backend integration for content management
- User authentication system
- Analytics implementation
- Localization infrastructure
- Comprehensive testing framework

## Development Tools

### Recommended Extensions
- Flutter and Dart VS Code extensions
- Flutter Inspector for UI debugging
- DevTools for performance analysis

### Debugging Tools
- Flutter DevTools for performance profiling
- Flutter Inspector for widget hierarchy analysis
- Dart DevTools for memory analysis

### CI/CD Considerations
- Automated testing setup
- Build pipeline for multiple platforms
- Version management

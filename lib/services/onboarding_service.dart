// lib/services/onboarding_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static OnboardingService? _instance;
  static OnboardingService get instance {
    _instance ??= OnboardingService._();
    return _instance!;
  }

  OnboardingService._();

  SharedPreferences? _prefs;

  static const String _hasSeenAboutKey = 'onboarding_has_seen_about';
  static const String _welcomeDialogShownKey = 'onboarding_welcome_shown';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Был ли показан диалог приветствия
  bool get hasShownWelcomeDialog {
    return _prefs?.getBool(_welcomeDialogShownKey) ?? false;
  }

  Future<void> markWelcomeDialogShown() async {
    await _prefs?.setBool(_welcomeDialogShownKey, true);
  }

  // Видел ли пользователь "О приложении"
  bool get hasSeenAbout {
    return _prefs?.getBool(_hasSeenAboutKey) ?? false;
  }

  Future<void> markAboutAsSeen() async {
    await _prefs?.setBool(_hasSeenAboutKey, true);
  }

  // Показывать ли бейдж
  bool get shouldShowAboutBadge => !hasSeenAbout;

  // Показывать ли диалог приветствия
  bool get shouldShowWelcomeDialog => !hasShownWelcomeDialog;
}

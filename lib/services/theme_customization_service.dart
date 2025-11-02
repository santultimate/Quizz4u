import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCustomizationService {
  static const String _themeKey = 'custom_theme';
  static const String _unlockedThemesKey = 'unlocked_themes';
  static const String _avatarKey = 'player_avatar';

  // Thèmes disponibles
  static const Map<String, Map<String, dynamic>> _availableThemes = {
    'default': {
      'name': 'Classique',
      'description': 'Thème par défaut élégant',
      'primaryColor': 0xFF2196F3,
      'secondaryColor': 0xFF03DAC6,
      'backgroundColor': 0xFF121212,
      'surfaceColor': 0xFF1E1E1E,
      'unlocked': true,
      'cost': 0,
      'icon': '🎨',
      'previewColors': [0xFF2196F3, 0xFF03DAC6, 0xFF121212],
    },
    'dark_neon': {
      'name': 'Néon Sombre',
      'description': 'Thème cyberpunk avec effets néon',
      'primaryColor': 0xFF00FF41,
      'secondaryColor': 0xFFFF0080,
      'backgroundColor': 0xFF0A0A0A,
      'surfaceColor': 0xFF1A1A1A,
      'unlocked': false,
      'cost': 200,
      'icon': '🌃',
      'previewColors': [0xFF00FF41, 0xFFFF0080, 0xFF0A0A0A],
    },
    'sunset': {
      'name': 'Coucher de Soleil',
      'description': 'Dégradé orange et rose',
      'primaryColor': 0xFFFF6B35,
      'secondaryColor': 0xFFFF8E53,
      'backgroundColor': 0xFF2D1B69,
      'surfaceColor': 0xFF4A2C7A,
      'unlocked': false,
      'cost': 150,
      'icon': '🌅',
      'previewColors': [0xFFFF6B35, 0xFFFF8E53, 0xFF2D1B69],
    },
    'ocean': {
      'name': 'Océan Profond',
      'description': 'Bleus et verts océaniques',
      'primaryColor': 0xFF0066CC,
      'secondaryColor': 0xFF00CCCC,
      'backgroundColor': 0xFF001122,
      'surfaceColor': 0xFF002244,
      'unlocked': false,
      'cost': 150,
      'icon': '🌊',
      'previewColors': [0xFF0066CC, 0xFF00CCCC, 0xFF001122],
    },
    'forest': {
      'name': 'Forêt Mystique',
      'description': 'Verts naturels et bruns',
      'primaryColor': 0xFF4CAF50,
      'secondaryColor': 0xFF8BC34A,
      'backgroundColor': 0xFF1B3B1B,
      'surfaceColor': 0xFF2D4A2D,
      'unlocked': false,
      'cost': 150,
      'icon': '🌲',
      'previewColors': [0xFF4CAF50, 0xFF8BC34A, 0xFF1B3B1B],
    },
    'royal': {
      'name': 'Royal',
      'description': 'Or et pourpre majestueux',
      'primaryColor': 0xFFFFD700,
      'secondaryColor': 0xFF9C27B0,
      'backgroundColor': 0xFF2D1B69,
      'surfaceColor': 0xFF4A2C7A,
      'unlocked': false,
      'cost': 300,
      'icon': '👑',
      'previewColors': [0xFFFFD700, 0xFF9C27B0, 0xFF2D1B69],
    },
    'matrix': {
      'name': 'Matrix',
      'description': 'Vert code Matrix',
      'primaryColor': 0xFF00FF00,
      'secondaryColor': 0xFF00CC00,
      'backgroundColor': 0xFF000000,
      'surfaceColor': 0xFF0A0A0A,
      'unlocked': false,
      'cost': 250,
      'icon': '💚',
      'previewColors': [0xFF00FF00, 0xFF00CC00, 0xFF000000],
    },
    'cosmic': {
      'name': 'Cosmique',
      'description': 'Violets et roses galactiques',
      'primaryColor': 0xFF9C27B0,
      'secondaryColor': 0xFFE91E63,
      'backgroundColor': 0xFF1A0033,
      'surfaceColor': 0xFF330066,
      'unlocked': false,
      'cost': 200,
      'icon': '🌌',
      'previewColors': [0xFF9C27B0, 0xFFE91E63, 0xFF1A0033],
    },
  };

  // Avatars disponibles
  static const Map<String, Map<String, dynamic>> _availableAvatars = {
    'default': {
      'name': 'Défaut',
      'emoji': '🧑‍🎓',
      'unlocked': true,
      'cost': 0,
    },
    'scientist': {
      'name': 'Scientifique',
      'emoji': '👨‍🔬',
      'unlocked': false,
      'cost': 100,
    },
    'teacher': {
      'name': 'Professeur',
      'emoji': '👩‍🏫',
      'unlocked': false,
      'cost': 100,
    },
    'astronaut': {
      'name': 'Astronaute',
      'emoji': '👨‍🚀',
      'unlocked': false,
      'cost': 150,
    },
    'wizard': {
      'name': 'Magicien',
      'emoji': '🧙‍♂️',
      'unlocked': false,
      'cost': 200,
    },
    'robot': {
      'name': 'Robot',
      'emoji': '🤖',
      'unlocked': false,
      'cost': 250,
    },
    'alien': {
      'name': 'Alien',
      'emoji': '👽',
      'unlocked': false,
      'cost': 300,
    },
    'ninja': {
      'name': 'Ninja',
      'emoji': '🥷',
      'unlocked': false,
      'cost': 200,
    },
    'pirate': {
      'name': 'Pirate',
      'emoji': '🏴‍☠️',
      'unlocked': false,
      'cost': 180,
    },
    'superhero': {
      'name': 'Super-héros',
      'emoji': '🦸‍♂️',
      'unlocked': false,
      'cost': 220,
    },
  };

  // Obtenir le thème actuel
  static Future<Map<String, dynamic>> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeData = prefs.getString(_themeKey);

    if (themeData != null) {
      return Map<String, dynamic>.from(json.decode(themeData));
    }

    return _availableThemes['default']!;
  }

  // Appliquer un thème
  static Future<void> setTheme(String themeId) async {
    final theme = _availableThemes[themeId];
    if (theme == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, json.encode(theme));

    print('[ThemeCustomization] 🎨 Thème appliqué: ${theme['name']}');
  }

  // Obtenir tous les thèmes
  static Future<List<Map<String, dynamic>>> getAllThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedThemes =
        prefs.getStringList(_unlockedThemesKey) ?? ['default'];

    return _availableThemes.entries.map((entry) {
      final theme = Map<String, dynamic>.from(entry.value);
      theme['id'] = entry.key;
      theme['unlocked'] = unlockedThemes.contains(entry.key);
      return theme;
    }).toList();
  }

  // Débloquer un thème
  static Future<bool> unlockTheme(String themeId) async {
    final theme = _availableThemes[themeId];
    if (theme == null) return false;

    // TODO: Vérifier si l'utilisateur a assez de coins/XP
    // TODO: Débiter le coût

    final prefs = await SharedPreferences.getInstance();
    final unlockedThemes =
        prefs.getStringList(_unlockedThemesKey) ?? ['default'];

    if (!unlockedThemes.contains(themeId)) {
      unlockedThemes.add(themeId);
      await prefs.setStringList(_unlockedThemesKey, unlockedThemes);

      print('[ThemeCustomization] 🎨 Thème débloqué: ${theme['name']}');
      return true;
    }

    return false;
  }

  // Obtenir l'avatar actuel
  static Future<Map<String, dynamic>> getCurrentAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarId = prefs.getString(_avatarKey) ?? 'default';

    final avatar = _availableAvatars[avatarId];
    if (avatar != null) {
      return {
        'id': avatarId,
        ...avatar,
      };
    }

    return {
      'id': 'default',
      ..._availableAvatars['default']!,
    };
  }

  // Définir l'avatar
  static Future<void> setAvatar(String avatarId) async {
    final avatar = _availableAvatars[avatarId];
    if (avatar == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, avatarId);

    print('[ThemeCustomization] 👤 Avatar défini: ${avatar['name']}');
  }

  // Obtenir tous les avatars
  static Future<List<Map<String, dynamic>>> getAllAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedAvatars =
        prefs.getStringList('${_unlockedThemesKey}_avatars') ?? ['default'];

    return _availableAvatars.entries.map((entry) {
      final avatar = Map<String, dynamic>.from(entry.value);
      avatar['id'] = entry.key;
      avatar['unlocked'] = unlockedAvatars.contains(entry.key);
      return avatar;
    }).toList();
  }

  // Débloquer un avatar
  static Future<bool> unlockAvatar(String avatarId) async {
    final avatar = _availableAvatars[avatarId];
    if (avatar == null) return false;

    // TODO: Vérifier si l'utilisateur a assez de coins/XP
    // TODO: Débiter le coût

    final prefs = await SharedPreferences.getInstance();
    final unlockedAvatars =
        prefs.getStringList('${_unlockedThemesKey}_avatars') ?? ['default'];

    if (!unlockedAvatars.contains(avatarId)) {
      unlockedAvatars.add(avatarId);
      await prefs.setStringList(
          '${_unlockedThemesKey}_avatars', unlockedAvatars);

      print('[ThemeCustomization] 👤 Avatar débloqué: ${avatar['name']}');
      return true;
    }

    return false;
  }

  // Générer un thème personnalisé
  static Map<String, dynamic> generateCustomTheme({
    required int primaryColor,
    required int secondaryColor,
    required int backgroundColor,
    required int surfaceColor,
  }) {
    return {
      'name': 'Personnalisé',
      'description': 'Thème créé par vous',
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'unlocked': true,
      'cost': 0,
      'icon': '🎨',
      'previewColors': [primaryColor, secondaryColor, backgroundColor],
      'isCustom': true,
    };
  }

  // Obtenir les couleurs d'un thème
  static ColorScheme getColorScheme(Map<String, dynamic> theme) {
    return ColorScheme.fromSeed(
      seedColor: Color(theme['primaryColor']),
      brightness: Brightness.dark,
      background: Color(theme['backgroundColor']),
      surface: Color(theme['surfaceColor']),
      secondary: Color(theme['secondaryColor']),
    );
  }

  // Obtenir les statistiques de personnalisation
  static Future<Map<String, dynamic>> getCustomizationStats() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedThemes =
        prefs.getStringList(_unlockedThemesKey) ?? ['default'];
    final unlockedAvatars =
        prefs.getStringList('${_unlockedThemesKey}_avatars') ?? ['default'];

    return {
      'unlockedThemes': unlockedThemes.length,
      'totalThemes': _availableThemes.length,
      'unlockedAvatars': unlockedAvatars.length,
      'totalAvatars': _availableAvatars.length,
      'completionPercentage':
          ((unlockedThemes.length + unlockedAvatars.length) /
                  (_availableThemes.length + _availableAvatars.length) *
                  100)
              .round(),
    };
  }

  // Réinitialiser toutes les personnalisations
  static Future<void> resetAllCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_unlockedThemesKey);
    await prefs.remove(_avatarKey);
    await prefs.remove('${_unlockedThemesKey}_avatars');

    print('[ThemeCustomization] 🔄 Personnalisations réinitialisées');
  }
}










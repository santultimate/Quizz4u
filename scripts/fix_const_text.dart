#!/usr/bin/env dart

import 'dart:io';

void main() {
  final file = File('lib/screens/enhanced_premium_screen.dart');
  String content = file.readAsStringSync();
  
  // Remplacer tous les "const Text(TranslationService.translate(...))" par "Text(TranslationService.translate(...))"
  // en gardant le style const
  content = content.replaceAllMapped(
    RegExp(r'(\s*)(const Text\(\s*TranslationService\.translate\([^)]+\)\s*,)'),
    (Match m) => '${m[1]}Text(',
  );
  
  file.writeAsStringSync(content);
  print('✅ Fixed const Text() issues in enhanced_premium_screen.dart');
}


import 'package:flutter/material.dart';
import 'category_selection_screen.dart'; // Assure-toi d'importer le bon fichier

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Fond vert comme les autres écrans
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quizz4U',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 100,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySelectionScreen(
                        onCategorySelected: (category) {
                          // Tu redirigeras vers QuizPage ici
                        },
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontFamily: 'Raleway',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

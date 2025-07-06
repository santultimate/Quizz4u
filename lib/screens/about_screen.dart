import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'À propos',
          style: TextStyle(fontFamily: 'Signatra', fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Logo/Image de l'app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.quiz, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Nom de l'app
            const Text(
              'Quizz4u',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 10),

            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Description
            const Text(
              'Une application de quiz éducative avec des questions variées sur différents sujets. Testez vos connaissances et améliorez-vous !',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 40),

            // Informations du développeur
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Développé par',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Yacouba Santara',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Développeur Flutter',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Section Don
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, size: 40, color: Colors.orange),
                  const SizedBox(height: 10),
                  const Text(
                    'Soutenez le développement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Si vous aimez cette application, vous pouvez soutenir son développement en faisant un don.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Boutons de paiement
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PaymentButton(
                        title: 'Orange Money',
                        icon: Icons.phone_android,
                        color: Colors.orange,
                        onTap: () => _makeDonation(context, 'Orange Money'),
                      ),
                      _PaymentButton(
                        title: 'Moov Money',
                        icon: Icons.phone_android,
                        color: Colors.blue,
                        onTap: () => _makeDonation(context, 'Moov Money'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PaymentButton(
                        title: 'M-Pesa',
                        icon: Icons.phone_android,
                        color: Colors.green,
                        onTap: () => _makeDonation(context, 'M-Pesa'),
                      ),
                      _PaymentButton(
                        title: 'Wave',
                        icon: Icons.phone_android,
                        color: Colors.purple,
                        onTap: () => _makeDonation(context, 'Wave'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _ContactItem(
                    icon: Icons.email,
                    text: 'yacoubasantara@yahoo.fr',
                    onTap: () => _launchEmail(),
                  ),
                  const SizedBox(height: 10),
                  _ContactItem(
                    icon: Icons.phone,
                    text: '+223 76 03 91 92',
                    onTap: () => _launchPhone(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _makeDonation(BuildContext context, String method) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Don via $method'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Numéro: +223 76 03 91 92'),
                const SizedBox(height: 10),
                const Text('Montant suggéré: 500 FCFA'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Merci pour votre don via $method !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'yacoubasantara@yahoo.fr',
      query: 'subject=Support Quizz4u',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+22376039192');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

class _PaymentButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: Text(title, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.purple, size: 20),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

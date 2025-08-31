import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
// import '../services/premium_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text(
          'Version Premium',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 30),
            const Text(
              'Quizz4u Premium',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: 'Signatra',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profitez de Quizz4u sans publicités !',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: 'Raleway',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Avantages Premium :',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.amber,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildFeature('✓ Aucune publicité', Icons.block),
                  _buildFeature('✓ Expérience fluide', Icons.speed),
                  _buildFeature('✓ Support du développement', Icons.favorite),
                  _buildFeature('✓ Mise à jour gratuite', Icons.update),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Vérifier si le service est prêt
                if (!PurchaseService.isReady()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Service d\'achat non disponible. Vérifiez votre connexion.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Afficher un indicateur de chargement
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                );

                try {
                  // Effectuer l'achat
                  final success = await PurchaseService.purchasePremium();

                  if (context.mounted) {
                    Navigator.pop(context); // Fermer le loader

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Achat en cours... Vérification en cours.'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Erreur lors de l\'achat. Vérifiez que les produits sont configurés.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Fermer le loader
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: FutureBuilder<String>(
                future: Future.value(PurchaseService.getFormattedPrice()),
                builder: (context, snapshot) {
                  return Text(
                    'Acheter Premium - ${snapshot.data ?? '2.99€'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );

                    await PurchaseService.restorePurchases();

                    if (context.mounted) {
                      Navigator.pop(context); // Fermer le loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Achats restaurés !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Restaurer achats',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Continuer avec les pubs',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Les publicités nous aident à maintenir l\'application gratuite et à ajouter de nouvelles fonctionnalités. Merci de votre compréhension !',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Raleway',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Raleway',
            ),
          ),
        ],
      ),
    );
  }
}

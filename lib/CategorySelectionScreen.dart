class CategorySelectionScreen extends StatelessWidget {
  final Function(String) onCategorySelected;

  CategorySelectionScreen({required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Choisissez une catégorie',
          style: TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CategoryButton(
              title: 'Sciences',
              onTap: () => onCategorySelected('Sciences'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Culture générale',
              onTap: () => onCategorySelected('Culture générale'),
            ),
            const SizedBox(height: 20),
            CategoryButton(
              title: 'Mathématiques',
              onTap: () => onCategorySelected('Mathématiques'),
            ),
            // Ajoute ici d'autres catégories si besoin
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CategoryButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.green,
            fontFamily: 'Raleway',
          ),
        ),
      ),
    );
  }
}
